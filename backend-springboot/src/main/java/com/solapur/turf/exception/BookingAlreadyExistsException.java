package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a user tries to book a turf slot that was already booked
 * by another user (race condition scenario or duplicate submission).
 * Maps to HTTP 409 Conflict.
 *
 * Usage:
 * if (bookingRepository.existsByTurfAndDateAndTimeOverlap(turfId, date, start,
 * end)) {
 * throw new BookingAlreadyExistsException(turfId, bookingDate, startTime,
 * endTime);
 * }
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class BookingAlreadyExistsException extends RuntimeException {

    // Detailed constructor
    public BookingAlreadyExistsException(Object turfId, Object date, Object start, Object end) {
        super(String.format(
                "A booking already exists for turf '%s' on %s from %s to %s",
                turfId, date, start, end));
    }

    // Simple message constructor
    public BookingAlreadyExistsException(String message) {
        super(message);
    }
}
