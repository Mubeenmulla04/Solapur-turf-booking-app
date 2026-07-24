package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.TurfListingDto;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.FileStorageService;
import com.solapur.turf.service.TurfService;
import com.solapur.turf.util.FileUploadValidator;
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
    private final FileUploadValidator fileUploadValidator;

    // ── Public read endpoints ─────────────────────────────────────────────────

    @GetMapping
    public ResponseEntity<ApiResponse<List<TurfListingDto>>> getAllTurfs(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String sportType,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam(required = false) Double userLat,
            @RequestParam(required = false) Double userLng) {
        
        List<TurfListingDto> turfs = turfService.getFilteredTurfs(city, sportType, search, minPrice, maxPrice, sortBy, page, limit, userLat, userLng);
        return ResponseEntity.ok(ApiResponse.success(turfs, "Turfs retrieved successfully"));
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
        
        // Validate ownership
        turfService.getTurfByIdAndOwnerId(id, userDetails.getUser().getId());

        // Max 10 images per upload request
        if (images.size() > 10) {
            throw new com.solapur.turf.exception.InvalidRequestException("Maximum 10 images allowed per upload");
        }

        List<String> imageUrls = new ArrayList<>();
        for (MultipartFile file : images) {
            // Validate each file before storing (magic byte check via Tika)
            fileUploadValidator.validateImageUpload(file);
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
