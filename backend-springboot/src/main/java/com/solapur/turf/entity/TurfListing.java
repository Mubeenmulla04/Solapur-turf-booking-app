package com.solapur.turf.entity;

import com.solapur.turf.enums.SportType;
import com.solapur.turf.enums.SurfaceType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "turf_listings", indexes = {
        @Index(name = "idx_turf_city_active", columnList = "city, is_active, is_verified"),
        @Index(name = "idx_turf_sport", columnList = "sport_type, is_active")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TurfListing extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private TurfOwner owner;

    @Column(nullable = false)
    private String name;

    @Column(length = 2000)
    private String description;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String state;

    @Column(name = "pin_code", nullable = false)
    private String pinCode;

    // PostGIS or simple lat/lng caching; using decimal for now
    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    // Use Postgres Point if needed later, storing as standard coordinates
    // point(longitude, latitude)

    @Enumerated(EnumType.STRING)
    @Column(name = "sport_type", nullable = false)
    private SportType sportType;

    @Enumerated(EnumType.STRING)
    @Column(name = "surface_type", nullable = false)
    private SurfaceType surfaceType;

    @Column(name = "pitch_size")
    private String pitchSize; // e.g., "5v5", "7v7"

    @Column(name = "is_indoor")
    @Builder.Default
    private boolean isIndoor = false;

    @Column(name = "hourly_rate", nullable = false, precision = 10, scale = 2)
    private BigDecimal hourlyRate;

    @Column(name = "peak_hour_rate", precision = 10, scale = 2)
    private BigDecimal peakHourRate;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "peak_hours", columnDefinition = "jsonb")
    private List<String> peakHours; // e.g., ["18:00-22:00"]

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<String> amenities;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "image_urls", columnDefinition = "jsonb")
    @Builder.Default
    private List<String> imageUrls = new java.util.ArrayList<>();

    @Column(columnDefinition = "text")
    private String rules;

    @Column(name = "rating_average", precision = 3, scale = 2)
    @Builder.Default
    private BigDecimal ratingAverage = BigDecimal.ZERO;

    @Column(name = "review_count")
    @Builder.Default
    private int reviewCount = 0;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean isActive = true;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private boolean isVerified = false;

    @Column(name = "opening_time")
    @Builder.Default
    private LocalTime openingTime = LocalTime.of(6, 0);

    @Column(name = "closing_time")
    @Builder.Default
    private LocalTime closingTime = LocalTime.of(23, 0);
}
