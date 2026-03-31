package com.solapur.turf.service;

import com.solapur.turf.entity.AuditLog;
import com.solapur.turf.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@RequiredArgsConstructor
@Slf4j
public class SecurityAuditService {

    private final AuditLogRepository auditLogRepository;

    // In-memory counters for real-time monitoring
    private final Map<String, AtomicInteger> failedLoginAttempts = new ConcurrentHashMap<>();
    private final Map<String, AtomicInteger> suspiciousActivities = new ConcurrentHashMap<>();

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCKOUT_DURATION_MINUTES = 15;

    @Scheduled(fixedRate = 60000) // Every minute
    public void performSecurityAudit() {
        checkForSuspiciousActivities();
        cleanupOldCounters();
        logSecurityMetrics();
    }

    public void recordFailedLogin(String email, String ipAddress) {
        String key = email + ":" + ipAddress;
        failedLoginAttempts.computeIfAbsent(key, k -> new AtomicInteger(0)).incrementAndGet();

        if (failedLoginAttempts.get(key).get() >= MAX_FAILED_ATTEMPTS) {
            logSecurityIncident("MULTIPLE_FAILED_LOGINS", email, ipAddress,
                    "Multiple failed login attempts detected");
            // In a real system, you would lock the account here
        }
    }

    public void recordSuspiciousActivity(String activity, String userId, String ipAddress) {
        String key = activity + ":" + ipAddress;
        suspiciousActivities.computeIfAbsent(key, k -> new AtomicInteger(0)).incrementAndGet();

        logSecurityIncident(activity, userId, ipAddress, "Suspicious activity detected");
    }

    public boolean isAccountLocked(String email, String ipAddress) {
        String key = email + ":" + ipAddress;
        AtomicInteger attempts = failedLoginAttempts.get(key);
        return attempts != null && attempts.get() >= MAX_FAILED_ATTEMPTS;
    }

    private void checkForSuspiciousActivities() {
        // Check for unusual patterns
        LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);

        // Check for rapid API calls from same IP
        List<AuditLog> recentLogs = auditLogRepository.findByTimestampAfterOrderByTimestampDesc(oneHourAgo);
        Map<String, Long> ipCounts = recentLogs.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                        log -> log.getIpAddress(),
                        java.util.stream.Collectors.counting()));

        ipCounts.entrySet().stream()
                .filter(entry -> entry.getValue() > 1000) // More than 1000 requests per hour
                .forEach(entry -> {
                    logSecurityIncident("HIGH_FREQUENCY_REQUESTS", null, entry.getKey(),
                            "Unusually high request frequency detected");
                });
    }

    private void cleanupOldCounters() {
        // Clean up counters older than lockout duration
        // LocalDateTime cutoff = LocalDateTime.now().minusMinutes(LOCKOUT_DURATION_MINUTES);

        failedLoginAttempts.entrySet().removeIf(entry -> {
            // In a real implementation, you'd store timestamps
            return false; // For now, keep all counters
        });
    }

    private void logSecurityMetrics() {
        int totalFailedAttempts = failedLoginAttempts.values().stream()
                .mapToInt(AtomicInteger::get).sum();
        int totalSuspiciousActivities = suspiciousActivities.values().stream()
                .mapToInt(AtomicInteger::get).sum();

        log.info("Security Metrics - Failed attempts: {}, Suspicious activities: {}",
                totalFailedAttempts, totalSuspiciousActivities);
    }

    private void logSecurityIncident(String incidentType, String userId, String ipAddress, String description) {
        // Log to app log only — do NOT persist to audit_logs DB table here.
        // AuditLog requires non-null userId/userEmail/userRole, which are unavailable
        // for pre-authentication incidents (e.g., failed logins). Persisting here
        // would cause a DataIntegrityViolationException → 500 for every failed login.
        log.warn("Security Incident - Type: {}, User: {}, IP: {}, Description: {}",
                incidentType, userId, ipAddress, description);
    }

    public Map<String, Object> getSecurityReport() {
        return Map.of(
                "failedLoginAttempts", failedLoginAttempts.size(),
                "suspiciousActivities", suspiciousActivities.size(),
                "lockedAccounts", failedLoginAttempts.entrySet().stream()
                        .filter(entry -> entry.getValue().get() >= MAX_FAILED_ATTEMPTS)
                        .count(),
                "timestamp", LocalDateTime.now());
    }
}
