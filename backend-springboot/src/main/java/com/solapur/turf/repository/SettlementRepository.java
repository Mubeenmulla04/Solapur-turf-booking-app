package com.solapur.turf.repository;

import com.solapur.turf.entity.Settlement;
import com.solapur.turf.enums.SettlementStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, UUID> {
    List<Settlement> findByOwnerIdOrderByPeriodStartDesc(UUID ownerId);

    List<Settlement> findByStatus(SettlementStatus status);

    boolean existsByOwnerIdAndPeriodStartAndPeriodEnd(UUID ownerId, LocalDate periodStart, LocalDate periodEnd);

    @Query("SELECT COUNT(s) FROM Settlement s WHERE s.status = :status")
    long countByStatus(@Param("status") SettlementStatus status);

    @Query("SELECT COALESCE(SUM(s.settlementAmount), 0) FROM Settlement s WHERE s.status = :status")
    BigDecimal sumSettlementAmountByStatus(@Param("status") SettlementStatus status);
}
