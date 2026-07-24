package com.solapur.turf.service;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.http.FileContent;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.DriveScopes;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class DatabaseBackupService {

    @Value("${spring.datasource.url}")
    private String dbUrl;

    @Value("${spring.datasource.username}")
    private String dbUsername;

    @Value("${spring.datasource.password}")
    private String dbPassword;

    @Value("${google.drive.config.path:google-drive-service-account.json}")
    private String credentialsPath;

    @Value("${google.drive.config.json:}")
    private String credentialsJson;

    @Value("${google.drive.folder.id:}")
    private String driveFolderId;

    @Value("${backup.local.dir:backups}")
    private String localBackupDir;

    /**
     * Runs every night at 2:00 AM.
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void performScheduledBackup() {
        log.info("Starting scheduled nightly database backup...");
        runBackupFlow();
    }

    public String runBackupFlow() {
        File backupFile = null;
        try {
            // 1. Create backup file name with timestamp
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String fileName = "turf_booking_backup_" + timestamp + ".sql";

            File backupDir = new File(localBackupDir);
            if (!backupDir.exists()) {
                backupDir.mkdirs();
            }
            backupFile = new File(backupDir, fileName);

            // 2. Extract DB details from JDBC URL
            // Format: jdbc:postgresql://host:port/database_name
            String host = "localhost";
            String port = "5432";
            String dbName = "turf_booking_db";

            Pattern pattern = Pattern.compile("jdbc:postgresql://([^:/]+)(?::(\\d+))?/([^?]+)");
            Matcher matcher = pattern.matcher(dbUrl);
            if (matcher.find()) {
                host = matcher.group(1);
                if (matcher.group(2) != null) {
                    port = matcher.group(2);
                }
                dbName = matcher.group(3);
            }

            log.info("Backing up database: {} from {}:{}", dbName, host, port);

            // 3. Build pg_dump command
            // We use simple sql format, compatible with standard restores
            List<String> command = List.of(
                    "pg_dump",
                    "-h", host,
                    "-p", port,
                    "-U", dbUsername,
                    "-F", "p", // plain text format
                    "-f", backupFile.getAbsolutePath(),
                    dbName
            );

            ProcessBuilder pb = new ProcessBuilder(command);
            
            // Set PG_PASSWORD environment variable to prevent password prompt hang
            pb.environment().put("PGPASSWORD", dbPassword);
            
            Process process = pb.start();

            // Read error stream if any
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    log.warn("pg_dump: {}", line);
                }
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                throw new RuntimeException("pg_dump failed with exit code: " + exitCode);
            }

            log.info("Backup successfully written to local file: {}", backupFile.getAbsolutePath());

            // 4. Try uploading to Google Drive
            uploadToGoogleDrive(backupFile);
            return "Backup completed successfully. Saved locally: " + fileName;

        } catch (Exception e) {
            log.error("Database backup process failed: {}", e.getMessage(), e);
            return "Backup failed: " + e.getMessage();
        }
    }

    private void uploadToGoogleDrive(File file) {
        if ((credentialsJson == null || credentialsJson.isBlank()) && !new File(credentialsPath).exists()) {
            log.warn("Google Drive credentials not configured. Local backup created, skipping Drive upload.");
            return;
        }

        try {
            // Get credentials from json string or json file path
            InputStream credsStream;
            if (credentialsJson != null && !credentialsJson.isBlank()) {
                credsStream = new ByteArrayInputStream(credentialsJson.getBytes(StandardCharsets.UTF_8));
            } else {
                credsStream = new FileInputStream(credentialsPath);
            }

            GoogleCredentials credentials = GoogleCredentials.fromStream(credsStream)
                    .createScoped(Collections.singleton(DriveScopes.DRIVE_FILE));

            Drive service = new Drive.Builder(
                    GoogleNetHttpTransport.newTrustedTransport(),
                    GsonFactory.getDefaultInstance(),
                    new HttpCredentialsAdapter(credentials))
                    .setApplicationName("Solapur Turf Booking App")
                    .build();

            com.google.api.services.drive.model.File fileMetadata = new com.google.api.services.drive.model.File();
            fileMetadata.setName(file.getName());
            fileMetadata.setMimeType("application/sql");

            if (driveFolderId != null && !driveFolderId.isBlank()) {
                fileMetadata.setParents(Collections.singletonList(driveFolderId));
            }

            FileContent mediaContent = new FileContent("application/sql", file);

            com.google.api.services.drive.model.File uploadedFile = service.files().create(fileMetadata, mediaContent)
                    .setFields("id, parents")
                    .execute();

            log.info("Backup successfully uploaded to Google Drive. File ID: {}", uploadedFile.getId());

        } catch (Exception e) {
            log.error("Failed to upload backup to Google Drive: {}", e.getMessage(), e);
        }
    }
}
