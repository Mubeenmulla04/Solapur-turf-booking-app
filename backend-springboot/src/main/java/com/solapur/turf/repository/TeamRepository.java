package com.solapur.turf.repository;

import com.solapur.turf.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TeamRepository extends JpaRepository<Team, UUID> {
    List<Team> findByCaptainIdAndIsActiveTrue(UUID captainId);

    boolean existsByNameIgnoreCase(String name);

    Optional<Team> findByInviteCodeAndIsActiveTrue(String inviteCode);
}
