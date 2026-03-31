package com.solapur.turf.entity;

import com.solapur.turf.enums.VerificationStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "turf_owners")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TurfOwner extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "business_name", nullable = false)
    private String businessName;

    @Column(name = "contact_number", nullable = false)
    private String contactNumber;

    @Column(name = "address_line1", nullable = false)
    private String addressLine1;

    @Column(name = "address_line2")
    private String addressLine2;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String state;

    @Column(name = "pin_code", nullable = false)
    private String pinCode;

    @Column(name = "upi_id")
    private String upiId;

    @Column(name = "bank_account_number")
    private String bankAccountNumber;

    @Column(name = "ifsc_code")
    private String ifscCode;

    @Column(name = "gst_number")
    private String gstNumber;

    @Column(name = "pan_number")
    private String panNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status", nullable = false)
    @Builder.Default
    private VerificationStatus verificationStatus = VerificationStatus.PENDING;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "verification_documents", columnDefinition = "jsonb")
    private Map<String, Object> verificationDocuments;

    @Column(name = "total_earnings", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal totalEarnings = BigDecimal.ZERO;

    @Column(name = "pending_settlement", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal pendingSettlement = BigDecimal.ZERO;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private boolean isActive = true;
}
