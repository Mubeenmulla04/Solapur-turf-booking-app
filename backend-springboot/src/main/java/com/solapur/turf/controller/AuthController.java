package com.solapur.turf.controller;

import com.solapur.turf.dto.*;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.AuthService;
import com.solapur.turf.service.SecurityAuditService;
import com.solapur.turf.util.ValidationUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final SecurityAuditService securityAuditService;

    // ─── POST /api/auth/register ──────────────────────────────────────────────
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest) {

        String clientIp = getClientIp(httpRequest);
        String sanitizedEmail = ValidationUtil.sanitizeInput(request.getEmail());

        if (!ValidationUtil.isValidEmail(sanitizedEmail)) {
            throw new IllegalArgumentException("Invalid email format");
        }
        if (!ValidationUtil.isValidPhone(request.getPhone())) {
            throw new IllegalArgumentException("Invalid phone number format");
        }

        AuthResponse authResponse = authService.register(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(authResponse, "Registration successful"));
    }

    // ─── POST /api/auth/login ─────────────────────────────────────────────────
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {

        String clientIp  = getClientIp(httpRequest);
        String identifier = ValidationUtil.sanitizeInput(request.getIdentifier());

        if (securityAuditService.isAccountLocked(identifier, clientIp)) {
            return ResponseEntity
                    .status(HttpStatus.TOO_MANY_REQUESTS)
                    .body(ApiResponse.error("Account temporarily locked due to multiple failed attempts"));
        }

        try {
            AuthResponse authResponse = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success(authResponse, "Login successful"));
        } catch (Exception e) {
            securityAuditService.recordFailedLogin(identifier, clientIp);
            throw e;
        }
    }

    // ─── POST /api/auth/refresh ────────────────────────────────────────────────
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse authResponse = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(authResponse, "Token refreshed successfully"));
    }

    // ─── POST /api/auth/logout ────────────────────────────────────────────────
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Object>> logout(HttpServletRequest httpRequest) {
        String authHeader = httpRequest.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            authService.logout(authHeader.substring(7));
        }
        return ResponseEntity.ok(ApiResponse.success(null, "Logged out successfully"));
    }

    // ─── GET /api/auth/me ─────────────────────────────────────────────────────
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        UserDto dto = authService.getCurrentUser(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(dto, "User profile fetched successfully"));
    }

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Object>> changePassword(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(null, "Password changed successfully"));
    }

    // ─── POST /api/auth/forgot-password/request ───────────────────────────────
    @PostMapping("/forgot-password/request")
    public ResponseEntity<ApiResponse<Object>> requestForgotPassword(
            @RequestBody java.util.Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        authService.sendForgotPasswordOtp(email);
        return ResponseEntity.ok(ApiResponse.success(null, "OTP sent to your email"));
    }

    // ─── POST /api/auth/forgot-password/reset ─────────────────────────────────
    @PostMapping("/forgot-password/reset")
    public ResponseEntity<ApiResponse<Object>> resetPasswordWithOtp(
            @Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPasswordWithOtp(request);
        return ResponseEntity.ok(ApiResponse.success(null, "Password reset successfully"));
    }

    // ─── Helper ───────────────────────────────────────────────────────────────
    private String getClientIp(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null) return request.getRemoteAddr();
        return xfHeader.split(",")[0];
    }
}
