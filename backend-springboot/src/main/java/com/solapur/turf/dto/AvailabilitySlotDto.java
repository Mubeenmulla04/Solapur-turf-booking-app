package com.solapur.turf.dto;

import com.solapur.turf.enums.SlotStatus;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AvailabilitySlotDto {
    private UUID id;
    private UUID turfId;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private SlotStatus status;
    private java.math.BigDecimal price;
    private String turfName;
    private String turfAddress;
}
