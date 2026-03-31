package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.AuditLogDto;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/audit-logs")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminAuditLogController {

    private final AuditLogService auditLogService;

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<AuditLogDto>>> getAuditLogs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<AuditLogDto> auditLogs = auditLogService.getAuditLogs(page, limit);
        return ResponseEntity.ok(ApiResponse.success(auditLogs, "Audit logs fetched successfully"));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<PageResponse<AuditLogDto>>> getAuditLogsByUser(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<AuditLogDto> auditLogs = auditLogService.getAuditLogsByUser(userId, page, limit);
        return ResponseEntity.ok(ApiResponse.success(auditLogs, "Audit logs for user fetched successfully"));
    }

    @GetMapping("/action/{action}")
    public ResponseEntity<ApiResponse<PageResponse<AuditLogDto>>> getAuditLogsByAction(
            @PathVariable String action,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<AuditLogDto> auditLogs = auditLogService.getAuditLogsByAction(action, page, limit);
        return ResponseEntity.ok(ApiResponse.success(auditLogs, "Audit logs for action fetched successfully"));
    }

    @GetMapping("/date-range")
    public ResponseEntity<ApiResponse<PageResponse<AuditLogDto>>> getAuditLogsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {
        PageResponse<AuditLogDto> auditLogs = auditLogService.getAuditLogsByDateRange(startDate, endDate, page, limit);
        return ResponseEntity.ok(ApiResponse.success(auditLogs, "Audit logs for date range fetched successfully"));
    }

    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<AuditLogDto>>> getRecentAuditLogs(
            @RequestParam(defaultValue = "50") int limit) {
        List<AuditLogDto> auditLogs = auditLogService.getRecentAuditLogs(limit);
        return ResponseEntity.ok(ApiResponse.success(auditLogs, "Recent audit logs fetched successfully"));
    }

    @PostMapping("/log")
    public ResponseEntity<ApiResponse<Object>> logAction(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody LogActionRequest request) {
        auditLogService.logAction(
                userDetails.getUser().getId(),
                userDetails.getUser().getEmail(),
                userDetails.getUser().getRole().name(),
                request.getAction(),
                request.getEntityType(),
                request.getEntityId(),
                request.getOldValues(),
                request.getNewValues(),
                request.getIpAddress(),
                request.getUserAgent(),
                request.getSuccess(),
                request.getErrorMessage()
        );
        return ResponseEntity.ok(ApiResponse.success(null, "Action logged successfully"));
    }

    // DTO for logging actions
    public static class LogActionRequest {
        private String action;
        private String entityType;
        private UUID entityId;
        private String oldValues;
        private String newValues;
        private String ipAddress;
        private String userAgent;
        private Boolean success;
        private String errorMessage;

        // Getters and setters
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        public String getEntityType() { return entityType; }
        public void setEntityType(String entityType) { this.entityType = entityType; }
        public UUID getEntityId() { return entityId; }
        public void setEntityId(UUID entityId) { this.entityId = entityId; }
        public String getOldValues() { return oldValues; }
        public void setOldValues(String oldValues) { this.oldValues = oldValues; }
        public String getNewValues() { return newValues; }
        public void setNewValues(String newValues) { this.newValues = newValues; }
        public String getIpAddress() { return ipAddress; }
        public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
        public String getUserAgent() { return userAgent; }
        public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
        public Boolean getSuccess() { return success; }
        public void setSuccess(Boolean success) { this.success = success; }
        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    }
}
