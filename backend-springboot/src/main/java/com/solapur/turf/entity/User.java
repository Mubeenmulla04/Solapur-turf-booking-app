package com.solapur.turf.entity;

import com.solapur.turf.enums.UserRole;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true, nullable = false)
    private String phone;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private boolean isVerified = false;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean isActive = true;

    // --- Profile Stats & Preferences
    @Column(name = "wallet_balance")
    @Builder.Default
    private Double walletBalance = 0.0;

    @Column(name = "loyalty_points")
    @Builder.Default
    private Integer loyaltyPoints = 0;

    @Column(name = "favorite_sports")
    private String favoriteSports;

    @Column(name = "preferred_time_slots")
    private String preferredTimeSlots;

    @Column(name = "fcm_token")
    private String fcmToken;

    // Optional relation mapped by Wallet later
    // @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    // private UserWallet wallet;
}
