package com.solapur.turf.service;

import com.solapur.turf.dto.TurfListingDto;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TurfService {

    private final TurfListingRepository turfListingRepository;
    private final TurfOwnerRepository turfOwnerRepository;

    public List<TurfListingDto> getAllActiveTurfs() {
        return turfListingRepository.findByIsActiveTrueAndIsVerifiedTrue()
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<TurfListingDto> getTurfsByCity(String city) {
        return turfListingRepository.findByCityIgnoreCaseAndIsActiveTrueAndIsVerifiedTrue(city)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<TurfListingDto> getTurfsBySport(SportType sportType) {
        return turfListingRepository.findBySportTypeAndIsActiveTrueAndIsVerifiedTrue(sportType)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public TurfListingDto getTurfById(UUID id) {
        TurfListing turf = turfListingRepository.findById(id)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));
        return mapToDto(turf);
    }

    // Example map logic (we could use MapStruct for deeper projects)
    public TurfListingDto mapToDto(TurfListing turf) {
        return TurfListingDto.builder()
                .turfId(turf.getId().toString())
                .ownerId(turf.getOwner().getId())
                .turfName(turf.getName())
                .description(turf.getDescription())
                .address(turf.getAddress())
                .city(turf.getCity())
                .state(turf.getState())
                .pinCode(turf.getPinCode())
                .latitude(turf.getLatitude())
                .longitude(turf.getLongitude())
                .sportType(turf.getSportType())
                .surfaceType(turf.getSurfaceType())
                .pitchSize(turf.getPitchSize())
                .isIndoor(turf.isIndoor())
                .hourlyRate(turf.getHourlyRate())
                .peakHourRate(turf.getPeakHourRate())
                .peakHours(turf.getPeakHours())
                .amenities(turf.getAmenities())
                .rules(turf.getRules())
                .ratingAverage(turf.getRatingAverage())
                .reviewCount(turf.getReviewCount())
                .imageUrls(turf.getImageUrls())
                .openingTime(turf.getOpeningTime())
                .closingTime(turf.getClosingTime())
                .build();
    }

    public long countTurfs() {
        return turfListingRepository.count();
    }

    public List<TurfListingDto> getTurfsByOwnerId(UUID userId) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));
        
        return turfListingRepository.findByOwnerId(owner.getId())
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public TurfListingDto createTurf(UUID userId, TurfListingDto turfDto) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = TurfListing.builder()
                .name(turfDto.getTurfName())
                .description(turfDto.getDescription())
                .address(turfDto.getAddress())
                .city(turfDto.getCity())
                .state(turfDto.getState())
                .pinCode(turfDto.getPinCode())
                .latitude(turfDto.getLatitude())
                .longitude(turfDto.getLongitude())
                .sportType(turfDto.getSportType())
                .surfaceType(turfDto.getSurfaceType())
                .pitchSize(turfDto.getPitchSize())
                .isIndoor(turfDto.isIndoor())
                .hourlyRate(turfDto.getHourlyRate())
                .peakHourRate(turfDto.getPeakHourRate())
                .peakHours(turfDto.getPeakHours())
                .amenities(turfDto.getAmenities())
                .rules(turfDto.getRules())
                .openingTime(turfDto.getOpeningTime() != null ? turfDto.getOpeningTime() : LocalTime.of(6, 0))
                .closingTime(turfDto.getClosingTime() != null ? turfDto.getClosingTime() : LocalTime.of(23, 0))
                .owner(owner)
                .isActive(true)
                .isVerified(true) // Auto-verified for instant visibility on user dashboard
                .ratingAverage(BigDecimal.ZERO)
                .reviewCount(0)
                .build();

        TurfListing saved = turfListingRepository.save(turf);
        return mapToDto(saved);
    }

    public TurfListingDto updateTurf(UUID turfId, UUID userId, TurfListingDto turfDto) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only update your own turfs", HttpStatus.FORBIDDEN);
        }

        // Update fields
        if (turfDto.getTurfName() != null) turf.setName(turfDto.getTurfName());
        if (turfDto.getDescription() != null) turf.setDescription(turfDto.getDescription());
        if (turfDto.getAddress() != null) turf.setAddress(turfDto.getAddress());
        if (turfDto.getCity() != null) turf.setCity(turfDto.getCity());
        if (turfDto.getState() != null) turf.setState(turfDto.getState());
        if (turfDto.getPinCode() != null) turf.setPinCode(turfDto.getPinCode());
        if (turfDto.getLatitude() != null) turf.setLatitude(turfDto.getLatitude());
        if (turfDto.getLongitude() != null) turf.setLongitude(turfDto.getLongitude());
        if (turfDto.getSportType() != null) turf.setSportType(turfDto.getSportType());
        if (turfDto.getSurfaceType() != null) turf.setSurfaceType(turfDto.getSurfaceType());
        if (turfDto.getPitchSize() != null) turf.setPitchSize(turfDto.getPitchSize());
        turf.setIndoor(turfDto.isIndoor());
        if (turfDto.getHourlyRate() != null) turf.setHourlyRate(turfDto.getHourlyRate());
        if (turfDto.getPeakHourRate() != null) turf.setPeakHourRate(turfDto.getPeakHourRate());
        if (turfDto.getPeakHours() != null) turf.setPeakHours(turfDto.getPeakHours());
        if (turfDto.getAmenities() != null) turf.setAmenities(turfDto.getAmenities());
        if (turfDto.getRules() != null) turf.setRules(turfDto.getRules());
        if (turfDto.getOpeningTime() != null) turf.setOpeningTime(turfDto.getOpeningTime());
        if (turfDto.getClosingTime() != null) turf.setClosingTime(turfDto.getClosingTime());

        TurfListing saved = turfListingRepository.save(turf);
        return mapToDto(saved);
    }

    public void deleteTurf(UUID turfId, UUID userId) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only delete your own turfs", HttpStatus.FORBIDDEN);
        }

        turfListingRepository.delete(turf);
    }

    public TurfListingDto updateTurfStatus(UUID turfId, UUID userId, boolean isActive) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only update your own turfs", HttpStatus.FORBIDDEN);
        }

        turf.setActive(isActive);
        TurfListing saved = turfListingRepository.save(turf);
        return mapToDto(saved);
    }

    public TurfListing getTurfByIdAndOwnerId(UUID turfId, UUID userId) {
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("Ownership verification failed", HttpStatus.FORBIDDEN);
        }
        return turf;
    }

    public void updateTurfImages(UUID turfId, UUID userId, List<String> newUrls) {
        TurfListing turf = getTurfByIdAndOwnerId(turfId, userId);
        List<String> currentUrls = turf.getImageUrls();
        if (currentUrls == null) {
            currentUrls = new java.util.ArrayList<>();
        }
        currentUrls.addAll(newUrls);
        turf.setImageUrls(currentUrls);
        turfListingRepository.save(turf);
    }
}
