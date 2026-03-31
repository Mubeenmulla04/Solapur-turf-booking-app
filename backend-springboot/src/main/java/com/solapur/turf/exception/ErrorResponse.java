package com.solapur.turf.exception;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Standard error response format returned for ALL error HTTP responses.
 *
 * JSON format (single error):
 * {
 * "timestamp": "2026-03-03T00:03:05",
 * "status": 400,
 * "error": "Bad Request",
 * "message": "Start time must be before end time",
 * "path": "/api/bookings"
 * }
 *
 * JSON format (multi-field validation error):
 * {
 * "timestamp": "2026-03-03T00:03:05",
 * "status": 400,
 * "error": "Validation Failed",
 * "message": "One or more fields are invalid",
 * "path": "/api/bookings",
 * "errors": [
 * "email: must not be blank",
 * "phone: size must be between 10 and 10"
 * ]
 * }
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL) // omit 'errors' list when null (single-error case)
public class ErrorResponse {

    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private String path;

    // Only present for MethodArgumentNotValidException / ValidationException with
    // multiple errors
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    private List<String> errors;
}
