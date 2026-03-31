package com.solapur.turf.entity;

import com.solapur.turf.enums.SlotStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "availability_slots", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "turf_id", "date", "start_time" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AvailabilitySlot extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    @Column(nullable = false)
    private LocalDate date;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private SlotStatus status = SlotStatus.AVAILABLE;

    @Column(precision = 10, scale = 2)
    private java.math.BigDecimal price; // Override turf default if set

    // Optional relation mapped by Booking later
    // @OneToOne(mappedBy = "slot")
    // private Booking booking;
}
