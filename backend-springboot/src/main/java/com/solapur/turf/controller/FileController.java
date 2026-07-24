package com.solapur.turf.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Set;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {

    // Whitelist of allowed subfolder types — prevents accessing arbitrary directories
    private static final Set<String> ALLOWED_TYPES = Set.of("turfs", "documents", "avatars");

    // Only allow safe filenames: UUID format + known image/pdf extensions
    private static final Pattern SAFE_FILENAME = Pattern.compile(
        "^[a-f0-9\\-]{36}\\.(jpg|jpeg|png|webp|pdf)$", Pattern.CASE_INSENSITIVE);

    // Only allow UUID-format subfolder IDs
    private static final Pattern SAFE_ID = Pattern.compile(
        "^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$",
        Pattern.CASE_INSENSITIVE);

    @GetMapping("/{type}/{id}/{fileName:.+}")
    public ResponseEntity<Resource> getFile(
            @PathVariable String type,
            @PathVariable String id,
            @PathVariable String fileName,
            HttpServletRequest request) {

        // ── 1. Validate type against whitelist ─────────────────────────────
        if (!ALLOWED_TYPES.contains(type)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        // ── 2. Validate ID is UUID format ──────────────────────────────────
        if (!SAFE_ID.matcher(id).matches()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        // ── 3. Validate filename format (UUID.ext only) ────────────────────
        if (!SAFE_FILENAME.matcher(fileName).matches()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        try {
            Path basePath = Paths.get("uploads").toAbsolutePath().normalize();
            Path filePath = basePath.resolve(type).resolve(id).resolve(fileName)
                                    .normalize().toAbsolutePath();

            // ── 4. Strict path traversal check ────────────────────────────
            if (!filePath.startsWith(basePath)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }

            Resource resource = new UrlResource(filePath.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            // ── 5. Detect content type safely ─────────────────────────────
            String contentType = request.getServletContext()
                                        .getMimeType(resource.getFile().getAbsolutePath());
            if (contentType == null) {
                contentType = "application/octet-stream";
            }

            // ── 6. Force download for PDFs; inline display for images ──────
            String disposition = contentType.startsWith("image/")
                    ? "inline; filename=\"" + fileName + "\""
                    : "attachment; filename=\"" + fileName + "\"";

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, disposition)
                    // Prevent browsers from executing file content as scripts
                    .header("X-Content-Type-Options", "nosniff")
                    .body(resource);

        } catch (IOException ex) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
