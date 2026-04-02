package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.TournamentDto;
import com.solapur.turf.dto.TournamentRegistrationRequest;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.TournamentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tournaments")
@RequiredArgsConstructor
public class TournamentController {

    private final TournamentService tournamentService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<TournamentDto>>> getTournaments(
            @RequestParam(required = false) Integer limit,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String sport) {
        List<TournamentDto> tournaments;
        
        if (status != null && !status.isEmpty()) {
            // Filter by status
            tournaments = tournamentService.getTournamentsByStatus(status.toUpperCase());
        } else if (sport != null && !sport.isEmpty()) {
            // Filter by sport type
            tournaments = tournamentService.getTournamentsBySport(sport.toUpperCase());
        } else {
            // Default: get active tournaments
            tournaments = tournamentService.getActiveTournaments();
        }
        
        // Apply limit if specified
        if (limit != null && limit > 0 && tournaments.size() > limit) {
            tournaments = tournaments.subList(0, limit);
        }
        
        return ResponseEntity.ok(ApiResponse.success(tournaments, "Tournaments fetched successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TournamentDto>> getTournament(@PathVariable String id) {
        TournamentDto tournament = tournamentService.getTournamentById(UUID.fromString(id));
        return ResponseEntity.ok(ApiResponse.success(tournament, "Tournament fetched successfully"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TournamentDto>> createTournament(@RequestBody TournamentDto data) {
        TournamentDto created = tournamentService.createTournament(data);
        return ResponseEntity.ok(ApiResponse.created(created, "Tournament created successfully"));
    }

    @PostMapping("/{id}/generate-bracket")
    public ResponseEntity<ApiResponse<Object>> generateBracket(@PathVariable String id) {
        tournamentService.generateKnockoutBracket(UUID.fromString(id));
        return ResponseEntity.ok(ApiResponse.success(null, "Bracket generated successfully"));
    }

    @GetMapping("/{id}/matches")
    public ResponseEntity<ApiResponse<List<com.solapur.turf.entity.TournamentMatch>>> getMatches(@PathVariable String id) {
        // Simple entity return for now
        return ResponseEntity.ok(ApiResponse.success(tournamentService.getMatches(UUID.fromString(id)), "Matches fetched"));
    }

    @PostMapping("/{id}/matches/{matchId}/score")
    public ResponseEntity<ApiResponse<Object>> updateScore(
            @PathVariable String id,
            @PathVariable String matchId,
            @RequestParam Integer scoreA,
            @RequestParam Integer scoreB) {
        tournamentService.updateMatchResult(UUID.fromString(id), UUID.fromString(matchId), scoreA, scoreB);
        return ResponseEntity.ok(ApiResponse.success(null, "Score updated"));
    }
}
