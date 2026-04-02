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

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

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
        return UserDto.builder()
                .userId(user.getId().toString())
                .email(user.getEmail())
                .phone(user.getPhone())
                .fullName(user.getFullName())
                .role(user.getRole())
                .isActive(user.isActive())
                .walletBalance(user.getWalletBalance() != null ? user.getWalletBalance() : 0.0)
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
        
        try {
            UserRole role = UserRole.valueOf(newRole.toUpperCase());
            user.setRole(role);
            userRepository.save(user);
            return mapToUserDto(user);
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid role: " + newRole, HttpStatus.BAD_REQUEST);
        }
    }

    public void deleteUser(UUID id) {
        if (!userRepository.existsById(id)) {
            throw new ApiException("User not found", HttpStatus.NOT_FOUND);
        }
        userRepository.deleteById(id);
    }

    public void updateFcmToken(UUID userId, String fcmToken) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }
}
