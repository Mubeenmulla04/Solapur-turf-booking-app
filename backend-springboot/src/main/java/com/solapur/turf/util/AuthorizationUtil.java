package com.solapur.turf.util;

import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Centralized service-layer authorization utility.
 *
 * Use this in any service/controller that needs to verify ownership
 * of a resource before allowing a write/delete operation.
 *
 * All methods throw ApiException(FORBIDDEN) on failure — consistent
 * with the GlobalExceptionHandler response format.
 */
@Component
@RequiredArgsConstructor
public class AuthorizationUtil {

    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;

    /**
     * Resolves the TurfOwner for a given user ID.
     * Throws 404 if the user has no owner profile.
     */
    public TurfOwner requireOwnerProfile(UUID userId) {
        return turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException(
                        "No turf owner profile found for this user", HttpStatus.NOT_FOUND));
    }

    /**
     * Verifies that the given userId owns the given turf.
     * Throws 403 Forbidden if they do not.
     *
     * @param turfId  the turf to check
     * @param userId  the user claiming ownership
     * @return the TurfListing (for chaining)
     */
    public TurfListing requireTurfOwnership(UUID turfId, UUID userId) {
        TurfOwner owner = requireOwnerProfile(userId);

        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException(
                    "Access denied: you do not own this turf", HttpStatus.FORBIDDEN);
        }
        return turf;
    }

    /**
     * Verifies that the given userId owns the turf that a pricing rule belongs to.
     * Prevents an owner from deleting another owner's pricing rules.
     *
     * @param rule    the pricing rule entity
     * @param userId  the user requesting the deletion
     */
    public void requirePricingRuleOwnership(
            com.solapur.turf.entity.DynamicPricingRule rule, UUID userId) {

        if (rule == null || rule.getTurf() == null) {
            throw new ApiException("Pricing rule not found", HttpStatus.NOT_FOUND);
        }
        requireTurfOwnership(rule.getTurf().getId(), userId);
    }
}
