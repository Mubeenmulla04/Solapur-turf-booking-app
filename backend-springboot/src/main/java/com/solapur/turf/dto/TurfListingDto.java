package com.solapur.turf.dto;

import com.solapur.turf.enums.SportType;
import com.solapur.turf.enums.SurfaceType;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class TurfListingDto {
    private String turfId;
    private UUID ownerId;
    private String turfName;
    private String description;
    private String address;
    private String city;
    private String state;
    private String pinCode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private SportType sportType;
    private SurfaceType surfaceType;
    private String pitchSize;
    private boolean isIndoor;
    private BigDecimal hourlyRate;
    private BigDecimal peakHourRate;
    private List<String> peakHours;
    private List<String> amenities;
    private String rules;
    private BigDecimal ratingAverage;
    private int reviewCount;
    private List<String> imageUrls;
    private LocalTime openingTime;
    private LocalTime closingTime;
}
