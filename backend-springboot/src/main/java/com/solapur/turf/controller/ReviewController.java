package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.ReviewDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/turf/{turfId}")
    public ResponseEntity<ApiResponse<ReviewDto>> addReview(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID turfId,
            @RequestBody ReviewDto request) {
        
        ReviewDto response = reviewService.addReview(
                userDetails.getUser().getId(), turfId, request.getRating(), request.getComment());
                
        return ResponseEntity.ok(ApiResponse.success(response, "Review added successfully"));
    }

    @GetMapping("/turf/{turfId}")
    public ResponseEntity<ApiResponse<List<ReviewDto>>> getTurfReviews(@PathVariable UUID turfId) {
        List<ReviewDto> reviews = reviewService.getTurfReviews(turfId);
        return ResponseEntity.ok(ApiResponse.success(reviews, "Reviews fetched"));
    }
}
