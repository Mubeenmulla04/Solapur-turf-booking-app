package com.solapur.turf.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PaymentRefundRequest {
    private String transactionId; // Reference to the Razorpay Payment ID or Transaction ID
    private BigDecimal amount;
    private String reason;
}
