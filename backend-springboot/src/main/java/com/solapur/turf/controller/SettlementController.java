package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.SettlementDto;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.exception.ResourceNotFoundException;
import com.solapur.turf.repository.TurfOwnerRepository;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.SettlementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/settlement")
@RequiredArgsConstructor
public class SettlementController {

    private final SettlementService settlementService;
    private final TurfOwnerRepository turfOwnerRepository;

    /** Admin: view all pending settlements for processing */
    @GetMapping("/pending")
    public ResponseEntity<ApiResponse<List<SettlementDto>>> getPendingSettlements() {
        List<SettlementDto> settlements = settlementService.getPendingSettlements();
        return ResponseEntity.ok(ApiResponse.success(settlements, "Pending settlements fetched successfully"));
    }

    /** Owner: view their own payout history — resolved from JWT principal */
    @GetMapping("/owner")
    public ResponseEntity<ApiResponse<List<SettlementDto>>> getOwnerSettlements(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        java.util.Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(userDetails.getUser().getId());

        if (ownerOpt.isEmpty()) {
            return ResponseEntity
                    .ok(ApiResponse.success(java.util.Collections.emptyList(), "No TurfOwner profile found"));
        }

        List<SettlementDto> settlements = settlementService.getOwnerSettlements(ownerOpt.get().getId());
        return ResponseEntity.ok(ApiResponse.success(settlements, "Owner settlements fetched successfully"));
    }

    /** Admin: mark a pending settlement as processed */
    @PostMapping("/{id}/mark-processed")
    public ResponseEntity<ApiResponse<Object>> markAsProcessed(
            @PathVariable UUID id,
            @RequestBody Map<String, String> data) {

        settlementService.markAsProcessed(id, data);
        return ResponseEntity.ok(ApiResponse.success(null, "Settlement marked as processed successfully"));
    }
}
