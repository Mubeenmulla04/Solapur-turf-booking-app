package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "dynamic_pricing_rules")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DynamicPricingRule extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Column(name = "day_of_week")
    private Integer dayOfWeek; // 1 (Mon) to 7 (Sun), null for all days

    @Column(nullable = false, precision = 4, scale = 2)
    @Builder.Default
    private BigDecimal multiplier = BigDecimal.ONE;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean isActive = true;

    private String description;
}
