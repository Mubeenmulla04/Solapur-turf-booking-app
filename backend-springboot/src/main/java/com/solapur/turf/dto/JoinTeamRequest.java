package com.solapur.turf.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinTeamRequest {

    /** Accepts "inviteCode" (legacy) and "teamCode" (Flutter client). */
    @NotBlank(message = "Invite code is required")
    @JsonAlias("teamCode")
    private String inviteCode;

    private String message; // Optional message to the captain
}
