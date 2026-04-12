package com.solapur.turf.service;

import com.solapur.turf.dto.BookingCancellationRequest;
import com.solapur.turf.dto.BookingDto;
import com.solapur.turf.dto.BookingRescheduleRequest;
import com.solapur.turf.dto.CreateBookingRequest;
import com.solapur.turf.dto.PaymentOrderRequest;
import com.solapur.turf.dto.PaymentOrderResponse;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.dto.TurfListingDto;
import com.solapur.turf.dto.UserDto;
import com.solapur.turf.entity.Booking;
import com.solapur.turf.entity.DynamicPricingRule;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.entity.User;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.repository.DynamicPricingRuleRepository;
import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.PaymentStatus;
import com.solapur.turf.exception.BookingAlreadyExistsException;
import com.solapur.turf.exception.InvalidRequestException;
import com.solapur.turf.exception.ResourceNotFoundException;
import com.solapur.turf.repository.BookingRepository;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final TurfService turfService;
    private final UserRepository userRepository;
    private final TurfListingRepository turfListingRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final UserWalletRepository userWalletRepository;
    private final DynamicPricingRuleRepository dynamicPricingRuleRepository;
    private final WalletService walletService;
    private final PaymentService paymentService;
    private final SettlementService settlementService;

    // ─── Queries ─────────────────────────────────────────────────────────────

    public PageResponse<BookingDto> getUserBookings(UUID userId, int page, int limit) {
        Pageable pageable = paged(page, limit);
        return new PageResponse<>(bookingRepository.findByUserId(userId, pageable).map(this::mapToDto));
    }

    public PageResponse<BookingDto> getOwnerBookings(UUID userId, int page, int limit) {
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElse(null);
        if (owner == null) return new PageResponse<>(org.springframework.data.domain.Page.empty());
        return new PageResponse<>(bookingRepository.findByTurfOwnerId(owner.getId(), paged(page, limit))
                .map(this::mapToDto));
    }

    public PageResponse<BookingDto> getAllBookings(int page, int limit) {
        return new PageResponse<>(bookingRepository.findAll(paged(page, limit)).map(this::mapToDto));
    }

    /** Get a single booking by ID — validates the requesting user owns it or is staff. */
    public BookingDto getBookingById(UUID bookingId, UUID requestingUserId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        boolean isOwner  = booking.getTurf().getOwner().getUser().getId().equals(requestingUserId);
        boolean isCustomer = booking.getUser().getId().equals(requestingUserId);
        if (!isOwner && !isCustomer) {
            throw new InvalidRequestException("You do not have access to this booking");
        }
        return mapToDto(booking);
    }

    // ─── Create (with double-booking prevention + pessimistic lock) ──────────

    @Transactional
    public BookingDto createBooking(UUID userId, CreateBookingRequest request) {
        if (request.getStartTime().isAfter(request.getEndTime())
                || request.getStartTime().equals(request.getEndTime())) {
            throw new InvalidRequestException("Start time must be strictly before end time");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        TurfListing turf = turfListingRepository.findById(request.getTurfId())
                .orElseThrow(() -> new ResourceNotFoundException("Turf", "id", request.getTurfId()));

        // Reject past dates/times
        LocalDate today = LocalDate.now();
        if (request.getBookingDate().isBefore(today)) {
            throw new InvalidRequestException("Cannot book for a past date");
        }
        if (request.getBookingDate().isEqual(today)
                && request.getStartTime().isBefore(LocalTime.now())) {
            throw new InvalidRequestException("Cannot book a time slot that has already passed");
        }

        // ── Pessimistic DB lock ───────────────────────────────────────────────
        // Acquires an exclusive row-level lock on all existing bookings for this
        // turf+date before checking overlaps, preventing concurrent double-bookings.
        List<Booking> dayBookings = bookingRepository.findByTurfIdAndDateForUpdate(
                turf.getId(), request.getBookingDate());

        // ── Application-level O(log N) interval overlap check ─────────────────
        TreeMap<LocalTime, Booking> timeline = new TreeMap<>();
        for (Booking b : dayBookings) timeline.put(b.getStartTime(), b);

        Map.Entry<LocalTime, Booking> before = timeline.floorEntry(request.getStartTime());
        if (before != null && before.getValue().getEndTime().isAfter(request.getStartTime())) {
            throw new BookingAlreadyExistsException("Slot overlaps an existing booking (start conflict).");
        }

        Map.Entry<LocalTime, Booking> during = timeline.floorEntry(request.getEndTime().minusMinutes(1));
        if (during != null && !during.getKey().isBefore(request.getStartTime())) {
            throw new BookingAlreadyExistsException("Slot overlaps an existing booking (end conflict).");
        }

        // ── Price calculation with Dynamic Pricing Rules ─────────────────────
        long durationMinutes = ChronoUnit.MINUTES.between(request.getStartTime(), request.getEndTime());
        BigDecimal durationHours = BigDecimal.valueOf(durationMinutes)
                .divide(BigDecimal.valueOf(60), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal finalAmount = calculateBookingPrice(turf, request.getBookingDate(), 
                                                       request.getStartTime(), request.getEndTime());

        // ── Build booking ──────────────────────────────────────────────────────
        Booking booking = Booking.builder()
                .user(user)
                .turf(turf)
                .bookingDate(request.getBookingDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .durationHours(durationHours)
                .baseAmount(finalAmount)
                .finalAmount(finalAmount)
                .paymentMethod(request.getPaymentMethod())
                .build();

        // ── Payment status assignment ──────────────────────────────────────────
        BigDecimal advanceRequired = BigDecimal.ZERO;
        if (request.getPaymentMethod() == com.solapur.turf.enums.PaymentMethod.PARTIAL_ONLINE_CASH) {
            advanceRequired = BigDecimal.valueOf(50); // ₹50 advance
        } else if (request.getPaymentMethod().requiresPrepayment()) {
            advanceRequired = finalAmount;
        }

        booking.setAdvanceAmount(advanceRequired);
        booking.setCashAmount(finalAmount.subtract(advanceRequired));

        switch (request.getPaymentMethod()) {
            case WALLET -> {
                walletService.debitFunds(userId, finalAmount, "Booking payment for " + turf.getName());
                booking.setPaymentStatus(PaymentStatus.PAID);
                booking.setBookingStatus(BookingStatus.CONFIRMED);
            }
            case PARTIAL_ONLINE_CASH -> {
                booking.setPaymentStatus(PaymentStatus.PARTIAL);
                booking.setBookingStatus(BookingStatus.CONFIRMED);
            }
            case CASH, CASH_ON_BOOKING -> {
                // Pay at venue — confirm immediately
                booking.setPaymentStatus(PaymentStatus.PENDING);
                booking.setBookingStatus(BookingStatus.CONFIRMED);
            }
            default -> {
                // ONLINE / FULL_ONLINE — awaits payment gateway callback
                booking.setPaymentStatus(PaymentStatus.PENDING);
                booking.setBookingStatus(BookingStatus.PENDING);
            }
        }

        Booking saved = bookingRepository.save(booking);
        BookingDto dto = mapToDto(saved);

        // ── Razorpay order generation ──────────────────────────────────────────
        boolean needsPaymentOrder = (request.getPaymentMethod() == com.solapur.turf.enums.PaymentMethod.ONLINE 
                || request.getPaymentMethod() == com.solapur.turf.enums.PaymentMethod.FULL_ONLINE
                || request.getPaymentMethod() == com.solapur.turf.enums.PaymentMethod.PARTIAL_ONLINE_CASH);

        if (needsPaymentOrder && advanceRequired.compareTo(BigDecimal.ZERO) > 0) {
            try {
                PaymentOrderRequest orderReq = PaymentOrderRequest.builder()
                        .amount(advanceRequired)
                        .currency("INR")
                        .bookingId(saved.getId())
                        .transactionType("BOOKING_PAYMENT")
                        .build();

                PaymentOrderResponse orderRes = paymentService.createOrder(orderReq, userId);
                dto.setRazorpayOrderId(orderRes.getId());
            } catch (Exception e) {
                // If payment order fails, we might want to delete the pending booking or just log it
                // For now, just log. The user will see an error on the frontend and can retry.
            }
        }

        return dto;
    }

    // ─── Owner actions ────────────────────────────────────────────────────────

    /** Owner confirms a PENDING booking (e.g. after manual payment verification). */
    @Transactional
    public BookingDto confirmBooking(UUID bookingId, UUID ownerUserId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        if (!booking.getTurf().getOwner().getUser().getId().equals(ownerUserId)) {
            throw new InvalidRequestException("You do not own this turf");
        }
        if (booking.getBookingStatus() == BookingStatus.CONFIRMED) {
            throw new InvalidRequestException("Booking is already confirmed");
        }
        if (booking.getBookingStatus() == BookingStatus.CANCELLED) {
            throw new InvalidRequestException("Cannot confirm a cancelled booking");
        }

        booking.setBookingStatus(BookingStatus.CONFIRMED);
        return mapToDto(bookingRepository.save(booking));
    }

    /** Owner/system marks an on-going booking as COMPLETED. */
    @Transactional
    public BookingDto completeBooking(UUID bookingId, UUID ownerUserId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        if (!booking.getTurf().getOwner().getUser().getId().equals(ownerUserId)) {
            throw new InvalidRequestException("You do not own this turf");
        }
        if (booking.getBookingStatus() == BookingStatus.CANCELLED) {
            throw new InvalidRequestException("Cannot complete a cancelled booking");
        }
        if (booking.getBookingStatus() == BookingStatus.COMPLETED) {
            throw new InvalidRequestException("Booking is already completed");
        }

        booking.setBookingStatus(BookingStatus.COMPLETED);
        if (booking.getPaymentStatus() == PaymentStatus.PENDING) {
            booking.setPaymentStatus(PaymentStatus.PAID);
        }

        // Award loyalty points: ₹10 = 1 point
        User user = booking.getUser();
        int pointsToAward = booking.getFinalAmount().divide(BigDecimal.valueOf(10), 0, java.math.RoundingMode.DOWN).intValue();
        if (pointsToAward > 0) {
            user.setLoyaltyPoints((user.getLoyaltyPoints() != null ? user.getLoyaltyPoints() : 0) + pointsToAward);
            userRepository.save(user);
        }

        Booking saved = bookingRepository.save(booking);

        // Trigger real-time settlement calculation for the booking's owner.
        // This allows the settlement ledger to stay current rather than waiting
        // for the next monthly @Scheduled run.
        try {
            LocalDate today = LocalDate.now();
            settlementService.generateSettlementForOwner(
                    booking.getTurf().getOwner(),
                    today.withDayOfMonth(1),
                    today);
        } catch (Exception ex) {
            // Non-fatal: log and continue — booking is already saved
            System.err.println("[BookingService] Settlement trigger failed for booking " + saved.getId() + ": " + ex.getMessage());
        }

        return mapToDto(saved);
    }

    // ─── Cancel ──────────────────────────────────────────────────────────────

    @Transactional
    public BookingDto cancelBooking(UUID bookingId, UUID userId, BookingCancellationRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        validateCancellationPermission(booking, userId);
        validateCancellationEligibility(booking);

        BigDecimal refundAmount = calculateRefundAmount(booking);

        if (request.getRequestRefund() && refundAmount.compareTo(BigDecimal.ZERO) > 0) {
            processRefund(booking, refundAmount, request.getRefundMethod());
        }

        booking.setBookingStatus(BookingStatus.CANCELLED);
        booking.setCancellationReason(request.getReason());
        booking.setCancellationTime(LocalDateTime.now());
        booking.setRefundAmount(refundAmount);
        booking.setRefundMethod(request.getRefundMethod());

        return mapToDto(bookingRepository.save(booking));
    }

    public Map<String, Object> getCancellationPolicy(UUID bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        Map<String, Object> policy = new HashMap<>();
        policy.put("bookingId", bookingId);
        policy.put("bookingDate", booking.getBookingDate());
        policy.put("bookingTime", booking.getStartTime());
        policy.put("totalAmount", booking.getFinalAmount());
        policy.put("cancellationDeadline", calculateCancellationDeadline(booking));
        policy.put("refundPolicy", getRefundPolicy());
        policy.put("isCancellable", isCancellable(booking));
        policy.put("estimatedRefund", calculateRefundAmount(booking));
        return policy;
    }

    @Transactional
    public void requestCancellation(UUID bookingId, UUID userId, BookingCancellationRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        validateCancellationPermission(booking, userId);
        booking.setBookingStatus(BookingStatus.CANCELLATION_REQUESTED);
        booking.setCancellationReason(request.getReason());
        booking.setCancellationTime(LocalDateTime.now());
        bookingRepository.save(booking);
    }

    // ─── Reschedule ───────────────────────────────────────────────────────────

    @Transactional
    public BookingDto rescheduleBooking(UUID userId, BookingRescheduleRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", request.getBookingId()));

        validateReschedulePermission(booking, userId);
        validateRescheduleEligibility(booking);
        validateNewSlotAvailability(booking, request);

        BigDecimal priceDifference = calculatePriceDifference(booking, request);

        LocalDateTime oldDateTime = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        booking.setBookingDate(request.getNewDate());
        booking.setStartTime(request.getNewStartTime());
        booking.setEndTime(request.getNewEndTime());
        booking.setRescheduledAt(LocalDateTime.now());
        booking.setRescheduleReason(request.getReason());
        booking.setRescheduleNotes(request.getNotes());
        booking.setOldDateTime(oldDateTime);

        if (priceDifference.compareTo(BigDecimal.ZERO) > 0) {
            booking.setAdditionalAmount(priceDifference);
            booking.setFinalAmount(booking.getFinalAmount().add(priceDifference));
        } else if (priceDifference.compareTo(BigDecimal.ZERO) < 0) {
            BigDecimal refundAmount = priceDifference.abs();
            processRefund(booking, refundAmount, "WALLET");
            booking.setRefundAmount(refundAmount);
        }

        return mapToDto(bookingRepository.save(booking));
    }

    // ─── Owner analytics/stats ────────────────────────────────────────────────

    public Map<String, Object> getOwnerStats(UUID userId) {
        TurfOwner owner = turfOwnerRepository.findByUserId(userId).orElse(null);
        if (owner == null) return Map.of("todayRevenue", BigDecimal.ZERO,
                "weeklyRevenue", BigDecimal.ZERO, "occupancyRate", 0, "pendingSettlements", 0);

        List<Booking> ownerBookings = bookingRepository.findAllByTurfOwnerId(owner.getId());
        BigDecimal todayRevenue = BigDecimal.ZERO;
        BigDecimal weeklyRevenue = BigDecimal.ZERO;
        int pendingSettlements = 0;
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(7);

        for (Booking b : ownerBookings) {
            if (b.getBookingStatus() == BookingStatus.CONFIRMED
                    || b.getBookingStatus() == BookingStatus.COMPLETED) {
                if (b.getBookingDate().isEqual(today))
                    todayRevenue = todayRevenue.add(nvl(b.getFinalAmount()));
                if (!b.getBookingDate().isBefore(weekAgo) && !b.getBookingDate().isAfter(today))
                    weeklyRevenue = weeklyRevenue.add(nvl(b.getFinalAmount()));
            }
            if (b.getPaymentStatus() == PaymentStatus.PENDING
                    || b.getPaymentStatus() == PaymentStatus.PARTIAL)
                pendingSettlements++;
        }

        // Calculate a realistic dynamic occupancy rate (last 7 days)
        long turfsCount = turfListingRepository.findByOwnerId(owner.getId()).size();
        long availableSlotsLastWeek = Math.max(1, turfsCount * 14 * 7); // ~14 hours per day per turf
        long recentBookings = ownerBookings.stream()
                .filter(b -> (b.getBookingStatus() == BookingStatus.CONFIRMED || b.getBookingStatus() == BookingStatus.COMPLETED))
                .filter(b -> !b.getBookingDate().isBefore(weekAgo) && !b.getBookingDate().isAfter(today))
                .count();
        int occupancyRate = (int) Math.min(100, (recentBookings * 100) / availableSlotsLastWeek);

        return Map.of("todayRevenue", todayRevenue, "weeklyRevenue", weeklyRevenue,
                "occupancyRate", occupancyRate, "pendingSettlements", pendingSettlements);
    }

    public Map<String, Object> getOwnerAnalytics(UUID userId) {
        TurfOwner owner = turfOwnerRepository.findByUserId(userId).orElse(null);
        if (owner == null) return Map.of("heatmap", List.of(), "topSlots", List.of(),
                "popularSports", List.of(), "totalBookings", 0, "totalRevenue", BigDecimal.ZERO);

        List<Booking> ownerBookings = bookingRepository.findAllByTurfOwnerId(owner.getId())
                .stream()
                .filter(b -> b.getBookingStatus() != BookingStatus.CANCELLED)
                .collect(java.util.stream.Collectors.toList());
        LocalDate today = LocalDate.now();

        // 7-day heatmap
        java.util.Map<String, Object> heatmapByDay = new java.util.LinkedHashMap<>();
        String[] dayLabels = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            String label = dayLabels[d.getDayOfWeek().getValue() - 1];
            long count = ownerBookings.stream().filter(b -> b.getBookingDate() != null && b.getBookingDate().isEqual(d)).count();
            BigDecimal rev = ownerBookings.stream()
                    .filter(b -> b.getBookingDate() != null && b.getBookingDate().isEqual(d) && b.getFinalAmount() != null)
                    .map(Booking::getFinalAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
            heatmapByDay.put(label, Map.of("label", label, "bookings", count, "revenue", rev));
        }

        // Top slots by volume
        java.util.Map<Integer, Long> slotCounts = new TreeMap<>();
        ownerBookings.forEach(b -> { if (b.getStartTime() != null) slotCounts.merge(b.getStartTime().getHour(), 1L, Long::sum); });
        List<Map<String, Object>> topSlots = slotCounts.entrySet().stream()
                .sorted(java.util.Map.Entry.<Integer, Long>comparingByValue().reversed()).limit(5)
                .map(e -> Map.<String, Object>of("slot", String.format("%02d:00 - %02d:00", e.getKey(), e.getKey() + 1), "bookings", e.getValue()))
                .collect(java.util.stream.Collectors.toList());

        // Popular sports
        java.util.Map<String, Long> sportCount = new java.util.LinkedHashMap<>();
        ownerBookings.forEach(b -> { if (b.getTurf() != null && b.getTurf().getSportType() != null)
            sportCount.merge(b.getTurf().getSportType().name(), 1L, Long::sum); });
        List<Map<String, Object>> popularSports = sportCount.entrySet().stream()
                .sorted(java.util.Map.Entry.<String, Long>comparingByValue().reversed())
                .map(e -> Map.<String, Object>of("sport", e.getKey(), "bookings", e.getValue()))
                .collect(java.util.stream.Collectors.toList());

        BigDecimal totalRevenue = ownerBookings.stream().filter(b -> b.getFinalAmount() != null)
                .map(Booking::getFinalAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        java.util.Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("heatmap", new java.util.ArrayList<>(heatmapByDay.values()));
        result.put("topSlots", topSlots);
        result.put("popularSports", popularSports);
        result.put("totalBookings", ownerBookings.size());
        result.put("totalRevenue", totalRevenue);
        return result;
    }

    // ─── Private helpers ──────────────────────────────────────────────────────

    private void validateCancellationPermission(Booking booking, UUID userId) {
        if (booking.getUser().getId().equals(userId)) return;
        if (booking.getTurf().getOwner().getUser().getId().equals(userId)) return;
        throw new InvalidRequestException("You don't have permission to cancel this booking");
    }

    private void validateCancellationEligibility(Booking booking) {
        if (booking.getBookingStatus() == BookingStatus.CANCELLED)
            throw new InvalidRequestException("Booking is already cancelled");
        if (booking.getBookingStatus() == BookingStatus.CANCELLATION_REQUESTED)
            throw new InvalidRequestException("Cancellation request already submitted");
        if (booking.getBookingStatus() == BookingStatus.COMPLETED)
            throw new InvalidRequestException("Cannot cancel a completed booking");

        LocalDateTime bookingDT = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        if (Duration.between(LocalDateTime.now(), bookingDT).toHours() < 2)
            throw new InvalidRequestException("Cannot cancel less than 2 hours before start time");
    }

    private BigDecimal calculateRefundAmount(Booking booking) {
        LocalDateTime bookingDT = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        long hours = Duration.between(LocalDateTime.now(), bookingDT).toHours();
        BigDecimal total = booking.getFinalAmount();
        if (hours >= 48) return total;
        if (hours >= 24) return total.multiply(BigDecimal.valueOf(0.5));
        if (hours >= 2)  return total.multiply(BigDecimal.valueOf(0.25));
        return BigDecimal.ZERO;
    }

    private LocalDateTime calculateCancellationDeadline(Booking booking) {
        return LocalDateTime.of(booking.getBookingDate(), booking.getStartTime()).minusHours(2);
    }

    private Map<String, Object> getRefundPolicy() {
        Map<String, Object> policy = new HashMap<>();
        policy.put("fullRefundHours", 48);
        policy.put("partialRefundHours", 24);
        policy.put("minimumRefundHours", 2);
        policy.put("fullRefundPercentage", 100);
        policy.put("partialRefundPercentage", 50);
        policy.put("minimumRefundPercentage", 25);
        return policy;
    }

    private boolean isCancellable(Booking booking) {
        if (booking.getBookingStatus() == BookingStatus.CANCELLED
                || booking.getBookingStatus() == BookingStatus.COMPLETED) return false;
        LocalDateTime bookingDT = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        return Duration.between(LocalDateTime.now(), bookingDT).toHours() >= 2;
    }

    private void processRefund(Booking booking, BigDecimal refundAmount, String refundMethod) {
        User user = booking.getUser();
        UserWallet wallet = userWalletRepository.findByUserId(user.getId())
                .orElseGet(() -> {
                    UserWallet w = UserWallet.builder().user(user).balance(BigDecimal.ZERO).build();
                    return userWalletRepository.save(w);
                });
        wallet.setBalance(wallet.getBalance().add(refundAmount));
        userWalletRepository.save(wallet);
        booking.setPaymentStatus(PaymentStatus.REFUNDED);
    }

    private void validateReschedulePermission(Booking booking, UUID userId) {
        if (booking.getUser().getId().equals(userId)) return;
        if (booking.getTurf().getOwner().getUser().getId().equals(userId)) return;
        throw new InvalidRequestException("You don't have permission to reschedule this booking");
    }

    private void validateRescheduleEligibility(Booking booking) {
        if (booking.getBookingStatus() == BookingStatus.CANCELLED)
            throw new InvalidRequestException("Cannot reschedule a cancelled booking");
        if (booking.getBookingStatus() == BookingStatus.COMPLETED)
            throw new InvalidRequestException("Cannot reschedule a completed booking");
        LocalDateTime bookingDT = LocalDateTime.of(booking.getBookingDate(), booking.getStartTime());
        if (Duration.between(LocalDateTime.now(), bookingDT).toHours() < 4)
            throw new InvalidRequestException("Cannot reschedule less than 4 hours before start time");
    }

    private void validateNewSlotAvailability(Booking booking, BookingRescheduleRequest request) {
        List<Booking> existing = bookingRepository.findByTurfIdAndBookingDateAndBookingStatusNot(
                booking.getTurf().getId(), request.getNewDate(), BookingStatus.CANCELLED);
        for (Booking e : existing) {
            if (!e.getId().equals(booking.getId())
                    && isOverlapping(request.getNewStartTime(), request.getNewEndTime(),
                                     e.getStartTime(), e.getEndTime())) {
                throw new InvalidRequestException("Requested time slot is already booked");
            }
        }
    }

    private boolean isOverlapping(LocalTime s1, LocalTime e1, LocalTime s2, LocalTime e2) {
        return s1.isBefore(e2) && s2.isBefore(e1);
    }

    private BigDecimal calculatePriceDifference(Booking booking, BookingRescheduleRequest request) {
        BigDecimal newPrice = calculateBookingPrice(booking.getTurf(),
                request.getNewDate(), request.getNewStartTime(), request.getNewEndTime());
        return newPrice.subtract(booking.getFinalAmount());
    }

    private BigDecimal calculateBookingPrice(TurfListing turf, LocalDate date,
                                             LocalTime startTime, LocalTime endTime) {
        List<DynamicPricingRule> rules = dynamicPricingRuleRepository.findByTurfIdAndIsActiveTrue(turf.getId());
        int dayOfWeek = date.getDayOfWeek().getValue();
        BigDecimal multiplier = BigDecimal.ONE;

        for (DynamicPricingRule rule : rules) {
            if ((rule.getDayOfWeek() == null || rule.getDayOfWeek() == dayOfWeek)
                    && rule.getStartTime().isBefore(endTime)
                    && startTime.isBefore(rule.getEndTime())) {
                if (rule.getMultiplier().compareTo(multiplier) > 0)
                    multiplier = rule.getMultiplier();
            }
        }

        double duration = java.time.Duration.between(startTime, endTime).toMinutes() / 60.0;
        return turf.getHourlyRate().multiply(multiplier).multiply(BigDecimal.valueOf(duration));
    }

    private BigDecimal nvl(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }

    private BookingDto mapToDto(Booking booking) {
        TurfListingDto turfDto = turfService.mapToDto(booking.getTurf());

        UserDto userDto = null;
        if (booking.getUser() != null) {
            userDto = UserDto.builder()
                    .userId(booking.getUser().getId().toString())
                    .email(booking.getUser().getEmail())
                    .phone(booking.getUser().getPhone())
                    .fullName(booking.getUser().getFullName())
                    .role(booking.getUser().getRole())
                    .build();
        }

        return BookingDto.builder()
                .bookingId(booking.getId().toString())
                .userId(booking.getUser().getId())
                .turfId(booking.getTurf().getId())
                .turfName(booking.getTurf().getName())
                .bookingDate(booking.getBookingDate())
                .startTime(booking.getStartTime())
                .endTime(booking.getEndTime())
                .durationHours(booking.getDurationHours())
                .baseAmount(booking.getBaseAmount())
                .discountAmount(booking.getDiscountAmount())
                .finalAmount(booking.getFinalAmount())
                .advanceAmount(booking.getAdvanceAmount())
                .cashAmount(booking.getCashAmount())
                .refundAmount(booking.getRefundAmount())
                .paymentMethod(booking.getPaymentMethod())
                .paymentStatus(booking.getPaymentStatus())
                .bookingStatus(booking.getBookingStatus())
                .cancellationReason(booking.getCancellationReason())
                .cancellationTime(booking.getCancellationTime())
                .refundMethod(booking.getRefundMethod())
                .rescheduledAt(booking.getRescheduledAt())
                .rescheduleReason(booking.getRescheduleReason())
                .oldDateTime(booking.getOldDateTime())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .user(userDto)
                .turf(turfDto)
                .build();
    }

    private Pageable paged(int page, int limit) {
        return PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "bookingDate", "startTime"));
    }
}
