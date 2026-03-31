package com.solapur.turf.dto;

import lombok.Data;

@Data
public class PaymentVerificationRequest {
    private String razorpayOrderId;
    private String razorpayPaymentId;
    private String razorpaySignature;
    private String transactionId; // our DB custom Tx ID
}
