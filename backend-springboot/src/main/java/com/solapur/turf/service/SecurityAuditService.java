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

    private static class AttemptTracker {
        final AtomicInteger count = new AtomicInteger(0);
        volatile LocalDateTime lastAttempt = LocalDateTime.now();

        int incrementAndGet() {
            lastAttempt = LocalDateTime.now();
            return count.incrementAndGet();
        }

        int get() {
            return count.get();
        }
    }

    // In-memory counters for real-time monitoring
    private final Map<String, AttemptTracker> failedLoginAttempts = new ConcurrentHashMap<>();
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
        AttemptTracker tracker = failedLoginAttempts.computeIfAbsent(key, k -> new AttemptTracker());
        if (tracker.incrementAndGet() >= MAX_FAILED_ATTEMPTS) {
            logSecurityIncident("MULTIPLE_FAILED_LOGINS", email, ipAddress,
                    "Multiple failed login attempts detected");
        }
    }

    public void recordSuspiciousActivity(String activity, String userId, String ipAddress) {
        String key = activity + ":" + ipAddress;
        suspiciousActivities.computeIfAbsent(key, k -> new AtomicInteger(0)).incrementAndGet();

        logSecurityIncident(activity, userId, ipAddress, "Suspicious activity detected");
    }

    public boolean isAccountLocked(String email, String ipAddress) {
        String key = email + ":" + ipAddress;
        AttemptTracker tracker = failedLoginAttempts.get(key);
        if (tracker == null) {
            return false;
        }
        if (tracker.lastAttempt.isBefore(LocalDateTime.now().minusMinutes(LOCKOUT_DURATION_MINUTES))) {
            failedLoginAttempts.remove(key);
            return false;
        }
        return tracker.get() >= MAX_FAILED_ATTEMPTS;
    }

    private void checkForSuspiciousActivities() {
        // Check for unusual patterns
        LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);

        // Check for rapid API calls from same IP
        List<AuditLog> recentLogs = auditLogRepository.findByTimestampAfterOrderByTimestampDesc(oneHourAgo);
        Map<String, Long> ipCounts = recentLogs.stream()
                .filter(log -> log.getIpAddress() != null)
                .collect(java.util.stream.Collectors.groupingBy(
                        AuditLog::getIpAddress,
                        java.util.stream.Collectors.counting()));

        ipCounts.entrySet().stream()
                .filter(entry -> entry.getValue() > 1000) // More than 1000 requests per hour
                .forEach(entry -> {
                    logSecurityIncident("HIGH_FREQUENCY_REQUESTS", null, entry.getKey(),
                            "Unusually high request frequency detected");
                });
    }

    private void cleanupOldCounters() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(LOCKOUT_DURATION_MINUTES);
        failedLoginAttempts.entrySet().removeIf(entry -> entry.getValue().lastAttempt.isBefore(cutoff));
    }

    private void logSecurityMetrics() {
        int totalFailedAttempts = failedLoginAttempts.values().stream()
                .mapToInt(AttemptTracker::get).sum();
        int totalSuspiciousActivities = suspiciousActivities.values().stream()
                .mapToInt(AtomicInteger::get).sum();

        log.info("Security Metrics - Failed attempts: {}, Suspicious activities: {}",
                totalFailedAttempts, totalSuspiciousActivities);
    }

    private void logSecurityIncident(String incidentType, String userId, String ipAddress, String description) {
        // Log to app log only — do NOT persist to audit_logs DB table here.
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
