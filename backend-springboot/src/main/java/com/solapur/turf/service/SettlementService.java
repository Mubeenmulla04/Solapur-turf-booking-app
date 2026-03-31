package com.solapur.turf.service;

import com.solapur.turf.dto.SettlementDto;
import com.solapur.turf.dto.TurfOwnerDto;
import com.solapur.turf.dto.UserDto;
import com.solapur.turf.entity.Booking;
import com.solapur.turf.entity.Settlement;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.PaymentStatus;
import com.solapur.turf.enums.SettlementStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.BookingRepository;
import com.solapur.turf.repository.SettlementRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SettlementService {

    private final SettlementRepository settlementRepository;
    private final BookingRepository bookingRepository;
    private final TurfOwnerRepository turfOwnerRepository;

    public List<SettlementDto> getPendingSettlements() {
        return settlementRepository.findByStatus(SettlementStatus.PENDING)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<SettlementDto> getOwnerSettlements(UUID ownerId) {
        return settlementRepository.findByOwnerIdOrderByPeriodStartDesc(ownerId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public void markAsProcessed(UUID id, Map<String, String> data) {
        Settlement settlement = settlementRepository.findById(id)
                .orElseThrow(() -> new ApiException("Settlement not found", HttpStatus.NOT_FOUND));

        if (settlement.getStatus() == SettlementStatus.COMPLETED) {
            throw new ApiException("Settlement is already processed", HttpStatus.BAD_REQUEST);
        }

        String bankTransactionId = data.get("bankTransactionId");
        if (bankTransactionId == null || bankTransactionId.trim().isEmpty()) {
            throw new ApiException("Bank transaction ID is required", HttpStatus.BAD_REQUEST);
        }

        settlement.setStatus(SettlementStatus.COMPLETED);
        settlement.setBankReference(bankTransactionId);
        settlement.setProcessedAt(LocalDateTime.now());

        settlementRepository.save(settlement);
    }

    // Automated settlement generation - runs on 1st of every month
    @Scheduled(cron = "0 0 0 1 * ?")
    @Transactional
    public void generateMonthlySettlements() {
        YearMonth lastMonth = YearMonth.now().minusMonths(1);
        LocalDate periodStart = lastMonth.atDay(1);
        LocalDate periodEnd = lastMonth.atEndOfMonth();

        generateSettlementsForPeriod(periodStart, periodEnd);
    }

    // Manual settlement generation for specific period
    @Transactional
    public void generateSettlementsForPeriod(LocalDate startDate, LocalDate endDate) {
        List<TurfOwner> owners = turfOwnerRepository.findAll();

        for (TurfOwner owner : owners) {
            generateSettlementForOwner(owner, startDate, endDate);
        }
    }

    @Transactional
    public void generateSettlementForOwner(TurfOwner owner, LocalDate startDate, LocalDate endDate) {
        // Check if settlement already exists for this period
        boolean exists = settlementRepository.existsByOwnerIdAndPeriodStartAndPeriodEnd(
                owner.getId(), startDate, endDate);
        
        if (exists) {
            return; // Skip if already generated
        }

        // Get all completed bookings for the period
        List<Booking> bookings = bookingRepository.findByTurfOwnerIdAndBookingDateBetweenAndBookingStatus(
                owner.getId(), startDate, endDate, BookingStatus.COMPLETED);

        // Calculate totals
        BigDecimal totalRevenue = bookings.stream()
                .filter(b -> b.getPaymentStatus() == PaymentStatus.PAID || b.getPaymentStatus() == PaymentStatus.COMPLETED || b.getPaymentStatus() == PaymentStatus.REFUNDED)
                .map(Booking::getFinalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal platformCommission = totalRevenue.multiply(BigDecimal.valueOf(0.10)); // 10% commission
        BigDecimal transactionFee = BigDecimal.valueOf(bookings.size() * 5.00); // Rs. 5 per booking
        BigDecimal settlementAmount = totalRevenue.subtract(platformCommission).subtract(transactionFee);

        if (settlementAmount.compareTo(BigDecimal.ZERO) > 0) {
            Settlement settlement = Settlement.builder()
                    .owner(owner)
                    .periodStart(startDate)
                    .periodEnd(endDate)
                    .totalBookings(bookings.size())
                    .totalRevenue(totalRevenue)
                    .platformCommission(platformCommission)
                    .transactionFee(transactionFee)
                    .settlementAmount(settlementAmount)
                    .status(SettlementStatus.PENDING)
                    .generatedAt(LocalDateTime.now())
                    .processedAt(LocalDateTime.now()) // Set current time for now
                    .build();

            settlementRepository.save(settlement);
        }
    }

    @Transactional
    public void processPendingSettlements() {
        List<Settlement> pendingSettlements = settlementRepository.findByStatus(SettlementStatus.PENDING);

        for (Settlement settlement : pendingSettlements) {
            try {
                // Simulate bank transfer process
                String transactionId = "BANK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
                
                settlement.setStatus(SettlementStatus.COMPLETED);
                settlement.setBankReference(transactionId);
                settlement.setProcessedAt(LocalDateTime.now());
                
                settlementRepository.save(settlement);
            } catch (Exception e) {
                // Mark as failed if processing fails
                settlement.setStatus(SettlementStatus.FAILED);
                settlement.setErrorMessage(e.getMessage());
                settlementRepository.save(settlement);
            }
        }
    }

    public Map<String, Object> getSettlementStats() {
        Map<String, Object> stats = Map.of(
                "pendingCount", settlementRepository.countByStatus(SettlementStatus.PENDING),
                "completedCount", settlementRepository.countByStatus(SettlementStatus.COMPLETED),
                "failedCount", settlementRepository.countByStatus(SettlementStatus.FAILED),
                "totalProcessed", settlementRepository.countByStatus(SettlementStatus.COMPLETED),
                "pendingAmount", settlementRepository.sumSettlementAmountByStatus(SettlementStatus.PENDING),
                "totalAmount", settlementRepository.sumSettlementAmountByStatus(SettlementStatus.COMPLETED)
        );

        return stats;
    }

    private SettlementDto mapToDto(Settlement s) {
        TurfOwnerDto turfOwnerDto = null;
        if (s.getOwner() != null) {
            UserDto userDto = null;
            if (s.getOwner().getUser() != null) {
                userDto = UserDto.builder()
                        .userId(s.getOwner().getUser().getId().toString())
                        .fullName(s.getOwner().getUser().getFullName())
                        .email(s.getOwner().getUser().getEmail())
                        .phone(s.getOwner().getUser().getPhone())
                        .role(s.getOwner().getUser().getRole())
                        .build();
            }

            turfOwnerDto = TurfOwnerDto.builder()
                    .id(s.getOwner().getId())
                    .user(userDto)
                    .businessName(s.getOwner().getBusinessName())
                    .bankAccountNumber(s.getOwner().getBankAccountNumber())
                    .bankIfsc(s.getOwner().getIfscCode()) // Fixed mapping to use what TurfOwner actually holds
                    .build();
        }

        return SettlementDto.builder()
                .id(s.getId())
                .ownerId(s.getOwner() != null ? s.getOwner().getId() : null)
                .turfOwner(turfOwnerDto)
                .periodStart(s.getPeriodStart())
                .periodEnd(s.getPeriodEnd())
                .settlementAmount(s.getSettlementAmount())
                .commissionAmount(s.getCommissionAmount())
                .transactionFee(s.getTransactionFee())
                .status(s.getStatus())
                .bankReference(s.getBankReference())
                .processedAt(s.getProcessedAt())
                .build();
    }
}
