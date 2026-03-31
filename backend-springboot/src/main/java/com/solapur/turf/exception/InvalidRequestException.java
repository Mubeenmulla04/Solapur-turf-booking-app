package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a request contains invalid business logic input
 * that @Valid annotations don't cover (e.g., startTime after endTime).
 * Maps to HTTP 400 Bad Request.
 *
 * Usage:
 * if (request.getStartTime().isAfter(request.getEndTime())) {
 * throw new InvalidRequestException("Start time must be before end time");
 * }
 */
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class InvalidRequestException extends RuntimeException {

    public InvalidRequestException(String message) {
        super(message);
    }

    public InvalidRequestException(String message, Throwable cause) {
        super(message, cause);
    }
}
