package com.solapur.turf.repository;

import com.solapur.turf.entity.TurfImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TurfImageRepository extends JpaRepository<TurfImage, UUID> {
    List<TurfImage> findByTurfIdOrderByDisplayOrderAsc(UUID turfId);
}
