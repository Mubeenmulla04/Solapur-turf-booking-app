package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "reviews", uniqueConstraints = {
    @UniqueConstraint(name = "unique_user_turf_review", columnNames = {"user_id", "turf_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Review extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    @Column(nullable = false)
    private int rating; // 1 to 5

    @Column(length = 1000)
    private String comment;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private boolean isVerifiedReview = false; // True if user actually booked the turf
}
