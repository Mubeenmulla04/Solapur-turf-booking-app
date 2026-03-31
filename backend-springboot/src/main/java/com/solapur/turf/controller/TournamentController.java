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

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Object>> registerTeam(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody TournamentRegistrationRequest request) {
        tournamentService.registerTeam(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(null, "Team registered successfully"));
    }
}
