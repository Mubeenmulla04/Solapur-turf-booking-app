package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinTeamRequest {
    
    @NotBlank(message = "Invite code is required")
    private String inviteCode;
    
    private String message; // Optional message to the captain
}
