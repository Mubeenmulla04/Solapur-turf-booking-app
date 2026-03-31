package com.solapur.turf.entity;

import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.PaymentMethod;
import com.solapur.turf.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "bookings", uniqueConstraints = {
        @UniqueConstraint(name = "unique_slot", columnNames = { "turf_id", "booking_date", "start_time" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Booking extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    // Single slot simplified - or change to OneToMany for multiple slots
    @OneToOne
    @JoinColumn(name = "slot_id")
    private AvailabilitySlot slot;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    @Column(name = "booking_date", nullable = false)
    private LocalDate bookingDate;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Column(name = "duration_hours", nullable = false, precision = 4, scale = 2)
    private BigDecimal durationHours;

    @Column(name = "base_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal baseAmount;

    @Column(name = "peak_surcharge", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal peakSurcharge = BigDecimal.ZERO;

    @Column(name = "discount_amount", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "final_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal finalAmount;

    @Column(name = "platform_commission", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal platformCommission = BigDecimal.ZERO;

    @Column(name = "owner_share", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal ownerShare = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", nullable = false)
    private PaymentMethod paymentMethod;

    @Column(name = "advance_amount", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal advanceAmount = BigDecimal.ZERO;

    @Column(name = "cash_amount", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal cashAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false)
    @Builder.Default
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "booking_status", nullable = false)
    @Builder.Default
    private BookingStatus bookingStatus = BookingStatus.PENDING;

    @Column(name = "cancellation_reason")
    private String cancellationReason;

    @Column(name = "cancellation_time")
    private LocalDateTime cancellationTime;

    @Column(name = "refund_amount", precision = 10, scale = 2)
    private BigDecimal refundAmount;

    @Column(name = "refund_method")
    private String refundMethod;

    @Column(name = "old_date_time")
    private LocalDateTime oldDateTime;

    @Column(name = "rescheduled_at")
    private LocalDateTime rescheduledAt;

    @Column(name = "reschedule_reason")
    private String rescheduleReason;

    @Column(name = "reschedule_notes", columnDefinition = "TEXT")
    private String rescheduleNotes;

    @Column(name = "additional_amount", precision = 10, scale = 2)
    private BigDecimal additionalAmount;
}
