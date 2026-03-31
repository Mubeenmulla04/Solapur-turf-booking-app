package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.AvailabilitySlotDto;
import com.solapur.turf.service.SlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/slots")
@RequiredArgsConstructor
public class SlotController {

    private final SlotService slotService;

    @GetMapping("/available")
    public ResponseEntity<ApiResponse<List<AvailabilitySlotDto>>> getAvailableSlots(
            @RequestParam UUID turfId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        List<AvailabilitySlotDto> slots = slotService.getAvailableSlots(turfId, date);
        return ResponseEntity.ok(ApiResponse.success(slots, "Available slots fetched successfully"));
    }
}
