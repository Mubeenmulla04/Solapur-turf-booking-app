package com.solapur.turf.service;

import com.solapur.turf.exception.ApiException;
import com.solapur.turf.util.FileUploadValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileStorageService {

    private static final Path STORAGE_ROOT = Paths.get("uploads").toAbsolutePath().normalize();

    private final FileUploadValidator fileUploadValidator;

    @jakarta.annotation.PostConstruct
    public void init() {
        try {
            Files.createDirectories(STORAGE_ROOT);
        } catch (IOException e) {
            throw new RuntimeException("Could not create storage directory", e);
        }
    }

    public String storeFile(MultipartFile file, String subFolder) {
        // Validate subFolder to prevent path injection
        if (subFolder == null || subFolder.contains("..") || subFolder.contains("\\")) {
            throw new ApiException("Invalid storage folder", HttpStatus.BAD_REQUEST);
        }

        // Run full validation using Tika magic-byte detection
        if (subFolder.startsWith("turfs")) {
            fileUploadValidator.validateImageUpload(file);
        } else if (subFolder.startsWith("documents")) {
            fileUploadValidator.validateDocumentUpload(file);
        } else {
            fileUploadValidator.validateImageUpload(file);
        }

        try {
            String originalFileName = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFileName != null && originalFileName.lastIndexOf(".") != -1) {
                fileExtension = originalFileName.substring(originalFileName.lastIndexOf(".")).toLowerCase();
                // Sanitize extension — only alphanumeric chars
                fileExtension = fileExtension.replaceAll("[^a-z0-9.]", "");
            }

            // Always use a random UUID filename — never trust original filename
            String safeFileName = UUID.randomUUID().toString() + fileExtension;

            // Resolve target path and verify it stays inside STORAGE_ROOT
            Path targetFolder = STORAGE_ROOT.resolve(subFolder).normalize();
            if (!targetFolder.startsWith(STORAGE_ROOT)) {
                throw new ApiException("Invalid storage path", HttpStatus.BAD_REQUEST);
            }
            Files.createDirectories(targetFolder);

            Path targetLocation = targetFolder.resolve(safeFileName).normalize();
            if (!targetLocation.startsWith(targetFolder)) {
                throw new ApiException("Invalid file path", HttpStatus.BAD_REQUEST);
            }

            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            return "/api/files/" + subFolder + "/" + safeFileName;

        } catch (IOException ex) {
            throw new ApiException("Could not store file. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
