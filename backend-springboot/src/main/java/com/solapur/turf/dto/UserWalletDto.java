package com.solapur.turf.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
public class UserWalletDto {
    private UUID id;
    private BigDecimal balance;
    private BigDecimal totalAdded;
    private BigDecimal totalSpent;
}
