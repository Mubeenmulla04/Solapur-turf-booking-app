package com.solapur.turf.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateUserProfileRequest {
    
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Invalid Indian phone number")
    private String phone;
    
    @Size(max = 500, message = "Bio must be less than 500 characters")
    private String bio;
    
    @Size(max = 200, message = "Address must be less than 200 characters")
    private String address;
    
    @Size(max = 100, message = "City must be less than 100 characters")
    private String city;
}
