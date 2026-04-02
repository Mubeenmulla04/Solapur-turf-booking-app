package com.solapur.turf.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "tournament_matches")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TournamentMatch extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tournament_id", nullable = false)
    private Tournament tournament;

    @Column(nullable = false)
    private int round; // 1 = First Round, 2 = Quarters, 3 = Semis, etc.

    @Column(name = "match_number", nullable = false)
    private int matchNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_a_id")
    private Team teamA;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_b_id")
    private Team teamB;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "winner_id")
    private Team winner;

    @Column(name = "score_a")
    private Integer scoreA;

    @Column(name = "score_b")
    private Integer scoreB;

    @Column(nullable = false)
    @Builder.Default
    private String status = "UPCOMING"; // UPCOMING, LIVE, COMPLETED, CANCELLED

    @Column(name = "scheduled_start_time")
    private LocalDateTime scheduledStartTime;

    @Column(name = "court_number")
    private String courtNumber;

    // Optional: Reference to previous match ids for bracket progression logic
    @Column(name = "prev_match_a_id")
    private UUID prevMatchAId;

    @Column(name = "prev_match_b_id")
    private UUID prevMatchBId;
}
