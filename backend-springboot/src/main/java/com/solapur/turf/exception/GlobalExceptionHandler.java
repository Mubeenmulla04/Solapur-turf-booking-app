package com.solapur.turf.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Global exception handler for the entire Spring Boot application.
 *
 * Handles:
 * - All custom domain exceptions (ResourceNotFoundException, etc.)
 * - Spring MVC exceptions (@Valid failures, bad JSON, type mismatches)
 * - Spring Security exceptions (authentication, access denied)
 * - Database integrity violations
 * - All other unexpected exceptions (catch-all)
 *
 * All responses follow the ErrorResponse format:
 * { timestamp, status, error, message, path, errors? }
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    // ── Helper ──────────────────────────────────────────────────────────────

    private ResponseEntity<ErrorResponse> build(
            HttpStatus status,
            String error,
            String message,
            HttpServletRequest request,
            List<String> errors) {
        return ResponseEntity.status(status).body(
                ErrorResponse.builder()
                        .timestamp(LocalDateTime.now())
                        .status(status.value())
                        .error(error)
                        .message(message)
                        .path(request.getRequestURI())
                        .errors(errors)
                        .build());
    }

    private ResponseEntity<ErrorResponse> build(
            HttpStatus status, String error, String message, HttpServletRequest request) {
        return build(status, error, message, request, null);
    }

    // ── 400 Bad Request ──────────────────────────────────────────────────────

    /**
     * Handles @Valid / @Validated annotation failures on @RequestBody.
     * Collects ALL field errors and returns them in the 'errors' list.
     *
     * Triggered by: missing/invalid fields in request JSON.
     * Flutter should: display each error message under the corresponding field.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleMethodArgumentNotValid(
            MethodArgumentNotValidException ex,
            HttpServletRequest request) {
        List<String> fieldErrors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.toList());

        // Also include global object errors (cross-field constraints)
        List<String> globalErrors = ex.getBindingResult()
                .getGlobalErrors()
                .stream()
                .map(err -> err.getObjectName() + ": " + err.getDefaultMessage())
                .collect(Collectors.toList());

        fieldErrors.addAll(globalErrors);

        return build(
                HttpStatus.BAD_REQUEST,
                "Validation Failed",
                "One or more fields are invalid",
                request,
                fieldErrors);
    }

    /**
     * Handles malformed JSON bodies (invalid JSON structure), missing body,
     * or unrecognized enum values.
     *
     * Triggered by: sending bad JSON like {"email":} or wrong enum string.
     * Flutter should: log the error — this is a developer mistake, not a user
     * mistake.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleHttpMessageNotReadable(
            HttpMessageNotReadableException ex,
            HttpServletRequest request) {
        String message = "Request body is missing or contains invalid JSON format";
        // Provide a more specific message for unrecognized enum values
        if (ex.getMessage() != null && ex.getMessage().contains("not one of the values accepted")) {
            message = "Invalid value provided. Please check accepted values for enum fields.";
        }
        return build(HttpStatus.BAD_REQUEST, "Bad Request", message, request);
    }

    /**
     * Handles path variable or request param type mismatch.
     * E.g., passing "abc" where a UUID or Long is expected.
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleMethodArgumentTypeMismatch(
            MethodArgumentTypeMismatchException ex,
            HttpServletRequest request) {
        String message = String.format(
                "Parameter '%s' has invalid value '%s'. Expected type: %s",
                ex.getName(),
                ex.getValue(),
                ex.getRequiredType() != null ? ex.getRequiredType().getSimpleName() : "unknown");
        return build(HttpStatus.BAD_REQUEST, "Bad Request", message, request);
    }

    /**
     * Handles missing required @RequestParam parameters.
     */
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ErrorResponse> handleMissingServletRequestParameter(
            MissingServletRequestParameterException ex,
            HttpServletRequest request) {
        String message = String.format(
                "Required parameter '%s' of type '%s' is missing",
                ex.getParameterName(),
                ex.getParameterType());
        return build(HttpStatus.BAD_REQUEST, "Bad Request", message, request);
    }

    /**
     * Handles our custom InvalidRequestException (business logic validation).
     */
    @ExceptionHandler(InvalidRequestException.class)
    public ResponseEntity<ErrorResponse> handleInvalidRequest(
            InvalidRequestException ex,
            HttpServletRequest request) {
        return build(HttpStatus.BAD_REQUEST, "Bad Request", ex.getMessage(), request);
    }

    /**
     * Handles our custom ValidationException (multi-field business validation).
     */
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            ValidationException ex,
            HttpServletRequest request) {
        return build(
                HttpStatus.BAD_REQUEST,
                "Validation Failed",
                ex.getMessage(),
                request,
                ex.getErrors());
    }

    // ── 401 Unauthorized ─────────────────────────────────────────────────────

    /**
     * Handles our custom UnauthorizedException.
     * Flutter should: clear token and redirect to login screen.
     */
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(
            UnauthorizedException ex,
            HttpServletRequest request) {
        return build(HttpStatus.UNAUTHORIZED, "Unauthorized", ex.getMessage(), request);
    }

    /**
     * Handles Spring Security's AuthenticationException
     * (e.g., when JwtAuthenticationFilter rejects a token).
     * Flutter should: redirect to login screen.
     */
    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuthenticationException(
            AuthenticationException ex,
            HttpServletRequest request) {
        return build(
                HttpStatus.UNAUTHORIZED,
                "Unauthorized",
                "Authentication failed: " + ex.getMessage(),
                request);
    }

    // ── 403 Forbidden ────────────────────────────────────────────────────────

    /**
     * Handles our custom ForbiddenException.
     * Flutter should: show an "Access Denied" screen or snackbar.
     */
    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(
            ForbiddenException ex,
            HttpServletRequest request) {
        return build(HttpStatus.FORBIDDEN, "Forbidden", ex.getMessage(), request);
    }

    /**
     * Handles Spring Security's AccessDeniedException
     * (role-based access check failure via @PreAuthorize).
     * Flutter should: show "Access Denied" message.
     */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(
            AccessDeniedException ex,
            HttpServletRequest request) {
        return build(
                HttpStatus.FORBIDDEN,
                "Forbidden",
                "You do not have permission to perform this action",
                request);
    }

    // ── 404 Not Found ────────────────────────────────────────────────────────

    /**
     * Handles our custom ResourceNotFoundException.
     * Flutter should: show a "Not found" message or navigate back.
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
            ResourceNotFoundException ex,
            HttpServletRequest request) {
        return build(HttpStatus.NOT_FOUND, "Not Found", ex.getMessage(), request);
    }

    // ── 409 Conflict ─────────────────────────────────────────────────────────

    /**
     * Handles our custom ConflictException (e.g., duplicate email/phone).
     * Flutter should: show exact message, e.g., "Email already registered".
     */
    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorResponse> handleConflict(
            ConflictException ex,
            HttpServletRequest request) {
        return build(HttpStatus.CONFLICT, "Conflict", ex.getMessage(), request);
    }

    /**
     * Handles BookingAlreadyExistsException — specific slot conflict.
     * Flutter should: refresh the slot grid and inform user to pick another slot.
     */
    @ExceptionHandler(BookingAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleBookingAlreadyExists(
            BookingAlreadyExistsException ex,
            HttpServletRequest request) {
        return build(HttpStatus.CONFLICT, "Booking Conflict", ex.getMessage(), request);
    }

    /**
     * Handles TurfNotAvailableException — slot blocked/booked.
     * Flutter should: refresh availability and show slot picker.
     */
    @ExceptionHandler(TurfNotAvailableException.class)
    public ResponseEntity<ErrorResponse> handleTurfNotAvailable(
            TurfNotAvailableException ex,
            HttpServletRequest request) {
        return build(HttpStatus.CONFLICT, "Turf Not Available", ex.getMessage(), request);
    }

    /**
     * Handles JPA/Hibernate DataIntegrityViolationException
     * (e.g., DB-level UNIQUE constraint violation, NOT NULL violation).
     *
     * This is the database-level safety net even when service-layer checks pass.
     * Flutter should: treat as 409 — something already exists.
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(
            DataIntegrityViolationException ex,
            HttpServletRequest request) {
        // Extract root cause for a cleaner message
        String message = "Data conflict: a record with the provided details already exists";
        if (ex.getRootCause() != null && ex.getRootCause().getMessage() != null) {
            String rootMsg = ex.getRootCause().getMessage().toLowerCase();
            if (rootMsg.contains("email")) {
                message = "An account with this email already exists";
            } else if (rootMsg.contains("phone")) {
                message = "An account with this phone number already exists";
            } else if (rootMsg.contains("booking")) {
                message = "A booking conflict occurred. Please choose another slot.";
            }
        }
        return build(HttpStatus.CONFLICT, "Data Conflict", message, request);
    }

    // ── 500 Internal Server Error ────────────────────────────────────────────

    /**
     * Handles our custom DatabaseException (infrastructure-level DB failure).
     * Flutter should: show "Something went wrong, please try again" with retry
     * button.
     */
    @ExceptionHandler(DatabaseException.class)
    public ResponseEntity<ErrorResponse> handleDatabaseException(
            DatabaseException ex,
            HttpServletRequest request) {
        return build(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Database Error",
                "A database error occurred. Please try again later.",
                request);
    }

    /**
     * Handles general custom domain exceptions (ApiException).
     * Returns the HTTP status embedded within the exception.
     */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorResponse> handleApiException(
            ApiException ex,
            HttpServletRequest request) {
        return build(
                ex.getStatus(),
                ex.getStatus().getReasonPhrase(),
                ex.getMessage(),
                request);
    }

    /**
     * Catch-all handler for any unexpected exception not covered above.
     * The real error is logged but NOT exposed to the client (security).
     * Flutter should: show "Something went wrong" with retry button.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex,
            HttpServletRequest request) {
        // Log the full stack trace for debugging — without this you'll never know what
        // broke
        log.error("Unhandled exception at {}: {} - {}", request.getRequestURI(), ex.getClass().getName(), ex.getMessage(), ex);

        return build(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Internal Server Error",
                "An unexpected error occurred. Please try again later.",
                request);
    }
}
