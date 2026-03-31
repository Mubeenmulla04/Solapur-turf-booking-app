package com.solapur.turf.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletTransactionDto {
    private String id;
    private BigDecimal amount;
    private String type; // CREDIT, DEBIT
    private String description;
    private String transactionReference;
    private LocalDateTime createdAt;
}
