package com.solapur.turf.controller;

import com.solapur.turf.dto.*;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/create-order")
    public ResponseEntity<PaymentOrderResponse> createOrder(@RequestBody PaymentOrderRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(paymentService.createOrder(request, userDetails.getUser().getId()));
    }

    @PostMapping("/verify")
    public ResponseEntity<Map<String, Boolean>> verifyPayment(@RequestBody PaymentVerificationRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        boolean isValid = paymentService.verifySignature(request, userDetails.getUser().getId());
        return ResponseEntity.ok(Collections.singletonMap("success", isValid));
    }

    @PostMapping("/failure")
    public ResponseEntity<Map<String, String>> handleFailure(@RequestBody PaymentFailureRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        paymentService.handlePaymentFailure(request, userDetails.getUser().getId());
        return ResponseEntity.ok(Collections.singletonMap("status", "Handled"));
    }

    @PostMapping("/refund")
    @PreAuthorize("hasRole('ADMIN') or hasRole('OWNER')")
    public ResponseEntity<Map<String, Boolean>> initiateRefund(@RequestBody PaymentRefundRequest request) {
        boolean success = paymentService.processRefund(request);
        return ResponseEntity.ok(Collections.singletonMap("success", success));
    }

    @PostMapping("/refund-booking/{bookingId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('OWNER')")
    public ResponseEntity<Map<String, Boolean>> initiateRefundByBooking(
            @PathVariable UUID bookingId, 
            @RequestBody PaymentRefundRequest request) {
        boolean success = paymentService.processRefundByBookingId(bookingId, request.getAmount(), request.getReason());
        return ResponseEntity.ok(Collections.singletonMap("success", success));
    }
}
