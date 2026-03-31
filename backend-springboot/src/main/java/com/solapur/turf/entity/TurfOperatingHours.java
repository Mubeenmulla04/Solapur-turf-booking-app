package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "turf_operating_hours", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"turf_id", "day_of_week"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TurfOperatingHours extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    @Column(name = "day_of_week", nullable = false, length = 10)
    private String dayOfWeek; // MONDAY, TUESDAY, ... SUNDAY

    @Column(name = "open_time", nullable = false)
    private LocalTime openTime;

    @Column(name = "close_time", nullable = false)
    private LocalTime closeTime;

    @Column(name = "is_closed", nullable = false)
    @Builder.Default
    private boolean isClosed = false; // true = closed on this day
}
