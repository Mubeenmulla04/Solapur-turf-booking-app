package com.solapur.turf.service;

import com.solapur.turf.dto.JoinTeamRequest;
import com.solapur.turf.dto.TeamDto;
import com.solapur.turf.entity.Team;
import com.solapur.turf.entity.TeamMember;
import com.solapur.turf.entity.User;
import com.solapur.turf.enums.TeamMemberRole;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TeamMemberRepository;
import com.solapur.turf.repository.TeamRepository;
import com.solapur.turf.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final TeamMemberRepository teamMemberRepository;

    public List<TeamDto> getTeamsByCaptain(UUID captainId) {
        return teamRepository.findByCaptainIdAndIsActiveTrue(captainId)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public TeamDto getTeamById(UUID teamId) {
        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ApiException("Team not found", HttpStatus.NOT_FOUND));
        return mapToDto(team);
    }

    public TeamDto createTeam(TeamDto dto) {
        User captain = userRepository.findById(dto.getCaptainId())
                .orElseThrow(() -> new ApiException("User/Captain not found", HttpStatus.NOT_FOUND));

        Team newTeam = Team.builder()
                .name(dto.getName())
                .captain(captain)
                .sportType(dto.getSportType())
                .city(dto.getCity())
                .logoUrl(dto.getLogoUrl())
                .description(dto.getDescription())
                .isActive(true)
                .build();

        Team saved = teamRepository.save(newTeam);
        return mapToDto(saved);
    }

    public void joinTeam(UUID userId, JoinTeamRequest request) {
        // Find team by invite code
        Team team = teamRepository.findByInviteCodeAndIsActiveTrue(request.getInviteCode())
                .orElseThrow(() -> new ApiException("Invalid invite code or team not found", HttpStatus.NOT_FOUND));

        // Check if user is already a member
        if (teamMemberRepository.existsByTeamIdAndUserId(team.getId(), userId)) {
            throw new ApiException("You are already a member of this team", HttpStatus.CONFLICT);
        }

        // Check if user is trying to join their own team
        if (team.getCaptain().getId().equals(userId)) {
            throw new ApiException("You are the captain of this team", HttpStatus.BAD_REQUEST);
        }

        // Get user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

        // Add team member
        TeamMember teamMember = TeamMember.builder()
                .team(team)
                .user(user)
                .role(TeamMemberRole.MEMBER)
                .build();

        teamMemberRepository.save(teamMember);
    }

    private TeamDto mapToDto(Team team) {
        return TeamDto.builder()
                .id(team.getId())
                .name(team.getName())
                .inviteCode(team.getInviteCode())
                .captainId(team.getCaptain().getId())
                .sportType(team.getSportType())
                .city(team.getCity())
                .logoUrl(team.getLogoUrl())
                .description(team.getDescription())
                .isActive(team.isActive())
                .build();
    }
}
