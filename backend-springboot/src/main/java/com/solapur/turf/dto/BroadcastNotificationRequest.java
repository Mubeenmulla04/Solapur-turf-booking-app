package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class BroadcastNotificationRequest {
    
    @NotBlank(message = "Title is required")
    @Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
    private String title;
    
    @NotBlank(message = "Message is required")
    @Size(min = 10, max = 500, message = "Message must be between 10 and 500 characters")
    private String message;
    
    @NotBlank(message = "Audience is required")
    @Pattern(regexp = "^(ALL|USERS|OWNERS|ADMIN)$", message = "Audience must be ALL, USERS, OWNERS, or ADMIN")
    private String audience;
}
