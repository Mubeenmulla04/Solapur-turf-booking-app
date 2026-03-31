package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.TurfListingDto;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.FileStorageService;
import com.solapur.turf.service.TurfService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/turfs")
@RequiredArgsConstructor
public class TurfController {

    private final TurfService turfService;
    private final FileStorageService fileStorageService;

    // ── Public read endpoints ─────────────────────────────────────────────────

    @GetMapping
    public ResponseEntity<ApiResponse<List<TurfListingDto>>> getAllTurfs() {
        return ResponseEntity.ok(ApiResponse.success(turfService.getAllActiveTurfs(), "Turfs retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TurfListingDto>> getTurfById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(turfService.getTurfById(id), "Turf retrieved successfully"));
    }

    @GetMapping("/city/{city}")
    public ResponseEntity<ApiResponse<List<TurfListingDto>>> getTurfsByCity(@PathVariable String city) {
        return ResponseEntity.ok(ApiResponse.success(turfService.getTurfsByCity(city), "Turfs fetched correctly"));
    }

    @GetMapping("/sport/{sportType}")
    public ResponseEntity<ApiResponse<List<TurfListingDto>>> getTurfsBySport(@PathVariable SportType sportType) {
        return ResponseEntity.ok(ApiResponse.success(turfService.getTurfsBySport(sportType), "Fetched"));
    }

    @GetMapping("/count")
    public ResponseEntity<ApiResponse<Long>> countTurfs() {
        return ResponseEntity.ok(ApiResponse.success(turfService.countTurfs(), "Turf count retrieved successfully"));
    }

    @PostMapping("/{id}/images")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<List<String>>> uploadTurfImages(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam("images") List<MultipartFile> images) {
        
        // This validates owner and turf
        turfService.getTurfByIdAndOwnerId(id, userDetails.getUser().getId());

        List<String> imageUrls = new ArrayList<>();
        for (MultipartFile file : images) {
            String url = fileStorageService.storeFile(file, "turfs/" + id.toString());
            imageUrls.add(url);
        }

        // Save URLs to turf
        turfService.updateTurfImages(id, userDetails.getUser().getId(), imageUrls);

        return ResponseEntity.ok(ApiResponse.success(imageUrls, "Images uploaded successfully"));
    }

    // ── Owner endpoints ───────────────────────────────────────────────────────

    @GetMapping("/owner/my-turfs")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<List<TurfListingDto>>> getMyTurfs(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<TurfListingDto> turfs = turfService.getTurfsByOwnerId(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(turfs, "Your turfs retrieved successfully"));
    }

    @PostMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<TurfListingDto>> createTurf(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody TurfListingDto turfDto) {
        TurfListingDto created = turfService.createTurf(userDetails.getUser().getId(), turfDto);
        return ResponseEntity.ok(ApiResponse.success(created, "Turf created successfully"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<TurfListingDto>> updateTurf(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody TurfListingDto turfDto) {
        TurfListingDto updated = turfService.updateTurf(id, userDetails.getUser().getId(), turfDto);
        return ResponseEntity.ok(ApiResponse.success(updated, "Turf updated successfully"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<Object>> deleteTurf(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        turfService.deleteTurf(id, userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Turf deleted successfully"));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<TurfListingDto>> updateTurfStatus(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, Boolean> body) {
        boolean active = body.getOrDefault("isActive", true);
        TurfListingDto updated = turfService.updateTurfStatus(id, userDetails.getUser().getId(), active);
        return ResponseEntity.ok(ApiResponse.success(updated,
                active ? "Turf activated successfully" : "Turf deactivated successfully"));
    }
}
