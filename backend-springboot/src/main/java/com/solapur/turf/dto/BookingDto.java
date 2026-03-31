package com.solapur.turf.dto;

import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.PaymentMethod;
import com.solapur.turf.enums.PaymentStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Data
@Builder
public class BookingDto {
    private String        bookingId;
    private UUID          userId;
    private UUID          turfId;
    private String        turfName;           // convenience shortcut for Flutter

    private LocalDate     bookingDate;
    private LocalTime     startTime;
    private LocalTime     endTime;
    private BigDecimal    durationHours;

    private BigDecimal    baseAmount;
    private BigDecimal    discountAmount;
    private BigDecimal    finalAmount;
    private BigDecimal    advanceAmount;
    private BigDecimal    cashAmount;
    private BigDecimal    refundAmount;

    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private BookingStatus bookingStatus;

    // Cancellation details
    private String        cancellationReason;
    private LocalDateTime cancellationTime;
    private String        refundMethod;
    private String        razorpayOrderId; // For payment gateway

    // Reschedule details
    private LocalDateTime rescheduledAt;
    private String        rescheduleReason;
    private LocalDateTime oldDateTime;

    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private TurfListingDto turf;              // full nested DTO for rich UI displays
}
