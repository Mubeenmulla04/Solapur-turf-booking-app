package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.BroadcastNotificationRequest;
import com.solapur.turf.dto.RejectOwnerRequest;
import com.solapur.turf.entity.AuditLog;
import com.solapur.turf.entity.PlatformSettings;
import com.solapur.turf.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.solapur.turf.service.DatabaseBackupService;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Admin-only endpoints for platform stats, revenue analytics,
 * push-notification broadcast, platform settings, and owner approval.
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;
    private final com.solapur.turf.service.TurfService turfService;
    private final DatabaseBackupService backupService;

    // ── Platform Stats ────────────────────────────────────────────────────────

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPlatformStats() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getPlatformStats(), "Stats retrieved"));
    }

    // ── Revenue Analytics ─────────────────────────────────────────────────────
    @GetMapping("/revenue")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRevenueAnalytics() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getRevenueAnalytics(), "Revenue data retrieved"));
    }

    // ── Broadcast Notifications ───────────────────────────────────────────────
    @PostMapping("/notifications/broadcast")
    public ResponseEntity<ApiResponse<Map<String, Object>>> broadcastNotification(
            @Valid @RequestBody BroadcastNotificationRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.broadcastNotification(request.getTitle(), request.getMessage(), request.getAudience()),
                "Broadcast queued successfully"));
    }

    // ── Platform Settings ─────────────────────────────────────────────────────
    @GetMapping("/settings")
    public ResponseEntity<ApiResponse<PlatformSettings>> getSettings() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getSettings(), "Settings retrieved"));
    }

    @PutMapping("/settings")
    public ResponseEntity<ApiResponse<PlatformSettings>> updateSettings(
            @Valid @RequestBody PlatformSettings settings) {
        return ResponseEntity.ok(ApiResponse.success(adminService.updateSettings(settings), "Settings updated"));
    }

    // ── Audit Log ─────────────────────────────────────────────────────────────
    @GetMapping("/audit-log")
    public ResponseEntity<ApiResponse<List<AuditLog>>> getAuditLog() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAuditLog(), "Audit log retrieved"));
    }

    @PostMapping("/backups/trigger")
    public ResponseEntity<ApiResponse<String>> triggerBackup() {
        String result = backupService.runBackupFlow();
        if (result.contains("failed")) {
            return ResponseEntity.status(500).body(ApiResponse.error(result));
        }
        return ResponseEntity.ok(ApiResponse.success(result, "Backup completed"));
    }

    // ── Turf Management ───────────────────────────────────────────────────────
    @GetMapping("/turfs")
    public ResponseEntity<ApiResponse<List<com.solapur.turf.dto.TurfListingDto>>> getAllTurfs() {
        List<com.solapur.turf.dto.TurfListingDto> dtos = adminService.getAllTurfs()
            .stream().map(turfService::mapToDto).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtos, "All turfs retrieved"));
    }

    @PutMapping("/turfs/{turfId}/status")
    public ResponseEntity<ApiResponse<com.solapur.turf.dto.TurfListingDto>> toggleTurfStatus(
            @PathVariable UUID turfId,
            @RequestParam boolean isActive) {
        return ResponseEntity.ok(ApiResponse.success(turfService.mapToDto(adminService.toggleTurfStatus(turfId, isActive)), "Turf status updated"));
    }

    /**
     * Toggle Featured (Sponsored) status of a turf.
     *
     * This is a paid add-on (₹199/month) available to ALL owners — both TRIAL and ACTIVE.
     * The free trial does NOT include Featured status automatically.
     * Admin toggles this manually after verifying the owner has paid ₹199 for the add-on.
     *
     * Audit log records the owner's subscription status at the time of toggle.
     */
    @PutMapping("/turfs/{turfId}/featured")
    public ResponseEntity<ApiResponse<com.solapur.turf.dto.TurfListingDto>> toggleTurfFeatured(
            @PathVariable UUID turfId,
            @RequestParam boolean isFeatured) {
        return ResponseEntity.ok(ApiResponse.success(
                turfService.mapToDto(adminService.toggleTurfFeatured(turfId, isFeatured)),
                isFeatured ? "Turf marked as Featured (Sponsored)" : "Turf removed from Featured listings"));
    }

    // ── Owner Approval ────────────────────────────────────────────────────────

    /** Returns all OWNER accounts pending admin approval */
    @GetMapping("/owners/pending")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getPendingOwners() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getPendingOwners(), "Pending owners retrieved"));
    }

    /** Approve a turf owner — activates their account */
    @PutMapping("/owners/{ownerId}/approve")
    public ResponseEntity<ApiResponse<Map<String, Object>>> approveOwner(@PathVariable UUID ownerId) {
        return ResponseEntity.ok(ApiResponse.success(adminService.approveOwner(ownerId), "Owner approved successfully"));
    }

    /** Reject a turf owner registration */
    @PutMapping("/owners/{ownerId}/reject")
    public ResponseEntity<ApiResponse<Map<String, Object>>> rejectOwner(
            @PathVariable UUID ownerId,
            @Valid @RequestBody RejectOwnerRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.rejectOwner(ownerId, request.getReason()), "Owner rejected"));
    }
}
