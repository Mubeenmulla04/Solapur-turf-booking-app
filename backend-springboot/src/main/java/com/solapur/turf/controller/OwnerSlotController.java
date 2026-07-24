package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.AvailabilitySlotDto;
import com.solapur.turf.entity.AvailabilitySlot;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.AvailabilitySlotService;
import com.solapur.turf.service.SlotService;
import com.solapur.turf.util.AuthorizationUtil;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/owner/slots")
@RequiredArgsConstructor
@PreAuthorize("hasRole('OWNER')")
public class OwnerSlotController {

    private final AvailabilitySlotService availabilitySlotService;
    private final SlotService slotService;
    private final AuthorizationUtil authorizationUtil;

    @Data
    public static class SlotActionRequest {
        @NotNull(message = "Turf ID is required")
        private UUID turfId;

        @NotNull(message = "Date is required")
        private LocalDate date;

        @NotNull(message = "Start time is required")
        private LocalTime startTime;

        @NotNull(message = "End time is required")
        private LocalTime endTime;
    }

    /**
     * Allows a turf owner to toggle a specific slot (AVAILABLE <-> BLOCKED).
     * Ownership of the turf is verified before the operation.
     */
    @PostMapping("/toggle-block")
    public ResponseEntity<ApiResponse<AvailabilitySlot>> toggleSlotBlock(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody SlotActionRequest request) {

        // Verify the owner actually owns this turf before allowing slot management
        authorizationUtil.requireTurfOwnership(request.getTurfId(), userDetails.getUser().getId());

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

    /**
     * Returns all slots (all statuses) for a given turf and date.
     * Only the owning owner can view this.
     */
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<AvailabilitySlotDto>>> getAllSlots(
            @RequestParam UUID turfId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        // Ownership check replacing the previous TODO comment
        authorizationUtil.requireTurfOwnership(turfId, userDetails.getUser().getId());

        List<AvailabilitySlotDto> slots = slotService.getAllSlots(turfId, date);
        return ResponseEntity.ok(ApiResponse.success(slots, "All slots fetched successfully"));
    }
}
