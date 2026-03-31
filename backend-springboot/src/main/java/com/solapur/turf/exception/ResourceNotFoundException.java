package com.solapur.turf.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when a requested resource (Turf, User, Booking, etc.) does not exist.
 * Maps to HTTP 404 Not Found.
 *
 * Usage:
 * throw new ResourceNotFoundException("Turf", "id", turfId);
 * throw new ResourceNotFoundException("User not found with email: " + email);
 */
@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {

    private final String resourceName;
    private final String fieldName;
    private final Object fieldValue;

    // Constructor with resource details
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not found with %s: '%s'", resourceName, fieldName, fieldValue));
        this.resourceName = resourceName;
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
    }

    // Simple message constructor
    public ResourceNotFoundException(String message) {
        super(message);
        this.resourceName = "";
        this.fieldName = "";
        this.fieldValue = "";
    }

    public String getResourceName() {
        return resourceName;
    }

    public String getFieldName() {
        return fieldName;
    }

    public Object getFieldValue() {
        return fieldValue;
    }
}
