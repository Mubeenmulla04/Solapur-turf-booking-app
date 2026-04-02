package com.solapur.turf.repository;

import com.solapur.turf.entity.TournamentMatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TournamentMatchRepository extends JpaRepository<TournamentMatch, UUID> {
    List<TournamentMatch> findByTournamentIdOrderByRoundAscMatchNumberAsc(UUID tournamentId);
}
