package com.solapur.turf.service;

import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.dto.RefundDto;
import com.solapur.turf.controller.RefundController.RefundRequest;
import com.solapur.turf.controller.RefundController.ProcessRefundRequest;
import com.solapur.turf.entity.Booking;
import com.solapur.turf.entity.Refund;
import com.solapur.turf.entity.User;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.enums.RefundStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.BookingRepository;
import com.solapur.turf.repository.RefundRepository;
import com.solapur.turf.repository.UserRepository;
import com.solapur.turf.repository.UserWalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RefundService {

    private final RefundRepository refundRepository;
    private final BookingRepository bookingRepository;
    private final UserWalletRepository userWalletRepository;

    public PageResponse<RefundDto> getUserRefunds(UUID userId, int page, int limit, String status) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "requestedAt"));

        Page<Refund> refundPage;
        if (status != null && !status.isEmpty()) {
            try {
                RefundStatus refundStatus = RefundStatus.valueOf(status.toUpperCase());
                List<Refund> filtered = refundRepository.findByUserIdOrderByRequestedAtDesc(userId)
                        .stream()
                        .filter(refund -> refund.getStatus() == refundStatus)
                        .collect(java.util.stream.Collectors.toList());
                
                int start = (int) pageable.getOffset();
                int end = Math.min((start + pageable.getPageSize()), filtered.size());
                refundPage = new org.springframework.data.domain.PageImpl<>(
                        filtered.subList(start, end), pageable, filtered.size());
            } catch (IllegalArgumentException e) {
                refundPage = Page.empty(pageable);
            }
        } else {
            refundPage = refundRepository.findByUserIdOrderByRequestedAtDesc(userId, pageable);
        }

        return new PageResponse<>(refundPage.map(this::mapToDto));
    }

    public List<RefundDto> getRefundsByBooking(UUID bookingId) {
        List<Refund> refunds = refundRepository.findByBookingId(bookingId);
        return refunds.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional
    public RefundDto requestRefund(UUID userId, RefundRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ApiException("Booking not found", HttpStatus.NOT_FOUND));

        // Validate user can request refund for this booking
        if (!booking.getUser().getId().equals(userId)) {
            throw new ApiException("You can only request refunds for your own bookings", HttpStatus.FORBIDDEN);
        }

        // Check if refund already exists for this booking
        List<Refund> existingRefunds = refundRepository.findByBookingId(request.getBookingId());
        boolean hasActiveRefund = existingRefunds.stream()
                .anyMatch(r -> r.getStatus() == RefundStatus.REQUESTED || 
                              r.getStatus() == RefundStatus.PENDING || 
                              r.getStatus() == RefundStatus.APPROVED);

        if (hasActiveRefund) {
            throw new ApiException("Refund already requested for this booking", HttpStatus.CONFLICT);
        }

        // Validate booking is eligible for refund
        validateRefundEligibility(booking);

        // Calculate refund amount
        BigDecimal refundAmount = request.getRequestedAmount() != null ? 
                request.getRequestedAmount() : calculateRefundAmount(booking);

        if (refundAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApiException("Refund amount must be greater than zero", HttpStatus.BAD_REQUEST);
        }

        // Create refund request
        Refund refund = Refund.builder()
                .booking(booking)
                .user(booking.getUser())
                .originalAmount(booking.getFinalAmount())
                .requestedAmount(refundAmount)
                .refundMethod(request.getRefundMethod())
                .status(RefundStatus.REQUESTED)
                .reason(request.getReason())
                .requestedAt(LocalDateTime.now())
                .build();

        Refund saved = refundRepository.save(refund);
        return mapToDto(saved);
    }

    @Transactional
    public RefundDto processRefund(UUID refundId, ProcessRefundRequest request) {
        Refund refund = refundRepository.findById(refundId)
                .orElseThrow(() -> new ApiException("Refund not found", HttpStatus.NOT_FOUND));

        if (refund.getStatus() != RefundStatus.REQUESTED && refund.getStatus() != RefundStatus.PENDING) {
            throw new ApiException("Refund cannot be processed in current status", HttpStatus.BAD_REQUEST);
        }

        if ("APPROVE".equalsIgnoreCase(request.getAction())) {
            // Approve and process refund
            BigDecimal approvedAmount = request.getApprovedAmount() != null ? 
                    request.getApprovedAmount() : refund.getRequestedAmount();

            refund.setStatus(RefundStatus.APPROVED);
            refund.setApprovedAmount(approvedAmount);
            refund.setProcessedAt(LocalDateTime.now());
            refund.setProcessedBy(request.getProcessedBy());
            refund.setNotes(request.getNotes());

            // Process the actual refund
            processRefundPayment(refund, approvedAmount);

            refund.setStatus(RefundStatus.PROCESSED);
            
        } else if ("REJECT".equalsIgnoreCase(request.getAction())) {
            // Reject refund
            refund.setStatus(RefundStatus.REJECTED);
            refund.setRejectionReason(request.getNotes());
            refund.setProcessedAt(LocalDateTime.now());
            refund.setProcessedBy(request.getProcessedBy());

        } else {
            throw new ApiException("Invalid action. Use APPROVE or REJECT", HttpStatus.BAD_REQUEST);
        }

        Refund saved = refundRepository.save(refund);
        return mapToDto(saved);
    }

    @Transactional
    public RefundDto cancelRefund(UUID refundId, String reason) {
        Refund refund = refundRepository.findById(refundId)
                .orElseThrow(() -> new ApiException("Refund not found", HttpStatus.NOT_FOUND));

        if (refund.getStatus() == RefundStatus.PROCESSED || refund.getStatus() == RefundStatus.CANCELLED) {
            throw new ApiException("Refund cannot be cancelled in current status", HttpStatus.BAD_REQUEST);
        }

        refund.setStatus(RefundStatus.CANCELLED);
        refund.setRejectionReason(reason);
        refund.setProcessedAt(LocalDateTime.now());

        Refund saved = refundRepository.save(refund);
        return mapToDto(saved);
    }

    public PageResponse<RefundDto> getAllRefunds(int page, int limit, String status, 
                                               LocalDateTime startDate, LocalDateTime endDate) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "requestedAt"));

        RefundStatus statusEnum = null;
        if (status != null && !status.isEmpty()) {
            try {
                statusEnum = RefundStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                // Invalid status, will return all results
            }
        }

        Page<Refund> refundPage = refundRepository.findWithFilters(statusEnum, startDate, endDate, pageable);
        return new PageResponse<>(refundPage.map(this::mapToDto));
    }

    public Object getRefundStats() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalRequested", refundRepository.countByStatus(RefundStatus.REQUESTED));
        stats.put("totalPending", refundRepository.countByStatus(RefundStatus.PENDING));
        stats.put("totalApproved", refundRepository.countByStatus(RefundStatus.APPROVED));
        stats.put("totalProcessed", refundRepository.countByStatus(RefundStatus.PROCESSED));
        stats.put("totalRejected", refundRepository.countByStatus(RefundStatus.REJECTED));
        stats.put("totalRefundedAmount", refundRepository.sumProcessedRefunds());
        
        List<Refund> pendingRefunds = refundRepository.findPendingRefunds();
        stats.put("pendingRefundsCount", pendingRefunds.size());
        
        return stats;
    }

    private void validateRefundEligibility(Booking booking) {
        if (booking.getBookingStatus() != com.solapur.turf.enums.BookingStatus.CANCELLED &&
            booking.getBookingStatus() != com.solapur.turf.enums.BookingStatus.COMPLETED) {
            throw new ApiException("Booking must be cancelled or completed to request refund", HttpStatus.BAD_REQUEST);
        }

        if (booking.getPaymentStatus() != com.solapur.turf.enums.PaymentStatus.PAID &&
            booking.getPaymentStatus() != com.solapur.turf.enums.PaymentStatus.PARTIAL) {
            throw new ApiException("No payment found for this booking", HttpStatus.BAD_REQUEST);
        }
    }

    private BigDecimal calculateRefundAmount(Booking booking) {
        // Use the refund amount already calculated during cancellation if available
        if (booking.getRefundAmount() != null) {
            return booking.getRefundAmount();
        }

        // Default calculation based on cancellation policy
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime bookingDateTime = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        long hoursSinceBooking = Duration.between(bookingDateTime, now).toHours();

        if (hoursSinceBooking >= 48) {
            return booking.getFinalAmount();
        } else if (hoursSinceBooking >= 24) {
            return booking.getFinalAmount().multiply(BigDecimal.valueOf(0.5));
        } else if (hoursSinceBooking >= 2) {
            return booking.getFinalAmount().multiply(BigDecimal.valueOf(0.25));
        } else {
            return BigDecimal.ZERO;
        }
    }

    @Transactional
    private void processRefundPayment(Refund refund, BigDecimal amount) {
        User user = refund.getUser();
        
        // Get or create user wallet
        UserWallet wallet = userWalletRepository.findByUserId(user.getId())
                .orElseGet(() -> {
                    UserWallet newWallet = UserWallet.builder()
                            .user(user)
                            .balance(BigDecimal.ZERO)
                            .build();
                    return userWalletRepository.save(newWallet);
                });

        // Add refund to wallet
        wallet.setBalance(wallet.getBalance().add(amount));
        userWalletRepository.save(wallet);

        // Generate transaction ID
        String transactionId = "REF-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        refund.setTransactionId(transactionId);
    }

    private RefundDto mapToDto(Refund refund) {
        return RefundDto.builder()
                .id(refund.getId())
                .bookingId(refund.getBooking().getId())
                .userId(refund.getUser().getId())
                .bookingReference("BK-" + refund.getBooking().getId().toString().substring(0, 8).toUpperCase())
                .userName(refund.getUser().getFullName())
                .turfName(refund.getBooking().getTurf().getName())
                .originalAmount(refund.getOriginalAmount())
                .requestedAmount(refund.getRequestedAmount())
                .approvedAmount(refund.getApprovedAmount())
                .refundMethod(refund.getRefundMethod())
                .status(refund.getStatus())
                .reason(refund.getReason())
                .rejectionReason(refund.getRejectionReason())
                .requestedAt(refund.getRequestedAt())
                .processedAt(refund.getProcessedAt())
                .processedBy(refund.getProcessedBy())
                .notes(refund.getNotes())
                .transactionId(refund.getTransactionId())
                .build();
    }
}
