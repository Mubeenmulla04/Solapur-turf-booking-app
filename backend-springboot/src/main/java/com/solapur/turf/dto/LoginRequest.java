package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank
    private String identifier; // email or phone

    @NotBlank
    private String password;

    // Getter for email/phone compatibility
    public String getEmail() {
        return identifier;
    }

    public String getPhone() {
        return identifier;
    }
}
