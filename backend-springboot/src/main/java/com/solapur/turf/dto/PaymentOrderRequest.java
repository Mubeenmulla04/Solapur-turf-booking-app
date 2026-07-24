package com.solapur.turf.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
public class PaymentOrderRequest {

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "1.0", message = "Amount must be at least ₹1")
    private BigDecimal amount;

    @NotBlank(message = "Currency is required")
    @Pattern(regexp = "^(INR)$", message = "Only INR currency is supported")
    private String currency;

    private UUID bookingId; // Optional: If payment is for a booking

    @NotBlank(message = "Transaction type is required")
    @Pattern(regexp = "^(BOOKING_PAYMENT|WALLET_TOPUP|SUBSCRIPTION|TOURNAMENT_REGISTRATION)$",
             message = "Invalid transaction type")
    private String transactionType;
}
