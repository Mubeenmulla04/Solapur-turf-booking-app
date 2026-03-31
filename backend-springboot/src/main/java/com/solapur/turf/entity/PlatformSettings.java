package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "platform_settings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlatformSettings extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    @Builder.Default
    private String platformName = "Solapur Turf";

    @Column(nullable = false)
    @Builder.Default
    private BigDecimal platformFeePercentage = BigDecimal.valueOf(10.0);

    @Column(nullable = false)
    @Builder.Default
    private Integer minimumCancellationHours = 2;

    @Column(nullable = false)
    @Builder.Default
    private Integer maximumAdvanceBookingDays = 30;

    @Column(nullable = false)
    @Builder.Default
    private String supportEmail = "support@solapurturf.com";

    @Column(nullable = false)
    @Builder.Default
    private String supportContact = "+91 9876543210";

    @Column(name = "is_maintenance_mode", nullable = false)
    @Builder.Default
    private boolean isMaintenanceMode = false;
}
