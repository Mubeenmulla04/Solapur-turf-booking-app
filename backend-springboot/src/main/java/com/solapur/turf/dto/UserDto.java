package com.solapur.turf.dto;

import com.solapur.turf.enums.UserRole;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class UserDto {
    private String userId;
    private String email;
    private String phone;
    private String fullName;
    private UserRole role;
    private boolean isActive;
    private String fcmToken;
    private List<String> imageUrls;

    @Builder.Default
    private java.math.BigDecimal walletBalance = java.math.BigDecimal.ZERO;
    @Builder.Default
    private Integer loyaltyPoints = 0;

    private String favoriteSports;
    private String preferredTimeSlots;
}
