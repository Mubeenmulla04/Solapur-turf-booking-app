package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.DynamicPricingRule;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.exception.ResourceNotFoundException;
import com.solapur.turf.repository.DynamicPricingRuleRepository;
import com.solapur.turf.repository.TurfListingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/turfs/{turfId}/pricing-rules")
@RequiredArgsConstructor
public class PricingRuleController {

    private final DynamicPricingRuleRepository repository;
    private final TurfListingRepository turfListingRepository;

    @GetMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<List<DynamicPricingRule>>> getRules(@PathVariable UUID turfId) {
        return ResponseEntity.ok(ApiResponse.success(repository.findByTurfIdAndIsActiveTrue(turfId), "Rules fetched"));
    }

    @PostMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<DynamicPricingRule>> addRule(
            @PathVariable UUID turfId,
            @RequestBody DynamicPricingRule rule) {
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ResourceNotFoundException("Turf", "id", turfId));
        
        rule.setTurf(turf);
        return ResponseEntity.ok(ApiResponse.success(repository.save(rule), "Rule added"));
    }

    @DeleteMapping("/{ruleId}")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ApiResponse<Object>> deleteRule(@PathVariable UUID ruleId) {
        repository.deleteById(ruleId);
        return ResponseEntity.ok(ApiResponse.success(null, "Rule deleted"));
    }
}
