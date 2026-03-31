package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.List;

/**
 * Thrown for complex multi-field validation failures that cannot be expressed
 * with @Valid constraints alone (e.g., cross-field business rules).
 * Maps to HTTP 400 Bad Request.
 *
 * Usage (single message):
 * throw new ValidationException("Booking duration must be between 1 and 4
 * hours");
 *
 * Usage (multiple errors):
 * throw new ValidationException(List.of(
 * "Start time is in the past",
 * "Duration exceeds maximum allowed (4 hours)"
 * ));
 */
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class ValidationException extends RuntimeException {

    private final List<String> errors;

    // Single-error constructor
    public ValidationException(String message) {
        super(message);
        this.errors = List.of(message);
    }

    // Multi-error constructor (all errors concatenated in message)
    public ValidationException(List<String> errors) {
        super(String.join("; ", errors));
        this.errors = List.copyOf(errors);
    }

    /**
     * Returns all individual validation errors.
     * GlobalExceptionHandler uses this for richer error responses.
     */
    public List<String> getErrors() {
        return errors;
    }
}
