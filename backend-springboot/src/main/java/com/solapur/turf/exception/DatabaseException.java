package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a database operation fails due to an infrastructure problem
 * (connection issues, query failures etc.) that is NOT a data integrity
 * violation.
 * Maps to HTTP 500 Internal Server Error.
 *
 * Usage:
 * try {
 * return repository.save(entity);
 * } catch (DataAccessException e) {
 * throw new DatabaseException("Failed to save booking record", e);
 * }
 *
 * Note: DataIntegrityViolationException is handled separately in
 * GlobalExceptionHandler.
 */
@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
public class DatabaseException extends RuntimeException {

    public DatabaseException(String message) {
        super(message);
    }

    public DatabaseException(String message, Throwable cause) {
        super(message, cause);
    }
}
