package com.solapur.turf.dto;

import com.solapur.turf.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RegisterRequest {

    // ── Basic account fields (required for all roles) ──────────────────────
    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String phone;

    @NotBlank
    private String password;

    @NotBlank
    private String fullName;

    @NotNull
    private UserRole role;

    // ── Owner-only business fields (required when role = OWNER) ─────────────
    // Validated manually in AuthService when role == OWNER

    private String businessName;       // Required for OWNER
    private String contactNumber;      // Required for OWNER (business contact)
    private String addressLine1;       // Required for OWNER
    private String addressLine2;       // Optional
    private String city;               // Required for OWNER
    private String state;              // Required for OWNER
    private String pinCode;            // Required for OWNER
    private String upiId;             // Required for OWNER (for settlements)

    // Optional financials
    private String bankAccountNumber;
    private String ifscCode;
    private String gstNumber;
    private String panNumber;
}
