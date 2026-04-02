package com.solapur.turf.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;

@Slf4j
@Service
public class NotificationService {

    private final JavaMailSender mailSender;

    public NotificationService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    @Value("${firebase.config.path:}")
    private String firebaseConfigPath;

    @Value("${firebase.config.json:}")
    private String firebaseConfigJson;

    @PostConstruct
    public void initialize() {
        try {
            GoogleCredentials credentials = null;

            // 1. Try to load from provided JSON string (Environment Variable)
            if (firebaseConfigJson != null && !firebaseConfigJson.isBlank()) {
                credentials = GoogleCredentials.fromStream(
                        new java.io.ByteArrayInputStream(firebaseConfigJson.getBytes()));
                log.info("Loading Firebase credentials from provided JSON string.");
            } 
            // 2. Try to load from Classpath file
            else if (firebaseConfigPath != null && !firebaseConfigPath.isBlank()) {
                org.springframework.core.io.Resource resource = new org.springframework.core.io.ClassPathResource(firebaseConfigPath);
                if (resource.exists()) {
                    credentials = GoogleCredentials.fromStream(resource.getInputStream());
                    log.info("Loading Firebase credentials from file: {}", firebaseConfigPath);
                } else {
                    log.warn("Firebase config file not found at: {}. Skipping initialization.", firebaseConfigPath);
                    return;
                }
            } else {
                log.warn("No Firebase configuration provided. Push notifications will be disabled.");
                return;
            }

            if (credentials != null) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(credentials)
                        .build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                    log.info("Firebase application has been initialized successfully.");
                }
            }
        } catch (Exception e) {
            log.error("Failed to initialize Firebase: {}", e.getMessage());
        }
    }

    public void sendPushNotification(String token, String title, String body) {
        if (token == null || token.isEmpty()) {
            log.warn("No FCM token provided for notification: {}", title);
            return;
        }

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                log.warn("Firebase not initialized. Cannot send notification: {}", title);
                return;
            }

            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putData("click_action", "FLUTTER_NOTIFICATION_CLICK")
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Successfully sent message: " + response);
        } catch (Exception e) {
            log.error("Error sending FCM notification: {}", e.getMessage());
        }
    }

    public void sendOtpEmail(String to, String otp) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject("Solapur Turf - Reset Password OTP");
            message.setText("Your OTP for resetting your password is: " + otp + 
                "\n\nThis OTP is valid for 10 minutes. Do not share it with anyone.");
            
            mailSender.send(message);
            log.info("OTP email sent successfully to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send OTP email to {}: {}", to, e.getMessage());
        }
    }
}
