package com.solapur.turf.repository;

import com.solapur.turf.entity.AvailabilitySlot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface AvailabilitySlotRepository extends JpaRepository<AvailabilitySlot, UUID> {
    List<AvailabilitySlot> findByTurfIdAndDateOrderByStartTime(UUID turfId, LocalDate date);

    List<AvailabilitySlot> findByTurfIdAndDateOrderByStartTimeAsc(UUID turfId, LocalDate date);

    List<AvailabilitySlot> findByTurfId(UUID turfId);

    List<AvailabilitySlot> findByTurfIdAndDateBetween(UUID turfId, LocalDate startDate, LocalDate endDate);

    List<AvailabilitySlot> findByTurfIdAndDateBetweenOrderByDateAscStartTimeAsc(UUID turfId, LocalDate startDate, LocalDate endDate);

    List<AvailabilitySlot> findByTurfIdAndDate(UUID turfId, LocalDate date);

    Page<AvailabilitySlot> findByTurfOwnerId(UUID ownerId, Pageable pageable);

    Page<AvailabilitySlot> findByTurfOwnerIdAndDate(UUID ownerId, LocalDate date, Pageable pageable);
}
