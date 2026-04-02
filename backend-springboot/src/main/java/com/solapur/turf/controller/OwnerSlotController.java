package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.AvailabilitySlot;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.AvailabilitySlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;
import com.solapur.turf.dto.AvailabilitySlotDto;
import com.solapur.turf.service.SlotService;

@RestController
@RequestMapping("/api/owner/slots")
@RequiredArgsConstructor
public class OwnerSlotController {

    private final AvailabilitySlotService availabilitySlotService;
    private final SlotService slotService;

    @Data
    public static class SlotActionRequest {
        private UUID turfId;
        private LocalDate date;
        private LocalTime startTime;
        private LocalTime endTime;
    }

    /**
     * Allows a turf owner to toggle the status of a specific slot (AVAILABLE <-> BLOCKED).
     */
    @PostMapping("/toggle-block")
    public ResponseEntity<ApiResponse<AvailabilitySlot>> toggleSlotBlock(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody SlotActionRequest request) {
        
        AvailabilitySlot updatedSlot = availabilitySlotService.toggleSlotBlock(
                userDetails.getUser().getId(),
                request.getTurfId(),
                request.getDate(),
                request.getStartTime(),
                request.getEndTime()
        );
        String message = updatedSlot.getStatus().name().equals("BLOCKED") 
                ? "Slot successfully blocked" 
                : "Slot successfully opened";
        
        return ResponseEntity.ok(ApiResponse.success(updatedSlot, message));
    }

    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<AvailabilitySlotDto>>> getAllSlots(
            @RequestParam UUID turfId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        
        // TODO: verify ownership in a real scenario
        List<AvailabilitySlotDto> slots = slotService.getAllSlots(turfId, date);
        return ResponseEntity.ok(ApiResponse.success(slots, "All slots fetched successfully"));
    }
}
