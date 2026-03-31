package com.solapur.turf.repository;

import com.solapur.turf.entity.Refund;
import com.solapur.turf.enums.RefundStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface RefundRepository extends JpaRepository<Refund, UUID> {
    
    List<Refund> findByUserIdOrderByRequestedAtDesc(UUID userId);
    
    Page<Refund> findByUserIdOrderByRequestedAtDesc(UUID userId, Pageable pageable);
    
    List<Refund> findByBookingId(UUID bookingId);
    
    Page<Refund> findByStatusOrderByRequestedAtDesc(RefundStatus status, Pageable pageable);
    
    @Query("SELECT r FROM Refund r WHERE (:status IS NULL OR r.status = :status) " +
           "AND (:startDate IS NULL OR r.requestedAt >= :startDate) " +
           "AND (:endDate IS NULL OR r.requestedAt <= :endDate) " +
           "ORDER BY r.requestedAt DESC")
    Page<Refund> findWithFilters(@Param("status") RefundStatus status,
                                @Param("startDate") LocalDateTime startDate,
                                @Param("endDate") LocalDateTime endDate,
                                Pageable pageable);
    
    @Query("SELECT COUNT(r) FROM Refund r WHERE r.status = :status")
    long countByStatus(@Param("status") RefundStatus status);
    
    @Query("SELECT COALESCE(SUM(r.approvedAmount), 0) FROM Refund r WHERE r.status = 'PROCESSED'")
    java.math.BigDecimal sumProcessedRefunds();
    
    @Query("SELECT r FROM Refund r WHERE r.status = 'REQUESTED' ORDER BY r.requestedAt ASC")
    List<Refund> findPendingRefunds();
}
