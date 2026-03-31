package com.solapur.turf.dto;

import com.solapur.turf.enums.RefundStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class RefundDto {
    private UUID id;
    private UUID bookingId;
    private UUID userId;
    private String bookingReference;
    private String userName;
    private String turfName;
    private BigDecimal originalAmount;
    private BigDecimal requestedAmount;
    private BigDecimal approvedAmount;
    private String refundMethod;
    private RefundStatus status;
    private String reason;
    private String rejectionReason;
    private LocalDateTime requestedAt;
    private LocalDateTime processedAt;
    private String processedBy;
    private String notes;
    private String transactionId;
}
