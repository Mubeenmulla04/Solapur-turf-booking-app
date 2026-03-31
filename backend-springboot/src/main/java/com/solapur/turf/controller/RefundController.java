package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.dto.RefundDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.RefundService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/refunds")
@RequiredArgsConstructor
public class RefundController {

    private final RefundService refundService;

    @GetMapping("/my-refunds")
    public ResponseEntity<ApiResponse<PageResponse<RefundDto>>> getMyRefunds(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) String status) {
        PageResponse<RefundDto> refunds = refundService.getUserRefunds(
                userDetails.getUser().getId(), page, limit, status);
        return ResponseEntity.ok(ApiResponse.success(refunds, "Your refunds retrieved successfully"));
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<ApiResponse<List<RefundDto>>> getRefundsByBooking(@PathVariable UUID bookingId) {
        List<RefundDto> refunds = refundService.getRefundsByBooking(bookingId);
        return ResponseEntity.ok(ApiResponse.success(refunds, "Refunds for booking retrieved successfully"));
    }

    @PostMapping("/request")
    public ResponseEntity<ApiResponse<RefundDto>> requestRefund(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody RefundRequest request) {
        RefundDto refund = refundService.requestRefund(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(refund, "Refund request submitted successfully"));
    }

    @PatchMapping("/{id}/process")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<RefundDto>> processRefund(
            @PathVariable UUID id,
            @Valid @RequestBody ProcessRefundRequest request) {
        RefundDto refund = refundService.processRefund(id, request);
        return ResponseEntity.ok(ApiResponse.success(refund, "Refund processed successfully"));
    }

    @PatchMapping("/{id}/cancel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<RefundDto>> cancelRefund(
            @PathVariable UUID id,
            @RequestBody CancelRefundRequest request) {
        RefundDto refund = refundService.cancelRefund(id, request.getReason());
        return ResponseEntity.ok(ApiResponse.success(refund, "Refund cancelled successfully"));
    }

    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<RefundDto>>> getAllRefunds(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        PageResponse<RefundDto> refunds = refundService.getAllRefunds(page, limit, status, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(refunds, "All refunds retrieved successfully"));
    }

    @GetMapping("/admin/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> getRefundStats() {
        Object stats = refundService.getRefundStats();
        return ResponseEntity.ok(ApiResponse.success(stats, "Refund statistics retrieved successfully"));
    }

    // Request DTOs
    public static class RefundRequest {
        private UUID bookingId;
        private String reason;
        private String refundMethod; // "WALLET", "BANK", "ORIGINAL_PAYMENT"
        private BigDecimal requestedAmount;

        // Getters and setters
        public UUID getBookingId() { return bookingId; }
        public void setBookingId(UUID bookingId) { this.bookingId = bookingId; }
        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
        public String getRefundMethod() { return refundMethod; }
        public void setRefundMethod(String refundMethod) { this.refundMethod = refundMethod; }
        public BigDecimal getRequestedAmount() { return requestedAmount; }
        public void setRequestedAmount(BigDecimal requestedAmount) { this.requestedAmount = requestedAmount; }
    }

    public static class ProcessRefundRequest {
        private String action; // "APPROVE", "REJECT"
        private String processedBy;
        private String notes;
        private BigDecimal approvedAmount;

        // Getters and setters
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        public String getProcessedBy() { return processedBy; }
        public void setProcessedBy(String processedBy) { this.processedBy = processedBy; }
        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
        public BigDecimal getApprovedAmount() { return approvedAmount; }
        public void setApprovedAmount(BigDecimal approvedAmount) { this.approvedAmount = approvedAmount; }
    }

    public static class CancelRefundRequest {
        private String reason;

        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
    }
}
