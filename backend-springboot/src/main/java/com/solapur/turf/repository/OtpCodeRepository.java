package com.solapur.turf.repository;

import com.solapur.turf.entity.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, UUID> {
    
    Optional<OtpCode> findTopByEmailAndCodeAndIsUsedFalseOrderByCreatedAtDesc(String email, String code);
    
    void deleteByEmail(String email); // Cleanup old OTPs when generating new one
}
