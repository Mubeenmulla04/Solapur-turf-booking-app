package com.solapur.turf.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Adds industry-standard HTTP security headers to every response.
 *
 * Headers added:
 *  - X-Content-Type-Options     : prevents MIME sniffing
 *  - X-Frame-Options            : prevents clickjacking
 *  - X-XSS-Protection           : legacy XSS protection for older browsers
 *  - Strict-Transport-Security  : enforces HTTPS (HSTS)
 *  - Content-Security-Policy    : restricts resource loading origins
 *  - Referrer-Policy            : controls referrer information
 *  - Permissions-Policy         : disables unneeded browser features
 *  - Cache-Control              : prevents sensitive data caching
 */
@Component
public class SecurityHeadersFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        // ── Prevent MIME type sniffing ─────────────────────────────────────
        response.setHeader("X-Content-Type-Options", "nosniff");

        // ── Prevent Clickjacking ───────────────────────────────────────────
        response.setHeader("X-Frame-Options", "DENY");

        // ── XSS Protection (legacy browsers) ──────────────────────────────
        response.setHeader("X-XSS-Protection", "1; mode=block");

        // ── HSTS: Force HTTPS for 1 year, include subdomains ──────────────
        response.setHeader("Strict-Transport-Security",
                "max-age=31536000; includeSubDomains; preload");

        // ── Content Security Policy ────────────────────────────────────────
        // Restricts sources for scripts, styles, images, fonts, etc.
        response.setHeader("Content-Security-Policy",
                "default-src 'self'; " +
                "script-src 'self' 'unsafe-inline'; " +
                "style-src 'self' 'unsafe-inline'; " +
                "img-src 'self' data: https:; " +
                "font-src 'self' data: https:; " +
                "connect-src 'self' http: https: ws: wss:; " +
                "frame-ancestors 'none'; " +
                "base-uri 'self'; " +
                "form-action 'self'");

        // ── Referrer Policy ────────────────────────────────────────────────
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // ── Permissions Policy: disable unneeded browser features ──────────
        response.setHeader("Permissions-Policy",
                "camera=(), microphone=(), geolocation=(), payment=(), usb=()");

        // ── Prevent caching of sensitive API responses ─────────────────────
        String uri = request.getRequestURI();
        if (uri.startsWith("/api/")) {
            response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, private");
            response.setHeader("Pragma", "no-cache");
            response.setHeader("Expires", "0");
        }

        filterChain.doFilter(request, response);
    }
}
