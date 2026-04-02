package com.solapur.turf.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDto {
    private String id;
    private String userId;
    private String userName;
    private String turfId;
    private String turfName;
    private int rating;
    private String comment;
    private boolean isVerifiedReview;
    private LocalDateTime createdAt;
}
