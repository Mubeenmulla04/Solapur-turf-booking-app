package com.solapur.turf.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PaymentOrderResponse {
    private String id; // Razorpay Order ID
    private String currency;
    private int amount; // Internal amount in integer (paise)
    private String status;
}
