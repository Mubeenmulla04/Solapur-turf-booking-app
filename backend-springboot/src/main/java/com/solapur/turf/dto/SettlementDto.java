package com.solapur.turf.dto;

import com.solapur.turf.enums.SettlementStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class SettlementDto {
    private UUID id;
    private UUID ownerId;
    private TurfOwnerDto turfOwner;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private BigDecimal settlementAmount;
    private BigDecimal commissionAmount;
    private BigDecimal transactionFee;
    private SettlementStatus status;
    private String bankReference;
    private LocalDateTime processedAt;
}
