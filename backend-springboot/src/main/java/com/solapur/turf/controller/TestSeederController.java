package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.*;
import com.solapur.turf.enums.*;
import com.solapur.turf.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/test")
@RequiredArgsConstructor
public class TestSeederController {

    private final UserRepository userRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;
    private final AvailabilitySlotRepository availabilitySlotRepository;
    private final UserWalletRepository userWalletRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/seed-test-data")
    @Transactional
    public ResponseEntity<ApiResponse<String>> seedTestData() {
        String ownerEmail = "testowner@example.com";

        // 1. Delete existing if any (to make it repeatable)
        userRepository.findByEmail(ownerEmail).ifPresent(u -> {
            turfOwnerRepository.findByUserId(u.getId()).ifPresent(o -> {
                List<TurfListing> turfs = turfListingRepository.findByOwnerId(o.getId());
                for (TurfListing t : turfs) {
                    availabilitySlotRepository.deleteAll(availabilitySlotRepository.findByTurfId(t.getId()));
                }
                turfListingRepository.deleteAll(turfs);
                turfOwnerRepository.delete(o);
            });
            userWalletRepository.findByUserId(u.getId()).ifPresent(userWalletRepository::delete);
            userRepository.delete(u);
        });

        // 2. Create User with role OWNER
        User user = User.builder()
                .fullName("Mubin Owner")
                .email(ownerEmail)
                .phone("9876543210")
                .passwordHash(passwordEncoder.encode("password123"))
                .role(UserRole.OWNER)
                .isVerified(true)
                .build();
        User savedUser = userRepository.save(user);

        // 3. Create Wallet
        UserWallet wallet = UserWallet.builder()
                .user(savedUser)
                .balance(BigDecimal.ZERO)
                .build();
        userWalletRepository.save(wallet);

        // 4. Create TurfOwner profile
        TurfOwner ownerProfile = TurfOwner.builder()
                .user(savedUser)
                .businessName("Solapur Turf Academy")
                .contactNumber("9876543210")
                .addressLine1("Main Road, Navipeth")
                .city("Solapur")
                .state("Maharashtra")
                .pinCode("413001")
                .upiId("testowner@upi")
                .verificationStatus(VerificationStatus.APPROVED)
                .isActive(true)
                .build();
        TurfOwner savedOwner = turfOwnerRepository.save(ownerProfile);

        // 5. Create Turf Listing
        TurfListing turf = TurfListing.builder()
                .owner(savedOwner)
                .name("Solapur Grand Arena")
                .description(
                        "Professional 5v5 and 7v7 turf with high-quality FIFA-certified grass and modern amenities.")
                .address("Next to Railway Station, Navipeth")
                .city("Solapur")
                .state("MH")
                .pinCode("413003")
                .latitude(new BigDecimal("17.6599"))
                .longitude(new BigDecimal("75.9064"))
                .sportType(SportType.FOOTBALL)
                .surfaceType(SurfaceType.ARTIFICIAL_GRASS)
                .pitchSize("5v5")
                .isIndoor(false)
                .hourlyRate(new BigDecimal("1200.00"))
                .peakHourRate(new BigDecimal("1500.00"))
                .peakHours(List.of("18:00-22:00"))
                .amenities(List.of("Changing Room", "Parking", "Water", "Floodlights"))
                .rules("No smoking. No plastic studs. Arrive 15 mins early.")
                .ratingAverage(new BigDecimal("4.8"))
                .reviewCount(24)
                .isActive(true)
                .isVerified(true)
                .build();
        TurfListing savedTurf = turfListingRepository.save(turf);

        // 6. Create Slots for the next 3 days
        LocalDate today = LocalDate.now();
        List<AvailabilitySlot> slotsToSave = new ArrayList<>();

        for (int i = 0; i < 3; i++) {
            LocalDate date = today.plusDays(i);
            // Slots from 06:00 to 23:00
            for (int hour = 6; hour < 23; hour++) {
                AvailabilitySlot slot = AvailabilitySlot.builder()
                        .turf(savedTurf)
                        .date(date)
                        .startTime(LocalTime.of(hour, 0))
                        .endTime(LocalTime.of(hour + 1, 0))
                        .status(SlotStatus.AVAILABLE)
                        .price(hour >= 18 && hour <= 21 ? new BigDecimal("1500.00") : new BigDecimal("1200.00"))
                        .build();
                slotsToSave.add(slot);
            }
        }
        availabilitySlotRepository.saveAll(slotsToSave);

        return ResponseEntity.ok(ApiResponse.success("Seeded successfully: Created Owner (" + ownerEmail
                + "), 1 Turf, and " + slotsToSave.size() + " Slots for next 3 days.", "Done"));
    }
}
