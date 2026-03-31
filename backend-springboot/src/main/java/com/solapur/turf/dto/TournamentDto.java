package com.solapur.turf.dto;

import com.solapur.turf.enums.RegistrationStatus;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.enums.TournamentFormat;
import com.solapur.turf.enums.TournamentStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class TournamentDto {
    private UUID id;
    private String name;
    private String description;
    private UUID turfId;
    private SportType sportType;
    private TournamentFormat format;
    private int maxTeams;
    private BigDecimal entryFeePerTeam;
    private BigDecimal prizePoolWinner;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime registrationDeadline;
    private RegistrationStatus registrationStatus;
    private TournamentStatus tournamentStatus;
    private String bannerUrl;
}
