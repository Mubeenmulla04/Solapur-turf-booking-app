package com.solapur.turf.service;

import com.solapur.turf.dto.TournamentDto;
import com.solapur.turf.dto.TournamentRegistrationRequest;
import com.solapur.turf.entity.Team;
import com.solapur.turf.entity.Tournament;
import com.solapur.turf.entity.TournamentRegistration;
import com.solapur.turf.enums.RegistrationStatus;
import com.solapur.turf.enums.TournamentStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.entity.TournamentMatch;
import com.solapur.turf.repository.TeamRepository;
import com.solapur.turf.repository.TournamentRegistrationRepository;
import com.solapur.turf.repository.TournamentRepository;
import com.solapur.turf.repository.TournamentMatchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TournamentService {

    private final TournamentRepository tournamentRepository;
    private final TournamentRegistrationRepository registrationRepository;
    private final TeamRepository teamRepository;
    private final TournamentMatchRepository matchRepository;

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
            com.solapur.turf.enums.SportType sportType = com.solapur.turf.enums.SportType.valueOf(sport.toUpperCase());
            return tournamentRepository.findBySportType(sportType)
                    .stream().map(this::mapToDto).collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid sport type: " + sport, HttpStatus.BAD_REQUEST);
        }
    }

    public List<TournamentMatch> getMatches(UUID tournamentId) {
        return matchRepository.findByTournamentIdOrderByRoundAscMatchNumberAsc(tournamentId);
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
                .sportType(dto.getSportType())
                .format(dto.getFormat())
                .maxTeams(dto.getMaxTeams())
                .entryFeePerTeam(dto.getEntryFeePerTeam())
                .prizePoolWinner(dto.getPrizePoolWinner())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .registrationDeadline(dto.getRegistrationDeadline())
                .registrationStatus(RegistrationStatus.OPEN)
                .tournamentStatus(TournamentStatus.UPCOMING)
                .build();

        Tournament saved = tournamentRepository.save(t);
        return mapToDto(saved);
    }

    public void registerTeam(UUID userId, TournamentRegistrationRequest request) {
        Tournament tournament = tournamentRepository.findById(request.getTournamentId())
                .orElseThrow(() -> new ApiException("Tournament not found", HttpStatus.NOT_FOUND));

        if (tournament.getRegistrationStatus() != RegistrationStatus.OPEN) {
            throw new ApiException("Tournament registration is not open", HttpStatus.BAD_REQUEST);
        }

        Team team = teamRepository.findById(request.getTeamId())
                .orElseThrow(() -> new ApiException("Team not found", HttpStatus.NOT_FOUND));

        if (!team.getCaptain().getId().equals(userId)) {
            throw new ApiException("Only team captains can register", HttpStatus.FORBIDDEN);
        }

        TournamentRegistration registration = TournamentRegistration.builder()
                .tournament(tournament)
                .team(team)
                .status("REGISTERED")
                .registrationDate(LocalDateTime.now())
                .build();

        registrationRepository.save(registration);

        long count = registrationRepository.countByTournamentId(tournament.getId());
        if (count >= tournament.getMaxTeams()) {
            tournament.setRegistrationStatus(RegistrationStatus.CLOSED);
            tournamentRepository.save(tournament);
        }
    }

    @Transactional
    public List<TournamentMatch> generateKnockoutBracket(UUID tournamentId) {
        Tournament tournament = tournamentRepository.findById(tournamentId)
                .orElseThrow(() -> new ApiException("Tournament not found", HttpStatus.NOT_FOUND));

        List<TournamentRegistration> registrations = registrationRepository.findByTournamentId(tournamentId);
        List<Team> teams = registrations.stream().map(TournamentRegistration::getTeam).collect(Collectors.toList());
        Collections.shuffle(teams);

        int numTeams = teams.size();
        int rounds = (int) Math.ceil(Math.log(numTeams) / Math.log(2));
        int totalSlots = (int) Math.pow(2, rounds);

        List<TournamentMatch> r1Matches = new ArrayList<>();
        int numByes = totalSlots - numTeams;
        int numPlaying = numTeams - numByes;

        for (int i = 0; i < numPlaying; i += 2) {
            r1Matches.add(TournamentMatch.builder()
                    .tournament(tournament)
                    .round(1)
                    .matchNumber((i / 2) + 1)
                    .teamA(teams.get(i))
                    .teamB(teams.get(i + 1))
                    .status("UPCOMING")
                    .build());
        }
        
        matchRepository.saveAll(r1Matches);
        tournament.setTournamentStatus(TournamentStatus.ONGOING);
        tournamentRepository.save(tournament);
        return r1Matches;
    }

    @Transactional
    public TournamentMatch updateMatchResult(UUID tournamentId, UUID matchId, Integer scoreA, Integer scoreB) {
        TournamentMatch match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ApiException("Match not found", HttpStatus.NOT_FOUND));

        match.setScoreA(scoreA);
        match.setScoreB(scoreB);
        match.setStatus("COMPLETED");

        Team winner = scoreA > scoreB ? match.getTeamA() : match.getTeamB();
        match.setWinner(winner);

        TournamentMatch updated = matchRepository.save(match);
        promoteWinner(match, winner);
        return updated;
    }

    private void promoteWinner(TournamentMatch completedMatch, Team winner) {
        int currentRound = completedMatch.getRound();
        int currentNum = completedMatch.getMatchNumber();
        int nextRound = currentRound + 1;
        int nextMatchNum = (currentNum + 1) / 2;

        TournamentMatch nextMatch = matchRepository.findByTournamentIdOrderByRoundAscMatchNumberAsc(completedMatch.getTournament().getId())
                .stream()
                .filter(m -> m.getRound() == nextRound && m.getMatchNumber() == nextMatchNum)
                .findFirst()
                .orElseGet(() -> TournamentMatch.builder()
                        .tournament(completedMatch.getTournament())
                        .round(nextRound)
                        .matchNumber(nextMatchNum)
                        .status("UPCOMING")
                        .build());

        if (currentNum % 2 != 0) {
            nextMatch.setTeamA(winner);
        } else {
            nextMatch.setTeamB(winner);
        }

        matchRepository.save(nextMatch);
    }

    private TournamentDto mapToDto(Tournament t) {
        return TournamentDto.builder()
                .id(t.getId())
                .name(t.getName())
                .description(t.getDescription())
                .sportType(t.getSportType())
                .format(t.getFormat())
                .maxTeams(t.getMaxTeams())
                .entryFeePerTeam(t.getEntryFeePerTeam())
                .prizePoolWinner(t.getPrizePoolWinner())
                .prizePoolRunnerUp(t.getPrizePoolRunnerUp())
                .startDate(t.getStartDate())
                .endDate(t.getEndDate())
                .registrationDeadline(t.getRegistrationDeadline())
                .registrationStatus(t.getRegistrationStatus())
                .tournamentStatus(t.getTournamentStatus())
                .bannerUrl(t.getBannerUrl())
                .build();
    }
}
