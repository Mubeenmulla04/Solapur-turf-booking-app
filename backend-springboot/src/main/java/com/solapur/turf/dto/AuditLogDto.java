package com.solapur.turf.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class AuditLogDto {
    private UUID id;
    private UUID userId;
    private String userEmail;
    private String userRole;
    private String action;
    private String entityType;
    private UUID entityId;
    private String oldValues;
    private String newValues;
    private String ipAddress;
    private String userAgent;
    private LocalDateTime timestamp;
    private Boolean success;
    private String errorMessage;
}
