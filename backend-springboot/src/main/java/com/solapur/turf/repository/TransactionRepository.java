package com.solapur.turf.repository;

import com.solapur.turf.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    Optional<Transaction> findByGatewayOrderId(String gatewayOrderId);

    List<Transaction> findByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<Transaction> findByBookingId(UUID bookingId);
    Optional<Transaction> findByGatewayPaymentId(String gatewayPaymentId);
    Optional<Transaction> findByBookingIdAndStatusAndTransactionType(
            UUID bookingId, 
            com.solapur.turf.enums.TransactionStatus status, 
            com.solapur.turf.enums.TransactionType type);
}
