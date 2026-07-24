package com.solapur.turf.service;

import com.solapur.turf.dto.TurfListingDto;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.SportType;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TurfService {

    private final TurfListingRepository turfListingRepository;
    private final TurfOwnerRepository turfOwnerRepository;

    @Cacheable(value = "activeTurfs")
    public List<TurfListingDto> getAllActiveTurfs() {
        return turfListingRepository.findByIsActiveTrueAndIsVerifiedTrue()
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<TurfListingDto> getFilteredTurfs(
            String city,
            String sportType,
            String search,
            Double minPrice,
            Double maxPrice,
            String sortBy,
            int page,
            int limit,
            Double userLat,
            Double userLng
    ) {
        // Special case: NEAREST requires a native Haversine query that returns sorted distances.
        // For this path, we still post-filter in memory (subscription check) + paginate.
        if ("NEAREST".equalsIgnoreCase(sortBy) && userLat != null && userLng != null) {
            List<TurfListing> nearest = turfListingRepository.findNearestTurfs(userLat, userLng);
            nearest = nearest.stream()
                    .filter(t -> isOwnerSubscriptionValid(t.getOwner()))
                    .collect(Collectors.toList());
            // Apply additional filters in-memory (dataset is already small — only active+verified)
            if (city != null && !city.isBlank()) {
                nearest = nearest.stream().filter(t -> city.trim().equalsIgnoreCase(t.getCity())).collect(Collectors.toList());
            }
            if (sportType != null && !sportType.isBlank()) {
                nearest = nearest.stream().filter(t -> t.getSportType() != null && t.getSportType().name().equalsIgnoreCase(sportType.trim())).collect(Collectors.toList());
            }
            if (search != null && !search.isBlank()) {
                String term = search.toLowerCase().trim();
                nearest = nearest.stream().filter(t ->
                        (t.getName() != null && t.getName().toLowerCase().contains(term)) ||
                        (t.getAddress() != null && t.getAddress().toLowerCase().contains(term))
                ).collect(Collectors.toList());
            }
            if (minPrice != null) {
                BigDecimal min = BigDecimal.valueOf(minPrice);
                nearest = nearest.stream().filter(t -> t.getHourlyRate() != null && t.getHourlyRate().compareTo(min) >= 0).collect(Collectors.toList());
            }
            if (maxPrice != null) {
                BigDecimal max = BigDecimal.valueOf(maxPrice);
                nearest = nearest.stream().filter(t -> t.getHourlyRate() != null && t.getHourlyRate().compareTo(max) <= 0).collect(Collectors.toList());
            }
            bubbleFeatured(nearest);
            int from = Math.min((page - 1) * limit, nearest.size());
            int to = Math.min(from + limit, nearest.size());
            return nearest.subList(from, to).stream().map(this::mapToDto).collect(Collectors.toList());
        }

        // ── DB-level filtering + pagination (all other sort modes) ──────────────
        Sort sort = buildSort(sortBy);
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit, sort);

        SportType sportTypeEnum = null;
        if (sportType != null && !sportType.isBlank()) {
            try {
                sportTypeEnum = SportType.valueOf(sportType.trim().toUpperCase());
            } catch (IllegalArgumentException ignored) {
                // unknown sportType → return empty results
                return List.of();
            }
        }

        BigDecimal minPriceBd = minPrice != null ? BigDecimal.valueOf(minPrice) : null;
        BigDecimal maxPriceBd = maxPrice != null ? BigDecimal.valueOf(maxPrice) : null;
        String cityParam    = (city != null && !city.isBlank()) ? city.trim() : null;
        String searchParam  = (search != null && !search.isBlank()) ? search.trim() : null;

        Page<TurfListing> dbPage = turfListingRepository.findFiltered(
                cityParam, sportTypeEnum, searchParam, minPriceBd, maxPriceBd, pageable);

        // Post-filter by owner subscription (cannot easily push into JPQL without joining owners)
        List<TurfListing> results = dbPage.getContent().stream()
                .filter(t -> isOwnerSubscriptionValid(t.getOwner()))
                .collect(Collectors.toList());

        bubbleFeatured(results);
        return results.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    /** Push featured (ACTIVE subscription only) turfs to top of results list. */
    private void bubbleFeatured(List<TurfListing> turfs) {
        turfs.sort((t1, t2) -> {
            boolean f1 = t1.isFeatured() && t1.getOwner() != null && "ACTIVE".equalsIgnoreCase(t1.getOwner().getSubscriptionStatus());
            boolean f2 = t2.isFeatured() && t2.getOwner() != null && "ACTIVE".equalsIgnoreCase(t2.getOwner().getSubscriptionStatus());
            return Boolean.compare(f2, f1);
        });
    }

    /** Maps sortBy query param to Spring Sort object for use with Pageable. */
    private Sort buildSort(String sortBy) {
        if (sortBy == null) return Sort.by(Sort.Direction.DESC, "createdAt");
        return switch (sortBy.toUpperCase().trim()) {
            case "PRICE_ASC"  -> Sort.by(Sort.Direction.ASC,  "hourlyRate");
            case "PRICE_DESC" -> Sort.by(Sort.Direction.DESC, "hourlyRate");
            case "RATING_DESC" -> Sort.by(Sort.Direction.DESC, "ratingAverage");
            default           -> Sort.by(Sort.Direction.DESC, "createdAt"); // NEWEST
        };
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
                .turfId(turf.getId() != null ? turf.getId().toString() : "")
                .ownerId(turf.getOwner() != null ? turf.getOwner().getId() : null)
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
                .isActive(turf.isActive())
                .isVerified(turf.isVerified())
                .isFeatured(turf.isFeatured())
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

    @CacheEvict(value = "activeTurfs", allEntries = true)
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
                .isVerified(false) // Requires admin approval before becoming visible on user dashboard
                .isFeatured(turfDto.isFeatured())
                .ratingAverage(BigDecimal.ZERO)
                .reviewCount(0)
                .build();

        TurfListing saved = turfListingRepository.save(turf);
        return mapToDto(saved);
    }

    @CacheEvict(value = "activeTurfs", allEntries = true)
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
        turf.setFeatured(turfDto.isFeatured());

        TurfListing saved = turfListingRepository.save(turf);
        return mapToDto(saved);
    }

    @CacheEvict(value = "activeTurfs", allEntries = true)
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

    @CacheEvict(value = "activeTurfs", allEntries = true)
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

    private boolean isOwnerSubscriptionValid(TurfOwner owner) {
        if (owner == null) {
            return false;
        }
        if (!owner.isActive()) {
            return false;
        }
        String status = owner.getSubscriptionStatus();
        if (status == null || "TRIAL".equalsIgnoreCase(status)) {
            return owner.getTrialEndsAt() != null && java.time.LocalDateTime.now().isBefore(owner.getTrialEndsAt());
        }
        if ("ACTIVE".equalsIgnoreCase(status)) {
            return owner.getSubscriptionExpiresAt() != null && java.time.LocalDateTime.now().isBefore(owner.getSubscriptionExpiresAt());
        }
        return false;
    }
}
