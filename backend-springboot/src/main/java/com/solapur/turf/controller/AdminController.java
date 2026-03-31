package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.AuditLog;
import com.solapur.turf.entity.PlatformSettings;
import com.solapur.turf.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
public class AdminController {

    private final AdminService adminService;

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
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.broadcastNotification(body.get("title"), body.get("message"), body.get("audience")),
                "Broadcast queued successfully"));
    }

    // ── Platform Settings ─────────────────────────────────────────────────────
    @GetMapping("/settings")
    public ResponseEntity<ApiResponse<PlatformSettings>> getSettings() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getSettings(), "Settings retrieved"));
    }

    @PutMapping("/settings")
    public ResponseEntity<ApiResponse<PlatformSettings>> updateSettings(
            @RequestBody PlatformSettings settings) {
        return ResponseEntity.ok(ApiResponse.success(adminService.updateSettings(settings), "Settings updated"));
    }

    // ── Audit Log ─────────────────────────────────────────────────────────────
    @GetMapping("/audit-log")
    public ResponseEntity<ApiResponse<List<AuditLog>>> getAuditLog() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAuditLog(), "Audit log retrieved"));
    }

    // ── Turf Management ───────────────────────────────────────────────────────
    @GetMapping("/turfs")
    public ResponseEntity<ApiResponse<List<com.solapur.turf.entity.TurfListing>>> getAllTurfs() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAllTurfs(), "All turfs retrieved"));
    }

    @PutMapping("/turfs/{turfId}/status")
    public ResponseEntity<ApiResponse<com.solapur.turf.entity.TurfListing>> toggleTurfStatus(
            @PathVariable UUID turfId,
            @RequestParam boolean isActive) {
        return ResponseEntity.ok(ApiResponse.success(adminService.toggleTurfStatus(turfId, isActive), "Turf status updated"));
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
            @RequestBody(required = false) Map<String, String> body) {
        String reason = body != null ? body.getOrDefault("reason", "Application rejected") : "Application rejected";
        return ResponseEntity.ok(ApiResponse.success(adminService.rejectOwner(ownerId, reason), "Owner rejected"));
    }
}
