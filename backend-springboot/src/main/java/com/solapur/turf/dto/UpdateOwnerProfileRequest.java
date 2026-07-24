package com.solapur.turf.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateOwnerProfileRequest {
    
    @Size(min = 2, max = 100, message = "Business name must be between 2 and 100 characters")
    private String businessName;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Invalid Indian phone number")
    private String phone;
    
    @Size(max = 1000, message = "Description must be less than 1000 characters")
    private String description;
    
    @Size(max = 200, message = "Address must be less than 200 characters")
    private String address;
    
    @Size(max = 100, message = "City must be less than 100 characters")
    private String city;
    
    @Pattern(regexp = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$", message = "Invalid PAN number format")
    private String panNumber;
    
    @Pattern(regexp = "^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9]{1}[A-Z]{1}[0-9]{1}$", message = "Invalid GST number format")
    private String gstNumber;
    
    @Size(max = 34, message = "Bank account number must be less than 34 characters")
    @Pattern(regexp = "^[0-9]+$", message = "Bank account number must contain only digits")
    private String bankAccountNumber;
    
    @Pattern(regexp = "^[A-Z]{4}0[A-Z0-9]{6}$", message = "Invalid IFSC code format")
    private String ifscCode;
    
    @Size(max = 100, message = "Bank name must be less than 100 characters")
    private String bankName;
}
