package com.solapur.turf.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.solapur.turf.enums.SportType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class TeamDto {
    private UUID id;

    @NotBlank(message = "Team name is required")
    @Size(min = 2, max = 50, message = "Team name must be between 2 and 50 characters")
    @JsonAlias("teamName")
    private String name;

    @JsonAlias({"teamCode", "team_code"})
    private String inviteCode;

    private UUID captainId;

    @NotNull(message = "Sport type is required")
    @JsonAlias("sport_type")
    private SportType sportType;

    @NotBlank(message = "City is required")
    @Size(max = 100, message = "City must be less than 100 characters")
    @JsonAlias({"homeCity", "home_city"})
    private String city;

    @JsonAlias("logo_url")
    private String logoUrl;

    @Size(max = 500, message = "Description must be less than 500 characters")
    private String description;

    private boolean isActive;
}
