package com.solapur.turf.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class TopUpRequest {
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "1.0", message = "Minimum top-up amount is 1")
    private BigDecimal amount;

    @NotBlank(message = "Transaction reference is required")
    private String transactionReference;
}
