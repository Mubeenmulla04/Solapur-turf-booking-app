package com.solapur.turf.service;

import com.solapur.turf.dto.ReviewDto;
import com.solapur.turf.entity.Review;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.User;
import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.BookingRepository;
import com.solapur.turf.repository.ReviewRepository;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final TurfListingRepository turfListingRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;

    @Transactional
    public ReviewDto addReview(UUID userId, UUID turfId, int rating, String comment) {
        if (rating < 1 || rating > 5) {
            throw new ApiException("Rating must be between 1 and 5", HttpStatus.BAD_REQUEST);
        }

        if (reviewRepository.existsByUserIdAndTurfId(userId, turfId)) {
            throw new ApiException("You have already reviewed this turf", HttpStatus.CONFLICT);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Mark as verified if user has a completed booking
        boolean hasCompletedBooking = bookingRepository.existsByUserIdAndTurfIdAndBookingStatus(
                userId, turfId, BookingStatus.COMPLETED);

        Review review = Review.builder()
                .user(user)
                .turf(turf)
                .rating(rating)
                .comment(comment)
                .isVerifiedReview(hasCompletedBooking)
                .build();

        Review saved = reviewRepository.save(review);
        
        // Update Turf ratings
        updateTurfRating(turf);

        return mapToDto(saved);
    }

    public List<ReviewDto> getTurfReviews(UUID turfId) {
        return reviewRepository.findByTurfIdOrderByCreatedAtDesc(turfId)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    private void updateTurfRating(TurfListing turf) {
        List<Review> reviews = reviewRepository.findByTurfIdOrderByCreatedAtDesc(turf.getId());
        int count = reviews.size();
        
        if (count == 0) {
            turf.setRatingAverage(BigDecimal.ZERO);
            turf.setReviewCount(0);
        } else {
            double total = reviews.stream().mapToDouble(Review::getRating).sum();
            BigDecimal average = BigDecimal.valueOf(total / count)
                                  .setScale(2, RoundingMode.HALF_UP);
            turf.setRatingAverage(average);
            turf.setReviewCount(count);
        }
        
        turfListingRepository.save(turf);
    }

    private ReviewDto mapToDto(Review review) {
        return ReviewDto.builder()
                .id(review.getId().toString())
                .userId(review.getUser().getId().toString())
                .userName(review.getUser().getFullName())
                .turfId(review.getTurf().getId().toString())
                .turfName(review.getTurf().getName())
                .rating(review.getRating())
                .comment(review.getComment())
                .isVerifiedReview(review.isVerifiedReview())
                .createdAt(review.getCreatedAt())
                .build();
    }
}
