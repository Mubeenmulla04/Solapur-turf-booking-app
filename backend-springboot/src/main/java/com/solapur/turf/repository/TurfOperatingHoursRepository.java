package com.solapur.turf.repository;

import com.solapur.turf.entity.TurfOperatingHours;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TurfOperatingHoursRepository extends JpaRepository<TurfOperatingHours, UUID> {
    List<TurfOperatingHours> findByTurfId(UUID turfId);
    void deleteByTurfId(UUID turfId);
}
