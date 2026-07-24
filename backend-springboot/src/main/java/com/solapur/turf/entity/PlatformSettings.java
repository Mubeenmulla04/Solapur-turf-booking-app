package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("platformName")
    private String platformName = "Solapur Turf";

    @Column(nullable = false)
    @Builder.Default
    @JsonProperty("commissionPercent")
    private BigDecimal platformFeePercentage = BigDecimal.valueOf(10.0);

    @Column(nullable = false)
    @Builder.Default
    @JsonProperty("partialAdvanceAmount")
    private BigDecimal partialAdvanceAmount = BigDecimal.valueOf(50.0);

    @Column(nullable = false)
    @Builder.Default
    private Integer minimumCancellationHours = 2;

    @Column(nullable = false)
    @Builder.Default
    private Integer maximumAdvanceBookingDays = 30;

    @Column(name = "max_bookings_per_user", nullable = false, columnDefinition = "integer default 5")
    @Builder.Default
    @JsonProperty("maxBookingsPerUser")
    private Integer maxBookingsPerUser = 5;

    @Column(nullable = false)
    @Builder.Default
    @JsonProperty("supportEmail")
    private String supportEmail = "support@solapurturf.com";

    @Column(nullable = false)
    @Builder.Default
    @JsonProperty("supportContact")
    private String supportContact = "+91 9876543210";

    @Column(name = "is_maintenance_mode", nullable = false)
    @Builder.Default
    @JsonProperty("maintenanceMode")
    private boolean isMaintenanceMode = false;
}
