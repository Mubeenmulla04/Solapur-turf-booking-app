package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Data
public class BookingRescheduleRequest {
    
    @NotNull(message = "Booking ID is required")
    private UUID bookingId;
    
    @NotNull(message = "New date is required")
    private LocalDate newDate;
    
    @NotNull(message = "New start time is required")
    private LocalTime newStartTime;
    
    @NotNull(message = "New end time is required")
    private LocalTime newEndTime;
    
    @NotBlank(message = "Reason is required")
    private String reason;
    
    private String notes;
}
