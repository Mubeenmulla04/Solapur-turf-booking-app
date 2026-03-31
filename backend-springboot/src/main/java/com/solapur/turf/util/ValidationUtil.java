package com.solapur.turf.util;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.stream.Collectors;

@Component
public class ValidationUtil {

    private final Validator validator;

    public ValidationUtil() {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            this.validator = factory.getValidator();
        }
    }

    public <T> void validate(T object) {
        Set<ConstraintViolation<T>> violations = validator.validate(object);
        if (!violations.isEmpty()) {
            String errorMessage = violations.stream()
                    .map(ConstraintViolation::getMessage)
                    .collect(Collectors.joining(", "));
            throw new IllegalArgumentException("Validation failed: " + errorMessage);
        }
    }

    public <T> void validateProperty(T object, String propertyName) {
        Set<ConstraintViolation<T>> violations = validator.validateProperty(object, propertyName);
        if (!violations.isEmpty()) {
            String errorMessage = violations.stream()
                    .map(ConstraintViolation::getMessage)
                    .collect(Collectors.joining(", "));
            throw new IllegalArgumentException("Validation failed for " + propertyName + ": " + errorMessage);
        }
    }

    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        // Remove potentially dangerous characters
        return input.replaceAll("[<>\"'&]", "");
    }

    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        return phone.matches("^[0-9]{10}$");
    }

    public static boolean isValidUuid(String uuid) {
        if (uuid == null || uuid.trim().isEmpty()) {
            return false;
        }
        try {
            java.util.UUID.fromString(uuid);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
