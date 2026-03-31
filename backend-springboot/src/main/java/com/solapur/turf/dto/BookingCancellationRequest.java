package com.solapur.turf.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class BookingCancellationRequest {
    
    @NotBlank(message = "Cancellation reason is required")
    private String reason;
    
    private String refundMethod; // "WALLET", "BANK", "ORIGINAL_PAYMENT"
    
    private Boolean requestRefund = true;
    
    private String additionalNotes;
}
