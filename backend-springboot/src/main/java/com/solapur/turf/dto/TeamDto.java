package com.solapur.turf.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.solapur.turf.enums.SportType;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class TeamDto {
    private UUID id;

    /** Accepts both "name" (legacy) and "teamName" (Flutter client). */
    @JsonAlias("teamName")
    private String name;

    /** Serialized as "inviteCode". Flutter join screen uses "teamCode". */
    @JsonAlias({"teamCode", "team_code"})
    private String inviteCode;

    private UUID captainId;

    @JsonAlias("sport_type")
    private SportType sportType;

    /** Accepts both "city" (backend) and "homeCity" (Flutter client). */
    @JsonAlias({"homeCity", "home_city"})
    private String city;

    @JsonAlias("logo_url")
    private String logoUrl;

    private String description;
    private boolean isActive;
}
