package com.solapur.turf.service;

import com.solapur.turf.exception.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Objects;
import java.util.UUID;

@Service
public class FileStorageService {

    private final Path storageLocation;

    public FileStorageService() {
        // Store in a 'uploads' folder relative to current working directory
        this.storageLocation = Paths.get("uploads").toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.storageLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not create storage directory", e);
        }
    }

    public String storeFile(MultipartFile file, String subFolder) {
        String originalFileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String fileExtension = "";

        try {
            if (originalFileName.contains("..")) {
                throw new ApiException("Invalid filename", HttpStatus.BAD_REQUEST);
            }

            if (originalFileName.lastIndexOf(".") != -1) {
                fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
            }

            // Create a unique filename
            String fileName = UUID.randomUUID().toString() + fileExtension;
            
            Path targetFolder = this.storageLocation.resolve(subFolder);
            Files.createDirectories(targetFolder);

            Path targetLocation = targetFolder.resolve(fileName);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

            // In a real app, you'd return a full URL. 
            // Here we return the relative path for the controller to map.
            return "/api/files/" + subFolder + "/" + fileName;

        } catch (IOException ex) {
            throw new ApiException("Could not store file " + originalFileName + ". Please try again!", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
