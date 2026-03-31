package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a user is authenticated but does not have permission
 * to perform the requested action (e.g., USER trying to access OWNER routes).
 * Maps to HTTP 403 Forbidden.
 *
 * Usage:
 * if (!userDetails.getUser().getRole().equals(UserRole.OWNER)) {
 * throw new ForbiddenException("Only turf owners can perform this action");
 * }
 */
@ResponseStatus(HttpStatus.FORBIDDEN)
public class ForbiddenException extends RuntimeException {

    public ForbiddenException(String message) {
        super(message);
    }

    public ForbiddenException(String message, Throwable cause) {
        super(message, cause);
    }
}
