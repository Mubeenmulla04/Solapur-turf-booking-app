package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class TournamentRegistrationRequest {
    
    @NotNull(message = "Tournament ID is required")
    private UUID tournamentId;
    
    @NotNull(message = "Team ID is required")
    private UUID teamId;
    
    private String message; // Optional message to tournament organizer
}
