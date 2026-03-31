package com.solapur.turf.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Standard API response wrapper for ALL successful responses.
 *
 * Every controller should return ApiResponse<T> so Flutter always
 * knows exactly where to find data, messages, and status.
 *
 * JSON format:
 * {
 * "success": true,
 * "message": "Login successful",
 * "data": { ... }, ← nullable for void operations
 * "timestamp": "2026-03-03T00:03:05"
 * }
 *
 * Controller usage:
 * return ResponseEntity.ok(ApiResponse.success(authResponse, "Login
 * successful"));
 * return ResponseEntity.status(201).body(ApiResponse.created(booking, "Booking
 * created"));
 * return ResponseEntity.ok(ApiResponse.ok("Slot cancelled successfully"));
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL) // Omit null 'data' from JSON response
public class ApiResponse<T> {

    private boolean success;
    private String message;
    private T data;
    private LocalDateTime timestamp;

    // ── Factory methods ─────────────────────────────────────────────────────

    /**
     * 200 OK with data and message
     */
    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * 201 Created — alias for success, used for resource creation
     */
    public static <T> ApiResponse<T> created(T data, String message) {
        return success(data, message);
    }

    /**
     * 200 OK with message only (no body data — e.g., delete, cancel operations)
     */
    public static <T> ApiResponse<T> ok(String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Error response (used internally, prefer ErrorResponse for exception handler)
     */
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
