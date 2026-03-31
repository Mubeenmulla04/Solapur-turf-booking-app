package com.solapur.turf.repository;

import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.VerificationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TurfOwnerRepository extends JpaRepository<TurfOwner, UUID> {
    Optional<TurfOwner> findByUserId(UUID userId);
    List<TurfOwner> findByVerificationStatus(VerificationStatus status);
    long countByVerificationStatus(VerificationStatus status);
}
