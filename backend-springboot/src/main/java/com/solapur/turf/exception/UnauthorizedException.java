package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a request requires authentication but no valid JWT was provided,
 * or the JWT has expired.
 * Maps to HTTP 401 Unauthorized.
 *
 * Usage:
 * throw new UnauthorizedException("Session expired. Please login again.");
 * throw new UnauthorizedException("Invalid credentials");
 */
@ResponseStatus(HttpStatus.UNAUTHORIZED)
public class UnauthorizedException extends RuntimeException {

    public UnauthorizedException(String message) {
        super(message);
    }

    public UnauthorizedException(String message, Throwable cause) {
        super(message, cause);
    }
}
