package com.solapur.turf.entity;

import com.solapur.turf.enums.RegistrationStatus;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.enums.TournamentFormat;
import com.solapur.turf.enums.TournamentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "tournaments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tournament extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(length = 2000)
    private String description;

    @Column(name = "creator_type", nullable = false)
    private String creatorType; // 'OWNER' or 'ADMIN'

    @Column(name = "creator_id", nullable = false)
    private UUID creatorId; // Reference to TurfOwner or Admin User ID

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turf_id")
    private TurfListing turf;

    @Enumerated(EnumType.STRING)
    @Column(name = "sport_type", nullable = false)
    private SportType sportType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TournamentFormat format;

    @Column(name = "max_teams", nullable = false)
    private int maxTeams;

    @Column(name = "entry_fee_per_team", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal entryFeePerTeam = BigDecimal.ZERO;

    @Column(name = "prize_pool_winner", nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal prizePoolWinner = BigDecimal.ZERO;

    @Column(name = "prize_pool_runner_up", precision = 10, scale = 2)
    private BigDecimal prizePoolRunnerUp;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(name = "registration_deadline", nullable = false)
    private LocalDateTime registrationDeadline;

    @Enumerated(EnumType.STRING)
    @Column(name = "registration_status", nullable = false)
    @Builder.Default
    private RegistrationStatus registrationStatus = RegistrationStatus.OPEN;

    @Enumerated(EnumType.STRING)
    @Column(name = "tournament_status", nullable = false)
    @Builder.Default
    private TournamentStatus tournamentStatus = TournamentStatus.UPCOMING;

    @Column(name = "banner_url")
    private String bannerUrl;
}
