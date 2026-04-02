package com.solapur.turf.repository;

import com.solapur.turf.entity.Booking;
import com.solapur.turf.enums.BookingStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    @Query(value = "SELECT b FROM Booking b JOIN FETCH b.turf WHERE b.user.id = :userId",
           countQuery = "SELECT COUNT(b) FROM Booking b WHERE b.user.id = :userId")
    Page<Booking> findByUserId(@Param("userId") UUID userId, Pageable pageable);

    @Query(value = "SELECT b FROM Booking b JOIN FETCH b.turf WHERE b.turf.id = :turfId",
           countQuery = "SELECT COUNT(b) FROM Booking b WHERE b.turf.id = :turfId")
    Page<Booking> findByTurfId(@Param("turfId") UUID turfId, Pageable pageable);

    @Query(value = "SELECT b FROM Booking b JOIN FETCH b.turf WHERE b.turf.owner.id = :ownerId",
           countQuery = "SELECT COUNT(b) FROM Booking b WHERE b.turf.owner.id = :ownerId")
    Page<Booking> findByTurfOwnerId(@Param("ownerId") UUID ownerId, Pageable pageable);

    @Query("SELECT b FROM Booking b WHERE b.turf.owner.id = :ownerId")
    List<Booking> findAllByTurfOwnerId(@Param("ownerId") UUID ownerId);

    Page<Booking> findByBookingStatus(BookingStatus status, Pageable pageable);

    // ── Conflict detection (application-level) ────────────────────────────────
    List<Booking> findByTurfIdAndBookingDateAndBookingStatusNot(
            UUID turfId, LocalDate bookingDate, BookingStatus status);

    /**
     * Pessimistic write lock on all active bookings for a turf+date.
     * Called inside @Transactional before inserting a new booking to prevent
     * concurrent double-bookings that would slip past the application-level check.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT b FROM Booking b WHERE b.turf.id = :turfId " +
           "AND b.bookingDate = :date " +
           "AND b.bookingStatus <> com.solapur.turf.enums.BookingStatus.CANCELLED")
    List<Booking> findByTurfIdAndDateForUpdate(
            @Param("turfId") UUID turfId,
            @Param("date") LocalDate date);

    // ── Settlement-specific queries ───────────────────────────────────────────
    List<Booking> findByTurfOwnerIdAndBookingDateBetweenAndBookingStatus(
            UUID ownerId, LocalDate startDate, LocalDate endDate, BookingStatus status);

    boolean existsByUserIdAndTurfIdAndBookingStatus(UUID userId, UUID turfId, BookingStatus status);
}
