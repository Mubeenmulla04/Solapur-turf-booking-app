package com.solapur.turf.dto;

import com.solapur.turf.enums.SportType;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class TeamDto {
    private UUID id;
    private String name;
    private String inviteCode;
    private UUID captainId;
    private SportType sportType;
    private String city;
    private String logoUrl;
    private String description;
    private boolean isActive;
}
