package com.solapur.turf.repository;

import com.solapur.turf.entity.TournamentRegistration;
import com.solapur.turf.enums.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TournamentRegistrationRepository extends JpaRepository<TournamentRegistration, UUID> {
    List<TournamentRegistration> findByTournamentId(UUID tournamentId);

    List<TournamentRegistration> findByTeamId(UUID teamId);

    Optional<TournamentRegistration> findByTournamentIdAndTeamId(UUID tournamentId, UUID teamId);

    boolean existsByTournamentIdAndTeamId(UUID tournamentId, UUID teamId);

    int countByTournamentIdAndPaymentStatus(UUID tournamentId, PaymentStatus status);
    
    long countByTournamentId(UUID tournamentId);
}
