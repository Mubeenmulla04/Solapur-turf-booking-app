package com.solapur.turf.entity;

import com.solapur.turf.enums.SettlementStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "settlements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Settlement extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private TurfOwner owner;

    @Column(name = "period_start", nullable = false)
    private LocalDate periodStart;

    @Column(name = "period_end", nullable = false)
    private LocalDate periodEnd;

    @Column(name = "total_bookings")
    private Integer totalBookings;

    @Column(name = "total_revenue", precision = 10, scale = 2)
    private BigDecimal totalRevenue;

    @Column(name = "platform_commission", precision = 10, scale = 2)
    private BigDecimal platformCommission;

    @Column(name = "settlement_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal settlementAmount;

    @Column(name = "commission_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal commissionAmount;

    @Column(name = "transaction_fee", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal transactionFee = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private SettlementStatus status = SettlementStatus.PENDING;

    @Column(name = "bank_reference")
    private String bankReference;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "generated_at")
    private LocalDateTime generatedAt;

    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;
}
