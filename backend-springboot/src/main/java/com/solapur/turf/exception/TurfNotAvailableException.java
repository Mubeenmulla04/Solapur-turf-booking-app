package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a requested turf slot is not available for booking
 * (e.g., slot is already BOOKED or BLOCKED by owner).
 * Maps to HTTP 409 Conflict.
 *
 * Usage:
 * if (slot.getStatus() != SlotStatus.AVAILABLE) {
 * throw new TurfNotAvailableException(turf.getName(), request.getDate(),
 * slot.getStartTime());
 * }
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class TurfNotAvailableException extends RuntimeException {

    public TurfNotAvailableException(String turfName, Object date, Object startTime) {
        super(String.format(
                "Turf '%s' is not available on %s at %s. Please choose a different slot.",
                turfName, date, startTime));
    }

    public TurfNotAvailableException(String message) {
        super(message);
    }
}
