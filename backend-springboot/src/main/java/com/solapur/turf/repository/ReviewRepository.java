package com.solapur.turf.repository;

import com.solapur.turf.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByTurfIdOrderByCreatedAtDesc(UUID turfId);
    boolean existsByUserIdAndTurfId(UUID userId, UUID turfId);
    long countByTurfId(UUID turfId);
}
