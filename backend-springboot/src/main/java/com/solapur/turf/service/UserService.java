package com.solapur.turf.service;

import com.solapur.turf.dto.UserDto;
import com.solapur.turf.entity.User;
import com.solapur.turf.enums.UserRole;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;
import java.util.List;

import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final com.solapur.turf.repository.UserWalletRepository userWalletRepository;
    private final PasswordEncoder passwordEncoder;
    private final org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    public UserDto getUserProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        return mapToUserDto(user);
    }

    public UserDto updateUserProfile(UUID userId, UserDto updateDto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

        if (updateDto.getFullName() != null) {
            user.setFullName(updateDto.getFullName());
        }

        if (updateDto.getPhone() != null) {
            user.setPhone(updateDto.getPhone());
        }

        if (updateDto.getFavoriteSports() != null) {
            user.setFavoriteSports(updateDto.getFavoriteSports());
        }

        if (updateDto.getPreferredTimeSlots() != null) {
            user.setPreferredTimeSlots(updateDto.getPreferredTimeSlots());
        }

        if (updateDto.getFcmToken() != null) {
            user.setFcmToken(updateDto.getFcmToken());
        }

        userRepository.save(user);
        return mapToUserDto(user);
    }

    public UserDto updateUserStatus(UUID userId, boolean isActive) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        user.setActive(isActive);
        userRepository.save(user);
        return mapToUserDto(user);
    }

    public void changePassword(UUID userId, String currentPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new ApiException("Current password is incorrect", HttpStatus.BAD_REQUEST);
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new ApiException("New password must be at least 6 characters", HttpStatus.BAD_REQUEST);
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    private UserDto mapToUserDto(User user) {
        java.math.BigDecimal balance = userWalletRepository.findByUserId(user.getId())
                .map(com.solapur.turf.entity.UserWallet::getBalance)
                .orElse(java.math.BigDecimal.ZERO);

        return UserDto.builder()
                .userId(user.getId().toString())
                .email(user.getEmail())
                .phone(user.getPhone())
                .fullName(user.getFullName())
                .role(user.getRole())
                .isActive(user.isActive())
                .walletBalance(balance)
                .loyaltyPoints(user.getLoyaltyPoints() != null ? user.getLoyaltyPoints() : 0)
                .favoriteSports(user.getFavoriteSports())
                .preferredTimeSlots(user.getPreferredTimeSlots())
                .fcmToken(user.getFcmToken())
                .build();
    }

    public long countUsers() {
        return userRepository.count();
    }

    public Page<UserDto> getAllUsers(Pageable pageable) {
        return userRepository.findAll(pageable).map(this::mapToUserDto);
    }

    public Page<UserDto> getAllUsers(Pageable pageable, String search, String role) {
        Specification<User> spec = Specification.where(null);
        
        if (search != null && !search.trim().isEmpty()) {
            spec = spec.and((root, query, cb) -> 
                cb.or(
                    cb.like(cb.lower(root.get("email")), "%" + search.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("fullName")), "%" + search.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("phone")), "%" + search.toLowerCase() + "%")
                )
            );
        }
        
        if (role != null && !role.trim().isEmpty()) {
            try {
                UserRole userRole = UserRole.valueOf(role.toUpperCase());
                spec = spec.and((root, query, cb) -> cb.equal(root.get("role"), userRole));
            } catch (IllegalArgumentException e) {
                // Invalid role, ignore filter
            }
        }
        
        return userRepository.findAll(pageable).map(this::mapToUserDto);
    }

    public UserDto getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        return mapToUserDto(user);
    }

    public UserDto updateUserRole(UUID userId, String newRole) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        
        if (newRole == null || newRole.trim().isEmpty()) {
            throw new ApiException("Role cannot be null or empty", HttpStatus.BAD_REQUEST);
        }

        try {
            UserRole role = UserRole.valueOf(newRole.trim().toUpperCase());
            user.setRole(role);
            userRepository.save(user);
            return mapToUserDto(user);
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid role: " + newRole, HttpStatus.BAD_REQUEST);
        }
    }

    @Transactional
    public void deleteUser(UUID id) {
        if (!userRepository.existsById(id)) {
            throw new ApiException("User not found", HttpStatus.NOT_FOUND);
        }

        // 1. Get owner ID if exists
        UUID ownerId = null;
        try {
            ownerId = jdbcTemplate.queryForObject(
                "SELECT id FROM turf_owners WHERE user_id = ?",
                new Object[]{id},
                UUID.class
            );
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            // Not an owner
        }

        if (ownerId != null) {
            // Delete owner-related data
            // a. Find all turf IDs owned by this owner
            List<UUID> turfIds = jdbcTemplate.query(
                "SELECT id FROM turf_listings WHERE owner_id = ?",
                new Object[]{ownerId},
                (rs, rowNum) -> (UUID) rs.getObject("id")
            );

            for (UUID turfId : turfIds) {
                jdbcTemplate.update("DELETE FROM availability_slots WHERE turf_id = ?", turfId);
                jdbcTemplate.update("DELETE FROM turf_operating_hours WHERE turf_id = ?", turfId);
                jdbcTemplate.update("DELETE FROM turf_images WHERE turf_id = ?", turfId);
                
                // Get bookings for this turf to delete their dependents
                List<UUID> bookingIds = jdbcTemplate.query(
                    "SELECT id FROM bookings WHERE turf_id = ?",
                    new Object[]{turfId},
                    (rs, rowNum) -> (UUID) rs.getObject("id")
                );
                for (UUID bookingId : bookingIds) {
                    jdbcTemplate.update("DELETE FROM refunds WHERE booking_id = ?", bookingId);
                    jdbcTemplate.update("DELETE FROM transactions WHERE booking_id = ?", bookingId);
                }
                jdbcTemplate.update("DELETE FROM bookings WHERE turf_id = ?", turfId);
                jdbcTemplate.update("DELETE FROM reviews WHERE turf_id = ?", turfId);
            }

            // Delete turfs
            jdbcTemplate.update("DELETE FROM turf_listings WHERE owner_id = ?", ownerId);

            // Delete settlements
            jdbcTemplate.update("DELETE FROM settlements WHERE owner_id = ?", ownerId);

            // Delete tournaments created by this owner
            jdbcTemplate.update("DELETE FROM tournaments WHERE creator_id = ? AND creator_type = 'OWNER'", ownerId);

            // Delete owner profile
            jdbcTemplate.update("DELETE FROM turf_owners WHERE id = ?", ownerId);
        }

        // 2. Delete user-specific data (for both customers and owners)
        UUID walletId = null;
        try {
            walletId = jdbcTemplate.queryForObject(
                "SELECT id FROM user_wallets WHERE user_id = ?",
                new Object[]{id},
                UUID.class
            );
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {}

        if (walletId != null) {
            jdbcTemplate.update("DELETE FROM wallet_transactions WHERE wallet_id = ?", walletId);
            jdbcTemplate.update("DELETE FROM user_wallets WHERE id = ?", walletId);
        }

        // Get bookings by this user to delete their dependents
        List<UUID> userBookingIds = jdbcTemplate.query(
            "SELECT id FROM bookings WHERE user_id = ?",
            new Object[]{id},
            (rs, rowNum) -> (UUID) rs.getObject("id")
        );
        for (UUID bookingId : userBookingIds) {
            jdbcTemplate.update("DELETE FROM refunds WHERE booking_id = ?", bookingId);
            jdbcTemplate.update("DELETE FROM transactions WHERE booking_id = ?", bookingId);
        }
        jdbcTemplate.update("DELETE FROM bookings WHERE user_id = ?", id);

        // Delete team dependencies
        jdbcTemplate.update("DELETE FROM team_members WHERE user_id = ?", id);
        
        List<UUID> captainedTeamIds = jdbcTemplate.query(
            "SELECT id FROM teams WHERE captain_id = ?",
            new Object[]{id},
            (rs, rowNum) -> (UUID) rs.getObject("id")
        );
        for (UUID teamId : captainedTeamIds) {
            jdbcTemplate.update("DELETE FROM team_members WHERE team_id = ?", teamId);
            jdbcTemplate.update("DELETE FROM tournament_registrations WHERE team_id = ?", teamId);
        }
        jdbcTemplate.update("DELETE FROM teams WHERE captain_id = ?", id);

        jdbcTemplate.update("DELETE FROM refunds WHERE user_id = ?", id);
        jdbcTemplate.update("DELETE FROM transactions WHERE user_id = ?", id);
        jdbcTemplate.update("DELETE FROM reviews WHERE user_id = ?", id);
        jdbcTemplate.update("DELETE FROM audit_logs WHERE user_id = ?", id);

        // Finally, delete the user
        jdbcTemplate.update("DELETE FROM users WHERE id = ?", id);
    }

    public void updateFcmToken(UUID userId, String fcmToken) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }
}
