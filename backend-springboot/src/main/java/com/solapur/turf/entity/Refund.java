package com.solapur.turf.entity;

import com.solapur.turf.enums.RefundStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "refunds")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Refund extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "original_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal originalAmount;

    @Column(name = "requested_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal requestedAmount;

    @Column(name = "approved_amount", precision = 10, scale = 2)
    private BigDecimal approvedAmount;

    @Column(name = "refund_method")
    private String refundMethod; // "WALLET", "BANK", "ORIGINAL_PAYMENT"

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private RefundStatus status = RefundStatus.REQUESTED;

    @Column(name = "reason", columnDefinition = "TEXT")
    private String reason;

    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;

    @Column(name = "requested_at", nullable = false)
    private LocalDateTime requestedAt;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "processed_by")
    private String processedBy;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "transaction_id")
    private String transactionId;

    @PrePersist
    public void setRequestedAt() {
        if (this.requestedAt == null) {
            this.requestedAt = LocalDateTime.now();
        }
    }
}
