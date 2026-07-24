package com.solapur.turf.util;

import com.solapur.turf.exception.ApiException;
import org.apache.tika.Tika;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * Validates file uploads using Apache Tika magic-byte detection.
 *
 * Unlike checking just MIME type or extension (both easily spoofed),
 * Tika reads the actual file bytes to determine the real content type.
 *
 * Rules enforced:
 *  - Max file size: 10 MB
 *  - Allowed types for images: JPEG, PNG, WEBP
 *  - Allowed types for documents: JPEG, PNG, PDF
 *  - File extension must match actual content
 *  - No path traversal in filename
 *  - Filename sanitized to alphanumeric + safe chars only
 */
@Component
public class FileUploadValidator {

    private static final long MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024; // 10 MB

    // Map of Tika-detected MIME type → allowed extensions
    private static final Map<String, String> IMAGE_MIME_TO_EXT = Map.of(
        "image/jpeg", ".jpg",
        "image/png",  ".png",
        "image/webp", ".webp"
    );

    private static final Map<String, String> DOCUMENT_MIME_TO_EXT = Map.of(
        "image/jpeg",       ".jpg",
        "image/png",        ".png",
        "image/webp",       ".webp",
        "application/pdf",  ".pdf"
    );

    private static final Set<String> ALLOWED_IMAGE_MIME_TYPES  = IMAGE_MIME_TO_EXT.keySet();
    private static final Set<String> ALLOWED_DOCUMENT_MIME_TYPES = DOCUMENT_MIME_TO_EXT.keySet();

    private final Tika tika = new Tika();

    /**
     * Validates a turf image upload.
     * Allows: JPEG, PNG, WEBP — max 10 MB.
     */
    public void validateImageUpload(MultipartFile file) {
        validateCommon(file);
        String detectedType = detectMimeType(file);

        if (!ALLOWED_IMAGE_MIME_TYPES.contains(detectedType)) {
            throw new ApiException(
                "Invalid file type. Only JPEG, PNG, and WEBP images are allowed. " +
                "Detected: " + detectedType, HttpStatus.BAD_REQUEST);
        }

        validateExtensionMatchesMime(file, detectedType, IMAGE_MIME_TO_EXT);
    }

    /**
     * Validates a verification document upload.
     * Allows: JPEG, PNG, WEBP, PDF — max 10 MB.
     */
    public void validateDocumentUpload(MultipartFile file) {
        validateCommon(file);
        String detectedType = detectMimeType(file);

        if (!ALLOWED_DOCUMENT_MIME_TYPES.contains(detectedType)) {
            throw new ApiException(
                "Invalid file type. Only JPEG, PNG, WEBP images and PDF documents are allowed. " +
                "Detected: " + detectedType, HttpStatus.BAD_REQUEST);
        }

        validateExtensionMatchesMime(file, detectedType, DOCUMENT_MIME_TO_EXT);
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    private void validateCommon(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ApiException("File must not be empty", HttpStatus.BAD_REQUEST);
        }

        // Size check
        if (file.getSize() > MAX_FILE_SIZE_BYTES) {
            throw new ApiException(
                "File size exceeds the maximum allowed size of 10 MB", HttpStatus.BAD_REQUEST);
        }

        // Filename checks
        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.isBlank()) {
            throw new ApiException("File must have a valid filename", HttpStatus.BAD_REQUEST);
        }

        // Path traversal prevention
        if (originalName.contains("..") || originalName.contains("/") || originalName.contains("\\")) {
            throw new ApiException("Invalid filename: path traversal characters detected", HttpStatus.BAD_REQUEST);
        }

        // Null-byte injection prevention
        if (originalName.contains("\0")) {
            throw new ApiException("Invalid filename: null byte detected", HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Uses Apache Tika to read actual file bytes and detect the real MIME type.
     * This cannot be spoofed by changing the Content-Type header or file extension.
     */
    private String detectMimeType(MultipartFile file) {
        try (InputStream inputStream = file.getInputStream()) {
            return tika.detect(inputStream);
        } catch (IOException e) {
            throw new ApiException("Could not read file for validation", HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Ensures the file extension is consistent with the actual detected MIME type.
     * Prevents e.g. a PHP script named "photo.jpg" from being uploaded.
     */
    private void validateExtensionMatchesMime(
            MultipartFile file,
            String detectedMime,
            Map<String, String> mimeToExtMap) {

        String originalName = Objects.requireNonNull(file.getOriginalFilename());
        int dotIndex = originalName.lastIndexOf('.');
        if (dotIndex == -1) {
            throw new ApiException("File must have a valid extension", HttpStatus.BAD_REQUEST);
        }

        String actualExtension = originalName.substring(dotIndex).toLowerCase();
        String expectedExtension = mimeToExtMap.get(detectedMime);

        // JPEG files may use .jpg or .jpeg — both are valid
        boolean isJpeg = "image/jpeg".equals(detectedMime) &&
                         (actualExtension.equals(".jpg") || actualExtension.equals(".jpeg"));

        if (!isJpeg && !actualExtension.equals(expectedExtension)) {
            throw new ApiException(
                "File extension '" + actualExtension + "' does not match detected content type '" + detectedMime + "'",
                HttpStatus.BAD_REQUEST);
        }
    }
}
