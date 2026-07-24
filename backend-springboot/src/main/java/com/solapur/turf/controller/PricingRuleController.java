package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.DynamicPricingRule;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.exception.ResourceNotFoundException;
import com.solapur.turf.repository.DynamicPricingRuleRepository;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.util.AuthorizationUtil;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/turfs/{turfId}/pricing-rules")
@RequiredArgsConstructor
@PreAuthorize("hasRole('OWNER')")
public class PricingRuleController {

    private final DynamicPricingRuleRepository repository;
    private final AuthorizationUtil authorizationUtil;

    /** GET /api/turfs/{turfId}/pricing-rules — owner views their own rules only */
    @GetMapping
    public ResponseEntity<ApiResponse<List<DynamicPricingRule>>> getRules(
            @PathVariable UUID turfId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        // Verify the requesting owner actually owns this turf
        authorizationUtil.requireTurfOwnership(turfId, userDetails.getUser().getId());

        return ResponseEntity.ok(ApiResponse.success(
                repository.findByTurfIdAndIsActiveTrue(turfId), "Rules fetched"));
    }

    /** POST /api/turfs/{turfId}/pricing-rules — owner adds a pricing rule */
    @PostMapping
    public ResponseEntity<ApiResponse<DynamicPricingRule>> addRule(
            @PathVariable UUID turfId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody DynamicPricingRule rule) {

        // Verify ownership — also returns the TurfListing so we don't need a separate lookup
        TurfListing turf = authorizationUtil.requireTurfOwnership(turfId, userDetails.getUser().getId());

        rule.setTurf(turf);
        rule.setActive(true); // new rules are active by default

        return ResponseEntity.ok(ApiResponse.success(repository.save(rule), "Rule added"));
    }

    /** DELETE /api/turfs/{turfId}/pricing-rules/{ruleId} — owner deletes their rule */
    @DeleteMapping("/{ruleId}")
    public ResponseEntity<ApiResponse<Object>> deleteRule(
            @PathVariable UUID turfId,
            @PathVariable UUID ruleId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        // Verify the rule exists and belongs to this owner's turf
        DynamicPricingRule rule = repository.findById(ruleId)
                .orElseThrow(() -> new ResourceNotFoundException("PricingRule", "id", ruleId));

        authorizationUtil.requirePricingRuleOwnership(rule, userDetails.getUser().getId());

        repository.deleteById(ruleId);
        return ResponseEntity.ok(ApiResponse.success(null, "Rule deleted"));
    }
}
