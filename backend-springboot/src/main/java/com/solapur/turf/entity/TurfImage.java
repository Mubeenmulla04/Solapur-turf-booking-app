package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "turf_images")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TurfImage extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id", nullable = false)
    private TurfListing turf;

    @Column(name = "image_url", nullable = false)
    private String imageUrl;

    @Column(name = "is_primary", nullable = false)
    @Builder.Default
    private boolean isPrimary = false;

    @Column(name = "display_order")
    @Builder.Default
    private int displayOrder = 0;
}
