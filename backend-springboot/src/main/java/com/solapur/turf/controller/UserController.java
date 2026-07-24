package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.ChangePasswordRequest;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.dto.UpdateUserProfileRequest;
import com.solapur.turf.dto.UserDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.UserService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        UserDto user = userService.getUserProfile(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(user, "User profile retrieved successfully"));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> updateProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody UpdateUserProfileRequest updateDto) {
        // Map UpdateUserProfileRequest → UserDto using the builder
        UserDto dto = UserDto.builder()
                .fullName(updateDto.getName())
                .email(updateDto.getEmail())
                .phone(updateDto.getPhone())
                .build();
        UserDto user = userService.updateUserProfile(userDetails.getUser().getId(), dto);
        return ResponseEntity.ok(ApiResponse.success(user, "User profile updated successfully"));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<UserDto>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt,desc") String[] sort,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String role) {

        Sort.Direction direction = sort.length > 1 && sort[1].equalsIgnoreCase("asc")
                ? Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sort[0]));

        Page<UserDto> users = userService.getAllUsers(pageable, search, role);
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
            @Valid @RequestBody UserStatusRequest body) {
        return ResponseEntity.ok(ApiResponse.success(
                userService.updateUserStatus(id, body.isActive()),
                body.isActive() ? "User activated successfully" : "User suspended successfully"));
    }

    @PatchMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserDto>> updateUserRole(
            @PathVariable UUID id,
            @Valid @RequestBody UserRoleRequest body) {
        UserDto user = userService.updateUserRole(id, body.getRole());
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
            @Valid @RequestBody ChangePasswordRequest request) {
        userService.changePassword(
                userDetails.getUser().getId(),
                request.getCurrentPassword(),
                request.getNewPassword());
        return ResponseEntity.ok(ApiResponse.success("OK", "Password changed successfully"));
    }

    @PatchMapping("/me/fcm-token")
    public ResponseEntity<ApiResponse<Object>> updateFcmToken(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody FcmTokenRequest body) {
        userService.updateFcmToken(userDetails.getUser().getId(), body.getFcmToken());
        return ResponseEntity.ok(ApiResponse.success(null, "FCM token updated successfully"));
    }

    // ── Inline request DTOs ──────────────────────────────────────────────────

    @Data
    public static class UserStatusRequest {
        private boolean active;
    }

    @Data
    public static class UserRoleRequest {
        @NotBlank(message = "Role is required")
        @Pattern(regexp = "^(USER|OWNER|ADMIN)$", message = "Role must be USER, OWNER, or ADMIN")
        private String role;
    }

    @Data
    public static class FcmTokenRequest {
        @NotBlank(message = "FCM token is required")
        private String fcmToken;
    }
}
