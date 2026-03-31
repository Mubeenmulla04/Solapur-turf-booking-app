package com.solapur.turf.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
public class PaymentOrderRequest {
    private BigDecimal amount;
    private String currency;
    private UUID bookingId; // Optional: If payment is for a booking
    private String transactionType; // e.g. BOOKING_PAYMENT, WALLET_TOPUP, etc.
}
