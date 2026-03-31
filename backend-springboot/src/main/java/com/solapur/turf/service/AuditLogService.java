package com.solapur.turf.service;

import com.solapur.turf.dto.AuditLogDto;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.entity.AuditLog;
import com.solapur.turf.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    public PageResponse<AuditLogDto> getAuditLogs(int page, int limit) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "timestamp"));
        Page<AuditLog> auditLogPage = auditLogRepository.findAllByOrderByTimestampDesc(pageable);
        return new PageResponse<>(auditLogPage.map(this::mapToDto));
    }

    public PageResponse<AuditLogDto> getAuditLogsByUser(UUID userId, int page, int limit) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "timestamp"));
        Page<AuditLog> auditLogPage = auditLogRepository.findByUserIdOrderByTimestampDesc(userId, pageable);
        return new PageResponse<>(auditLogPage.map(this::mapToDto));
    }

    public PageResponse<AuditLogDto> getAuditLogsByAction(String action, int page, int limit) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "timestamp"));
        Page<AuditLog> auditLogPage = auditLogRepository.findByActionOrderByTimestampDesc(action, pageable);
        return new PageResponse<>(auditLogPage.map(this::mapToDto));
    }

    public PageResponse<AuditLogDto> getAuditLogsByDateRange(LocalDateTime startDate, LocalDateTime endDate, int page, int limit) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "timestamp"));
        Page<AuditLog> auditLogPage = auditLogRepository.findByTimestampBetween(startDate, endDate, pageable);
        return new PageResponse<>(auditLogPage.map(this::mapToDto));
    }

    public List<AuditLogDto> getRecentAuditLogs(int limit) {
        List<AuditLog> logs = auditLogRepository.findTop100ByOrderByTimestampDesc();
        return logs.stream()
                .limit(limit)
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public void logAction(UUID userId, String userEmail, String userRole, String action, 
                         String entityType, UUID entityId, String oldValues, String newValues,
                         String ipAddress, String userAgent, Boolean success, String errorMessage) {
        AuditLog auditLog = AuditLog.builder()
                .userId(userId)
                .userEmail(userEmail)
                .userRole(userRole)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .oldValues(oldValues)
                .newValues(newValues)
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .success(success)
                .errorMessage(errorMessage)
                .build();

        auditLogRepository.save(auditLog);
    }

    private AuditLogDto mapToDto(AuditLog auditLog) {
        return AuditLogDto.builder()
                .id(auditLog.getId())
                .userId(auditLog.getUserId())
                .userEmail(auditLog.getUserEmail())
                .userRole(auditLog.getUserRole())
                .action(auditLog.getAction())
                .entityType(auditLog.getEntityType())
                .entityId(auditLog.getEntityId())
                .oldValues(auditLog.getOldValues())
                .newValues(auditLog.getNewValues())
                .ipAddress(auditLog.getIpAddress())
                .userAgent(auditLog.getUserAgent())
                .timestamp(auditLog.getTimestamp())
                .success(auditLog.getSuccess())
                .errorMessage(auditLog.getErrorMessage())
                .build();
    }
}
