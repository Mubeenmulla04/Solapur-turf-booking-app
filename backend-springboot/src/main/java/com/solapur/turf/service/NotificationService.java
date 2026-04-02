package com.solapur.turf.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;

@Slf4j
@Service
public class NotificationService {

    @Value("${firebase.config.path:}")
    private String firebaseConfigPath;

    @PostConstruct
    public void initialize() {
        try {
            if (firebaseConfigPath == null || firebaseConfigPath.isEmpty()) {
                log.warn("Firebase config path not provided. Push notifications will be disabled.");
                return;
            }
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(
                            new org.springframework.core.io.ClassPathResource(firebaseConfigPath).getInputStream()))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                log.info("Firebase application has been initialized successfully.");
            }
        } catch (IOException e) {
            log.error("Error initializing Firebase: {}", e.getMessage());
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
}
