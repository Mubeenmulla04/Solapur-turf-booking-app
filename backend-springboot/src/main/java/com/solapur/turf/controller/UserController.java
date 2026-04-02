package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.dto.UserDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserDto> getCurrentUser(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(userService.getUserProfile(userDetails.getUser().getId()));
    }

    @PutMapping("/me")
    public ResponseEntity<UserDto> updateProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody UserDto updateDto) {
        return ResponseEntity.ok(userService.updateUserProfile(userDetails.getUser().getId(), updateDto));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<UserDto>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt,desc") String[] sort,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role) {

        // Convert array to sort
        org.springframework.data.domain.Sort.Direction direction = sort[1].equalsIgnoreCase("desc")
                ? org.springframework.data.domain.Sort.Direction.DESC
                : org.springframework.data.domain.Sort.Direction.ASC;
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(page, size,
                org.springframework.data.domain.Sort.by(direction, sort[0]));

        org.springframework.data.domain.Page<UserDto> users = userService.getAllUsers(pageable, search, role);
        return ResponseEntity.ok(ApiResponse.success(new PageResponse<>(users), "Users retrieved successfully"));
    }

    @GetMapping("/count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Long>> countUsers() {
        return ResponseEntity.ok(ApiResponse.success(userService.countUsers(), "User count retrieved successfully"));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserDto>> getUserById(@PathVariable UUID id) {
        UserDto user = userService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.success(user, "User retrieved successfully"));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserDto>> updateUserStatus(
            @PathVariable UUID id,
            @RequestBody Map<String, Boolean> body) {
        boolean active = body.getOrDefault("isActive", true);
        return ResponseEntity.ok(ApiResponse.success(userService.updateUserStatus(id, active),
                active ? "User activated successfully" : "User suspended successfully"));
    }

    @PatchMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserDto>> updateUserRole(
            @PathVariable UUID id,
            @RequestBody Map<String, String> body) {
        String newRole = body.get("role");
        UserDto user = userService.updateUserRole(id, newRole);
        return ResponseEntity.ok(ApiResponse.success(user, "User role updated successfully"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success(null, "User deleted successfully"));
    }

    @PostMapping("/me/change-password")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, String> body) {
        userService.changePassword(userDetails.getUser().getId(),
                body.get("currentPassword"), body.get("newPassword"));
        return ResponseEntity.ok(ApiResponse.success("OK", "Password changed successfully"));
    }

    @PatchMapping("/me/fcm-token")
    public ResponseEntity<ApiResponse<Object>> updateFcmToken(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, String> body) {
        userService.updateFcmToken(userDetails.getUser().getId(), body.get("fcmToken"));
        return ResponseEntity.ok(ApiResponse.success(null, "FCM token updated successfully"));
    }
}
