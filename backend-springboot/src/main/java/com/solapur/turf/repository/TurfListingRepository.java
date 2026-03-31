package com.solapur.turf.repository;

import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.enums.SportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TurfListingRepository extends JpaRepository<TurfListing, UUID> {
    List<TurfListing> findByIsActiveTrueAndIsVerifiedTrue();

    List<TurfListing> findByOwnerId(UUID ownerId);

    List<TurfListing> findByCityIgnoreCaseAndIsActiveTrueAndIsVerifiedTrue(String city);

    List<TurfListing> findBySportTypeAndIsActiveTrueAndIsVerifiedTrue(SportType sportType);
}
