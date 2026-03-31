package com.solapur.turf.repository;

import com.solapur.turf.entity.Tournament;
import com.solapur.turf.enums.RegistrationStatus;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.enums.TournamentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TournamentRepository extends JpaRepository<Tournament, UUID> {
    List<Tournament> findByTournamentStatusNot(TournamentStatus status);

    List<Tournament> findByCreatorId(UUID creatorId);

    List<Tournament> findByRegistrationStatus(RegistrationStatus status);

    List<Tournament> findByTournamentStatus(TournamentStatus status);

    List<Tournament> findBySportType(SportType sportType);
}
