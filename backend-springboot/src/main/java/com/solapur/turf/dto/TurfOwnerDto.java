package com.solapur.turf.dto;

import com.solapur.turf.enums.VerificationStatus;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class TurfOwnerDto {
    private UUID id;
    private UserDto user;
    private String businessName;
    private String bankAccountNumber;
    private String bankIfsc;
    private String bankName;
    private VerificationStatus status;
}
