package com.solapur.turf.dto;

import lombok.Data;

@Data
public class PaymentFailureRequest {
    private String razorpayOrderId;
    private String razorpayPaymentId;
    private String errorCode;
    private String errorDescription;
}
