package com.solapur.turf.repository;

import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.enums.SportType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface TurfListingRepository extends JpaRepository<TurfListing, UUID>,
        JpaSpecificationExecutor<TurfListing> {

    List<TurfListing> findByIsActiveTrueAndIsVerifiedTrue();

    List<TurfListing> findByOwnerId(UUID ownerId);

    List<TurfListing> findByCityIgnoreCaseAndIsActiveTrueAndIsVerifiedTrue(String city);

    List<TurfListing> findBySportTypeAndIsActiveTrueAndIsVerifiedTrue(SportType sportType);

    @Query(value = "SELECT *, (6371.0 * acos(cos(radians(:userLat)) * cos(radians(latitude)) * cos(radians(longitude) - radians(:userLng)) + sin(radians(:userLat)) * sin(radians(latitude)))) AS distance " +
                   "FROM turf_listings " +
                   "WHERE is_active = true AND is_verified = true " +
                   "ORDER BY distance ASC", 
           nativeQuery = true)
    List<TurfListing> findNearestTurfs(@Param("userLat") double userLat, @Param("userLng") double userLng);

    /**
     * DB-level filtered query — all filters are pushed to the WHERE clause.
     * Pageable handles LIMIT/OFFSET at the database level, not in Java memory.
     */
    @Query(value = "SELECT t FROM TurfListing t WHERE t.isActive = true AND t.isVerified = true " +
                   "AND (:city IS NULL OR LOWER(t.city) = LOWER(CAST(:city AS string))) " +
                   "AND (:sportType IS NULL OR t.sportType = :sportType) " +
                   "AND (:search IS NULL OR LOWER(t.name) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%')) " +
                   "     OR LOWER(t.description) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%')) " +
                   "     OR LOWER(t.address) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%'))) " +
                   "AND (:minPrice IS NULL OR t.hourlyRate >= :minPrice) " +
                   "AND (:maxPrice IS NULL OR t.hourlyRate <= :maxPrice)",
           countQuery = "SELECT COUNT(t) FROM TurfListing t WHERE t.isActive = true AND t.isVerified = true " +
                        "AND (:city IS NULL OR LOWER(t.city) = LOWER(CAST(:city AS string))) " +
                        "AND (:sportType IS NULL OR t.sportType = :sportType) " +
                        "AND (:search IS NULL OR LOWER(t.name) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%')) " +
                        "     OR LOWER(t.description) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%')) " +
                        "     OR LOWER(t.address) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%'))) " +
                        "AND (:minPrice IS NULL OR t.hourlyRate >= :minPrice) " +
                        "AND (:maxPrice IS NULL OR t.hourlyRate <= :maxPrice)")
    Page<TurfListing> findFiltered(
            @Param("city") String city,
            @Param("sportType") SportType sportType,
            @Param("search") String search,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice,
            Pageable pageable);
}

