package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when creating a resource that already exists
 * (e.g., duplicate email, duplicate phone, duplicate slot).
 * Maps to HTTP 409 Conflict.
 *
 * Usage:
 * if (userRepository.existsByEmail(email)) {
 * throw new ConflictException("User with email " + email + " already exists");
 * }
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }

    public ConflictException(String message, Throwable cause) {
        super(message, cause);
    }
}
