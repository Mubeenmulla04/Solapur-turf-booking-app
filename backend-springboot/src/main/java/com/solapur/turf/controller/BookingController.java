package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.BookingCancellationRequest;
import com.solapur.turf.dto.BookingDto;
import com.solapur.turf.dto.BookingRescheduleRequest;
import com.solapur.turf.dto.CreateBookingRequest;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    // ─── Create ───────────────────────────────────────────────────────────────
    /**
     * POST /api/bookings
     * Creates a new booking with double-booking prevention (pessimistic DB lock
     * + application-level interval check).
     */
    @PostMapping
    public ResponseEntity<ApiResponse<BookingDto>> createBooking(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateBookingRequest request) {
        BookingDto booking = bookingService.createBooking(userDetails.getUser().getId(), request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(booking, "Booking created successfully"));
    }

    // ─── Fetch by ID ──────────────────────────────────────────────────────────
    /**
     * GET /api/bookings/{id}
     * Fetches a single booking; accessible only by the booking's user or the turf owner.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<BookingDto>> getBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        BookingDto dto = bookingService.getBookingById(id, userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(dto, "Booking fetched successfully"));
    }

    // ─── My bookings ─────────────────────────────────────────────────────────
    /** GET /api/bookings/my-bookings */
    @GetMapping("/my-bookings")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getMyBookings(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "10") int limit) {
        PageResponse<BookingDto> bookings =
                bookingService.getUserBookings(userDetails.getUser().getId(), page, limit);
        return ResponseEntity.ok(ApiResponse.success(bookings, "Bookings fetched successfully"));
    }

    // ─── All bookings (admin) ─────────────────────────────────────────────────
    /** GET /api/bookings */
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getAllBookings(
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "10") int limit) {
        PageResponse<BookingDto> bookings = bookingService.getAllBookings(page, limit);
        return ResponseEntity.ok(ApiResponse.success(bookings, "All bookings fetched successfully"));
    }

    // ─── Owner views ──────────────────────────────────────────────────────────
    /** GET /api/bookings/owner-bookings */
    @GetMapping("/owner-bookings")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getOwnerBookings(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "1")  int page,
            @RequestParam(defaultValue = "50") int limit) {
        PageResponse<BookingDto> bookings =
                bookingService.getOwnerBookings(userDetails.getUser().getId(), page, limit);
        return ResponseEntity.ok(ApiResponse.success(bookings, "Owner bookings fetched successfully"));
    }

    /** GET /api/bookings/owner-stats */
    @GetMapping("/owner-stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getOwnerStats(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Map<String, Object> stats = bookingService.getOwnerStats(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(stats, "Owner stats fetched successfully"));
    }

    /** GET /api/bookings/owner-analytics */
    @GetMapping("/owner-analytics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getOwnerAnalytics(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Map<String, Object> analytics = bookingService.getOwnerAnalytics(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(analytics, "Owner analytics fetched successfully"));
    }

    // ─── Owner actions ────────────────────────────────────────────────────────
    /**
     * PATCH /api/bookings/{id}/confirm
     * Owner manually confirms a PENDING booking (e.g. after offline payment).
     */
    @PatchMapping("/{id}/confirm")
    public ResponseEntity<ApiResponse<BookingDto>> confirmBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        BookingDto dto = bookingService.confirmBooking(id, userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(dto, "Booking confirmed successfully"));
    }

    /**
     * PATCH /api/bookings/{id}/complete
     * Owner marks an active booking as completed after the session ends.
     */
    @PatchMapping("/{id}/complete")
    public ResponseEntity<ApiResponse<BookingDto>> completeBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        BookingDto dto = bookingService.completeBooking(id, userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(dto, "Booking marked as completed"));
    }

    // ─── Cancel & Reschedule ─────────────────────────────────────────────────
    /** PATCH /api/bookings/{id}/cancel */
    @PatchMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<BookingDto>> cancelBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody BookingCancellationRequest request) {
        BookingDto updated = bookingService.cancelBooking(id, userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(updated, "Booking cancelled successfully"));
    }

    /** GET /api/bookings/{id}/cancellation-policy */
    @GetMapping("/{id}/cancellation-policy")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCancellationPolicy(
            @PathVariable UUID id) {
        Map<String, Object> policy = bookingService.getCancellationPolicy(id);
        return ResponseEntity.ok(ApiResponse.success(policy, "Cancellation policy retrieved"));
    }

    /** POST /api/bookings/{id}/request-cancellation */
    @PostMapping("/{id}/request-cancellation")
    public ResponseEntity<ApiResponse<Object>> requestCancellation(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody BookingCancellationRequest request) {
        bookingService.requestCancellation(id, userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(null, "Cancellation request submitted"));
    }

    /** PATCH /api/bookings/{id}/reschedule */
    @PatchMapping("/{id}/reschedule")
    public ResponseEntity<ApiResponse<BookingDto>> rescheduleBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody BookingRescheduleRequest request) {
        request.setBookingId(id);
        BookingDto rescheduled = bookingService.rescheduleBooking(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(rescheduled, "Booking rescheduled successfully"));
    }
}
