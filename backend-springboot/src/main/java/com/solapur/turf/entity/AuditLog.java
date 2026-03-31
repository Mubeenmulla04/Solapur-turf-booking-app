package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    private UUID userId;
    private String userEmail;
    private String userRole;
    private String actor; // Can still be used for SYSTEM

    @Column(nullable = false, length = 1000)
    private String action;

    private String entityType;
    private UUID entityId;

    @Column(columnDefinition = "TEXT")
    private String oldValues;

    @Column(columnDefinition = "TEXT")
    private String newValues;

    private String ipAddress;
    private String userAgent;

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    private Boolean success;
    private String errorMessage;
}
