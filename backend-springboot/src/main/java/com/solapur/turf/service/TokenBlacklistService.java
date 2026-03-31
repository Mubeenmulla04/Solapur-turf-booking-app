package com.solapur.turf.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory JWT token blacklist.
 * Tokens are added on logout and expire automatically when their
 * original JWT expiry passes (to avoid unbounded growth).
 */
@Service
public class TokenBlacklistService {

    // token -> expiry epoch millis
    private final Map<String, Long> blacklist = new ConcurrentHashMap<>();

    public void blacklist(String token, long expiryEpochMillis) {
        blacklist.put(token, expiryEpochMillis);
    }

    public boolean isBlacklisted(String token) {
        Long expiry = blacklist.get(token);
        if (expiry == null) return false;
        // Token's own expiry has already passed → remove and treat as not blacklisted
        // (Spring Security will reject expired tokens anyway)
        if (Instant.now().toEpochMilli() > expiry) {
            blacklist.remove(token);
            return false;
        }
        return true;
    }

    /** Hourly cleanup: remove entries whose original JWT has long expired. */
    @Scheduled(fixedRate = 3_600_000)
    public void evictExpiredTokens() {
        long now = Instant.now().toEpochMilli();
        blacklist.entrySet().removeIf(e -> e.getValue() < now);
    }
}
