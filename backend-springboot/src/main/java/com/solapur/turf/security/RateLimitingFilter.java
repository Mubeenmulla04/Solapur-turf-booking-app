package com.solapur.turf.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Rate limiting filter using Bucket4j token bucket algorithm.
 * Prevents abuse by limiting the number of requests per IP address.
 */
@Slf4j
@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    // Store buckets per IP address
    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();

    // Default rate limit: 100 requests per minute per IP
    private static final int DEFAULT_CAPACITY = 100;
    private static final Duration DEFAULT_REFILL_DURATION = Duration.ofMinutes(1);

    // Strict rate limit for auth endpoints: 10 requests per minute
    private static final int AUTH_CAPACITY = 10;
    private static final Duration AUTH_REFILL_DURATION = Duration.ofMinutes(1);

    // Very strict for password reset: 3 requests per hour
    private static final int PASSWORD_RESET_CAPACITY = 3;
    private static final Duration PASSWORD_RESET_REFILL_DURATION = Duration.ofHours(1);

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        String clientIp = getClientIp(request);
        String requestUri = request.getRequestURI();
        
        // Get or create bucket for this IP
        Bucket bucket = resolveBucket(clientIp, requestUri);

        // Try to consume 1 token
        if (bucket.tryConsume(1)) {
            // Request allowed
            filterChain.doFilter(request, response);
        } else {
            // Rate limit exceeded
            log.warn("Rate limit exceeded for IP: {} on endpoint: {}", clientIp, requestUri);
            response.setStatus(429); // Too Many Requests
            response.setContentType("application/json");
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Too many requests. Please try again later.\",\"error\":\"RATE_LIMIT_EXCEEDED\"}"
            );
        }
    }

    /**
     * Resolve or create a bucket for the given IP and endpoint
     */
    private Bucket resolveBucket(String clientIp, String requestUri) {
        String key = clientIp + ":" + requestUri;
        
        return cache.computeIfAbsent(key, k -> {
            // Different rate limits based on endpoint sensitivity
            Bandwidth limit;
            
            if (requestUri.contains("/api/auth/login") || 
                requestUri.contains("/api/auth/register")) {
                // Auth endpoints: 10 requests per minute
                limit = Bandwidth.classic(AUTH_CAPACITY, 
                    Refill.intervally(AUTH_CAPACITY, AUTH_REFILL_DURATION));
            } else if (requestUri.contains("/api/auth/forgot-password")) {
                // Password reset: 3 requests per hour
                limit = Bandwidth.classic(PASSWORD_RESET_CAPACITY,
                    Refill.intervally(PASSWORD_RESET_CAPACITY, PASSWORD_RESET_REFILL_DURATION));
            } else {
                // Default: 100 requests per minute
                limit = Bandwidth.classic(DEFAULT_CAPACITY,
                    Refill.intervally(DEFAULT_CAPACITY, DEFAULT_REFILL_DURATION));
            }
            
            return Bucket.builder()
                    .addLimit(limit)
                    .build();
        });
    }

    /**
     * Extract client IP address from request, considering proxies
     */
    private String getClientIp(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader != null && !xfHeader.isEmpty()) {
            return xfHeader.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }

    /**
     * Skip rate limiting for static resources
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String path = request.getRequestURI();
        return path.startsWith("/static/") || 
               path.startsWith("/css/") || 
               path.startsWith("/js/") || 
               path.startsWith("/images/") ||
               path.startsWith("/uploads/") ||
               path.startsWith("/swagger-ui/") ||
               path.startsWith("/v3/api-docs/");
    }
}
