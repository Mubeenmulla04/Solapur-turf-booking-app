package com.solapur.turf.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Set;

/**
 * Protects the Razorpay webhook endpoint by whitelisting only
 * known Razorpay IP addresses.
 *
 * Any request to /api/payments/webhook from an unknown IP is
 * rejected with 403 Forbidden and logged.
 *
 * Official Razorpay webhook IPs:
 * https://razorpay.com/docs/webhooks/validate-test/#ip-addresses
 */
@Slf4j
@Component
public class RazorpayWebhookFilter extends OncePerRequestFilter {

    private static final String WEBHOOK_PATH = "/api/payments/webhook";

    /**
     * Razorpay's official webhook source IPs.
     * Update this list if Razorpay publishes new IPs.
     */
    private static final Set<String> RAZORPAY_ALLOWED_IPS = Set.of(
        // Production webhook IPs
        "54.187.174.169",
        "54.187.205.235",
        "54.187.101.64",
        "54.243.162.209",
        "50.18.192.231",
        "54.215.11.81",
        "54.153.13.85",
        // Localhost - for development/testing only
        "127.0.0.1",
        "0:0:0:0:0:0:0:1"
    );

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        // Only apply to the webhook endpoint
        if (!WEBHOOK_PATH.equals(request.getRequestURI())) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientIp = extractClientIp(request);

        if (!RAZORPAY_ALLOWED_IPS.contains(clientIp)) {
            log.warn("SECURITY: Blocked webhook request from unauthorized IP: {} | User-Agent: {}",
                    clientIp, request.getHeader("User-Agent"));

            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Access denied\"}");
            return;
        }

        // Also require the signature header to be present before even reaching the controller
        String signature = request.getHeader("X-Razorpay-Signature");
        if (signature == null || signature.isBlank()) {
            log.warn("SECURITY: Webhook request from {} missing X-Razorpay-Signature header", clientIp);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Missing webhook signature\"}");
            return;
        }

        log.debug("Webhook request accepted from Razorpay IP: {}", clientIp);
        filterChain.doFilter(request, response);
    }

    /**
     * Extract real client IP, accounting for reverse proxies.
     * For webhook calls, Razorpay sends from their own IPs directly —
     * X-Forwarded-For should reflect that if you're behind a load balancer.
     */
    private String extractClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isBlank()) {
            // Take the first IP (original client), not intermediate proxies
            return xForwardedFor.split(",")[0].trim();
        }

        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isBlank()) {
            return xRealIp.trim();
        }

        return request.getRemoteAddr();
    }

    /**
     * Only run this filter for the webhook path
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !WEBHOOK_PATH.equals(request.getRequestURI());
    }
}
