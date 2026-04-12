package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.JoinTeamRequest;
import com.solapur.turf.dto.TeamDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.TeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/teams")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;

    @GetMapping("/my-teams")
    public ResponseEntity<ApiResponse<List<TeamDto>>> getMyTeams(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<TeamDto> teams = teamService.getMyTeams(userDetails.getUser().getId());
        return ResponseEntity.ok(ApiResponse.success(teams, "Teams fetched successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TeamDto>> getTeam(@PathVariable String id) {
        TeamDto team = teamService.getTeamById(UUID.fromString(id));
        return ResponseEntity.ok(ApiResponse.success(team, "Team fetched successfully"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TeamDto>> createTeam(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody TeamDto data) {
        data.setCaptainId(userDetails.getUser().getId());
        TeamDto created = teamService.createTeam(data);
        return ResponseEntity.ok(ApiResponse.success(created, "Team created successfully"));
    }

    @PostMapping("/join")
    public ResponseEntity<ApiResponse<Object>> joinTeam(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody JoinTeamRequest request) {
        teamService.joinTeam(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(ApiResponse.success(null, "Successfully joined the team"));
    }
}
