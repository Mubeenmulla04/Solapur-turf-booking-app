package com.solapur.turf.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Health check endpoint — useful for verifying backend is reachable
 * from Flutter before doing auth/booking calls.
 *
 * Usage: GET http://10.0.2.2:8080/api/health
 * Expected: 200 OK { "status": "UP", "timestamp": "..." }
 */
@RestController
@RequestMapping("/api/health")
public class HealthController {

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "Solapur Turf Booking API",
                "timestamp", LocalDateTime.now().toString()));
    }
}
