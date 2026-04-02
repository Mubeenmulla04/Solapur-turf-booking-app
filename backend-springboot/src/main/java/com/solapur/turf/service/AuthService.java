package com.solapur.turf.service;

import com.solapur.turf.dto.AuthResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.solapur.turf.dto.ChangePasswordRequest;
import com.solapur.turf.dto.LoginRequest;
import com.solapur.turf.dto.RegisterRequest;
import com.solapur.turf.dto.UserDto;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.entity.User;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.enums.UserRole;
import com.solapur.turf.enums.VerificationStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TurfOwnerRepository;
import com.solapur.turf.repository.UserRepository;
import com.solapur.turf.repository.UserWalletRepository;
import com.solapur.turf.repository.OtpCodeRepository;
import com.solapur.turf.entity.OtpCode;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final UserWalletRepository userWalletRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final OtpCodeRepository otpCodeRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final TokenBlacklistService tokenBlacklistService;
    private final NotificationService notificationService;

    // ─── Register ────────────────────────────────────────────────────────────

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException("Email already registered", HttpStatus.CONFLICT);
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new ApiException("Phone number already registered", HttpStatus.CONFLICT);
        }

        log.info("Registering new user: {} with role: {}", request.getEmail(), request.getRole());

        if (request.getRole() == UserRole.OWNER) {
            validateOwnerFields(request);
        }

        boolean isVerified = request.getRole() == UserRole.USER;
        boolean isActive   = request.getRole() == UserRole.USER;

        User user = User.builder()
                .email(request.getEmail())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .role(request.getRole())
                .isVerified(isVerified)
                .isActive(isActive)
                .build();

        User savedUser = userRepository.save(user);

        // Create wallet for every new user
        UserWallet wallet = UserWallet.builder()
                .user(savedUser)
                .build();
        userWalletRepository.save(wallet);

        // Create TurfOwner profile for OWNER role
        if (request.getRole() == UserRole.OWNER) {
            TurfOwner turfOwner = TurfOwner.builder()
                    .user(savedUser)
                    .businessName(request.getBusinessName())
                    .contactNumber(request.getContactNumber())
                    .addressLine1(request.getAddressLine1())
                    .addressLine2(request.getAddressLine2())
                    .city(request.getCity())
                    .state(request.getState())
                    .pinCode(request.getPinCode())
                    .upiId(request.getUpiId())
                    .bankAccountNumber(request.getBankAccountNumber())
                    .ifscCode(request.getIfscCode())
                    .gstNumber(request.getGstNumber())
                    .panNumber(request.getPanNumber())
                    .verificationStatus(VerificationStatus.PENDING)
                    .isActive(false)
                    .build();
            turfOwnerRepository.save(turfOwner);

            return AuthResponse.builder()
                    .accessToken(null)
                    .refreshToken(null)
                    .tokenType("Bearer")
                    .expiresIn(null)
                    .user(mapToUserDto(savedUser))
                    .message("Registration successful. Your account is pending admin approval.")
                    .build();
        }

        CustomUserDetails userDetails = new CustomUserDetails(savedUser);
        String accessToken  = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtService.getAccessTokenExpirationMs() / 1000)
                .user(mapToUserDto(savedUser))
                .message("Registration successful. Welcome!")
                .build();
    }

    // ─── Login ───────────────────────────────────────────────────────────────

    public AuthResponse login(LoginRequest request) {
        // 1. Fetch user first to check status before Spring Security obscures the reason
        User user = userRepository.findByEmail(request.getIdentifier())
                .orElseGet(() -> userRepository.findByPhone(request.getIdentifier())
                        .orElseThrow(() -> new ApiException("Invalid credentials", HttpStatus.UNAUTHORIZED)));

        // 2. Check specific status triggers
        if (user.getRole() == UserRole.OWNER && !user.isVerified()) {
            throw new ApiException(
                "Your account is pending admin approval. Please wait for confirmation.",
                HttpStatus.FORBIDDEN);
        }

        if (!user.isActive()) {
            throw new ApiException("Your account is currently inactive. Please contact support.", HttpStatus.FORBIDDEN);
        }

        // 3. Perform standard authentication
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            user.getEmail(), // Use canonical email for auth
                            request.getPassword()));
        } catch (AuthenticationException e) {
            log.warn("Authentication failed for user: {}. Reason: {}", user.getEmail(), e.getMessage());
            throw new ApiException("Invalid credentials", HttpStatus.UNAUTHORIZED);
        }

        CustomUserDetails userDetails = new CustomUserDetails(user);
        String accessToken  = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtService.getAccessTokenExpirationMs() / 1000)
                .user(mapToUserDto(user))
                .message("Login successful")
                .build();
    }

    // ─── Refresh Token ───────────────────────────────────────────────────────

    public AuthResponse refreshToken(String refreshToken) {
        String username;
        try {
            username = jwtService.extractUsername(refreshToken);
        } catch (Exception e) {
            throw new ApiException("Invalid or malformed refresh token", HttpStatus.UNAUTHORIZED);
        }

        if (tokenBlacklistService.isBlacklisted(refreshToken)) {
            throw new ApiException("Refresh token has been invalidated", HttpStatus.UNAUTHORIZED);
        }

        CustomUserDetails userDetails = (CustomUserDetails)
                userDetailsService.loadUserByUsername(username);

        if (!jwtService.isTokenValid(refreshToken, userDetails)) {
            throw new ApiException("Refresh token is expired or invalid", HttpStatus.UNAUTHORIZED);
        }

        String newAccessToken  = jwtService.generateToken(userDetails);
        String newRefreshToken = jwtService.generateRefreshToken(userDetails);

        // Blacklist the old refresh token so it can't be reused
        tokenBlacklistService.blacklist(refreshToken,
                jwtService.extractExpirationMillis(refreshToken));

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtService.getAccessTokenExpirationMs() / 1000)
                .user(mapToUserDto(userDetails.getUser()))
                .message("Token refreshed successfully")
                .build();
    }

    // ─── Logout ──────────────────────────────────────────────────────────────

    public void logout(String accessToken) {
        if (accessToken != null && !accessToken.isBlank()) {
            try {
                long expiry = jwtService.extractExpirationMillis(accessToken);
                tokenBlacklistService.blacklist(accessToken, expiry);
            } catch (Exception ignored) {
                // If the token is already malformed / expired, nothing to blacklist
            }
        }
    }

    // ─── Get Current User ────────────────────────────────────────────────────

    public UserDto getCurrentUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        return mapToUserDto(user);
    }

    // ─── Change Password ─────────────────────────────────────────────────────

    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new ApiException("New password and confirmation do not match", HttpStatus.BAD_REQUEST);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new ApiException("Current password is incorrect", HttpStatus.UNAUTHORIZED);
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Transactional
    public void sendForgotPasswordOtp(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException("User not found with this email", HttpStatus.NOT_FOUND));

        // Generate 6 digit OTP
        String otp = String.format("%06d", new java.util.Random().nextInt(999999));

        // Cleanup existing OTPs for this email
        otpCodeRepository.deleteByEmail(email);

        OtpCode otpCode = OtpCode.builder()
                .email(email)
                .code(otp)
                .expiry(java.time.LocalDateTime.now().plusMinutes(10))
                .build();

        otpCodeRepository.save(otpCode);

        // Send Email
        notificationService.sendOtpEmail(email, otp);
        log.info("Reset OTP generated and email sent for: {}", email);
    }

    @Transactional
    public void resetPasswordWithOtp(com.solapur.turf.dto.ResetPasswordRequest request) {
        OtpCode otpCode = otpCodeRepository.findTopByEmailAndCodeAndIsUsedFalseOrderByCreatedAtDesc(
                request.getEmail(), request.getOtp())
                .orElseThrow(() -> new ApiException("Invalid or expired OTP", HttpStatus.BAD_REQUEST));

        if (otpCode.isExpired()) {
            throw new ApiException("OTP has expired. Please request a new one.", HttpStatus.BAD_REQUEST);
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        otpCode.setUsed(true);
        otpCodeRepository.save(otpCode);
        
        log.info("Password reset successful for user: {}", request.getEmail());
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    private void validateOwnerFields(RegisterRequest req) {
        if (isBlank(req.getBusinessName()))  throw new ApiException("Business name is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getContactNumber())) throw new ApiException("Business contact number is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getAddressLine1()))  throw new ApiException("Address is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getCity()))          throw new ApiException("City is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getState()))         throw new ApiException("State is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getPinCode()))       throw new ApiException("PIN code is required", HttpStatus.BAD_REQUEST);
        if (isBlank(req.getUpiId()))         throw new ApiException("UPI ID is required for settlements", HttpStatus.BAD_REQUEST);
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public UserDto mapToUserDto(User user) {
        java.math.BigDecimal balance = userWalletRepository.findByUserId(user.getId())
                .map(com.solapur.turf.entity.UserWallet::getBalance)
                .orElse(java.math.BigDecimal.ZERO);

        return UserDto.builder()
                .userId(user.getId().toString())
                .email(user.getEmail())
                .phone(user.getPhone())
                .fullName(user.getFullName())
                .role(user.getRole())
                .walletBalance(balance)
                .loyaltyPoints(user.getLoyaltyPoints() != null ? user.getLoyaltyPoints() : 0)
                .build();
    }
}
