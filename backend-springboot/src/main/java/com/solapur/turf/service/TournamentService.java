package com.solapur.turf.service;

import com.solapur.turf.dto.TournamentDto;
import com.solapur.turf.dto.TournamentRegistrationRequest;
import com.solapur.turf.entity.Team;
import com.solapur.turf.entity.Tournament;
import com.solapur.turf.entity.TournamentRegistration;
import com.solapur.turf.enums.RegistrationStatus;
import com.solapur.turf.enums.TournamentStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TeamRepository;
import com.solapur.turf.repository.TournamentRegistrationRepository;
import com.solapur.turf.repository.TournamentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TournamentService {

    private final TournamentRepository tournamentRepository;
    private final TournamentRegistrationRepository registrationRepository;
    private final TeamRepository teamRepository;

    public List<TournamentDto> getActiveTournaments() {
        return tournamentRepository.findByTournamentStatusNot(TournamentStatus.CANCELLED)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<TournamentDto> getOpenTournaments() {
        return tournamentRepository.findByRegistrationStatus(RegistrationStatus.OPEN)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<TournamentDto> getTournamentsByStatus(String status) {
        try {
            TournamentStatus tournamentStatus = TournamentStatus.valueOf(status);
            return tournamentRepository.findByTournamentStatus(tournamentStatus)
                    .stream().map(this::mapToDto).collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid tournament status: " + status, HttpStatus.BAD_REQUEST);
        }
    }

    public List<TournamentDto> getTournamentsBySport(String sport) {
        try {
            com.solapur.turf.enums.SportType sportType = com.solapur.turf.enums.SportType.valueOf(sport);
            return tournamentRepository.findBySportType(sportType)
                    .stream().map(this::mapToDto).collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid sport type: " + sport, HttpStatus.BAD_REQUEST);
        }
    }

    public TournamentDto getTournamentById(UUID id) {
        Tournament tournament = tournamentRepository.findById(id)
                .orElseThrow(() -> new ApiException("Tournament not found", HttpStatus.NOT_FOUND));
        return mapToDto(tournament);
    }

    public TournamentDto createTournament(TournamentDto dto) {
        Tournament t = Tournament.builder()
                .name(dto.getName())
                .description(dto.getDescription())
                .creatorType("ADMIN")
                .creatorId(UUID.fromString("11111111-1111-1111-1111-111111111111"))
                .sportType(
                        dto.getSportType() != null ? dto.getSportType() : com.solapur.turf.enums.SportType.BOX_CRICKET)
                .format(dto.getFormat() != null ? dto.getFormat() : com.solapur.turf.enums.TournamentFormat.KNOCKOUT)
                .maxTeams(dto.getMaxTeams() > 0 ? dto.getMaxTeams() : 16)
                .entryFeePerTeam(
                        dto.getEntryFeePerTeam() != null ? dto.getEntryFeePerTeam() : java.math.BigDecimal.ZERO)
                .prizePoolWinner(
                        dto.getPrizePoolWinner() != null ? dto.getPrizePoolWinner() : java.math.BigDecimal.ZERO)
                .startDate(dto.getStartDate() != null ? dto.getStartDate() : java.time.LocalDate.now().plusDays(7))
                .endDate(dto.getEndDate() != null ? dto.getEndDate() : java.time.LocalDate.now().plusDays(10))
                .registrationDeadline(dto.getRegistrationDeadline() != null ? dto.getRegistrationDeadline()
                        : java.time.LocalDateTime.now().plusDays(5))
                .registrationStatus(RegistrationStatus.OPEN)
                .tournamentStatus(TournamentStatus.UPCOMING)
                .build();

        Tournament saved = tournamentRepository.save(t);
        return mapToDto(saved);
    }

    public void registerTeam(UUID userId, TournamentRegistrationRequest request) {
        // Validate tournament exists and registration is open
        Tournament tournament = tournamentRepository.findById(request.getTournamentId())
                .orElseThrow(() -> new ApiException("Tournament not found", HttpStatus.NOT_FOUND));

        if (tournament.getRegistrationStatus() != RegistrationStatus.OPEN) {
            throw new ApiException("Tournament registration is not open", HttpStatus.BAD_REQUEST);
        }

        if (tournament.getRegistrationDeadline().isBefore(LocalDateTime.now())) {
            throw new ApiException("Registration deadline has passed", HttpStatus.BAD_REQUEST);
        }

        // Check if team exists
        Team team = teamRepository.findById(request.getTeamId())
                .orElseThrow(() -> new ApiException("Team not found", HttpStatus.NOT_FOUND));

        // Verify user is captain of the team (security check)
        if (!team.getCaptain().getId().equals(userId)) {
            throw new ApiException("Only team captains can register for tournaments", HttpStatus.FORBIDDEN);
        }

        // Check if team is already registered
        boolean exists = registrationRepository.existsByTournamentIdAndTeamId(
                request.getTournamentId(), request.getTeamId());
        if (exists) {
            throw new ApiException("Team is already registered for this tournament", HttpStatus.CONFLICT);
        }

        // Check if tournament has reached max teams
        long currentRegistrations = registrationRepository.countByTournamentId(request.getTournamentId());
        if (currentRegistrations >= tournament.getMaxTeams()) {
            throw new ApiException("Tournament has reached maximum team capacity", HttpStatus.BAD_REQUEST);
        }

        // Create registration
        TournamentRegistration registration = TournamentRegistration.builder()
                .tournament(tournament)
                .team(team)
                .status(RegistrationStatus.REGISTERED.name())
                .registrationDate(LocalDateTime.now())
                .build();

        registrationRepository.save(registration);

        // Check if tournament is now full and update status
        long totalRegistrations = registrationRepository.countByTournamentId(request.getTournamentId());
        if (totalRegistrations >= tournament.getMaxTeams()) {
            tournament.setRegistrationStatus(RegistrationStatus.CLOSED);
            tournamentRepository.save(tournament);
        }
    }

    private TournamentDto mapToDto(Tournament tournament) {
        return TournamentDto.builder()
                .id(tournament.getId())
                .name(tournament.getName())
                .description(tournament.getDescription())
                .turfId(tournament.getTurf() != null ? tournament.getTurf().getId() : null)
                .sportType(tournament.getSportType())
                .format(tournament.getFormat())
                .maxTeams(tournament.getMaxTeams())
                .entryFeePerTeam(tournament.getEntryFeePerTeam())
                .prizePoolWinner(tournament.getPrizePoolWinner())
                .startDate(tournament.getStartDate())
                .endDate(tournament.getEndDate())
                .registrationDeadline(tournament.getRegistrationDeadline())
                .registrationStatus(tournament.getRegistrationStatus())
                .tournamentStatus(tournament.getTournamentStatus())
                .bannerUrl(tournament.getBannerUrl())
                .build();
    }
}
