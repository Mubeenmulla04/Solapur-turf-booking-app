package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import com.solapur.turf.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/owners")
@RequiredArgsConstructor
public class OwnerController {

    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMyProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(userDetails.getUser().getId());

        if (ownerOpt.isEmpty()) {
            return ResponseEntity.ok(ApiResponse.success(new LinkedHashMap<>(), "No active TurfOwner profile"));
        }

        TurfOwner owner = ownerOpt.get();

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("ownerId", owner.getId());
        data.put("businessName", owner.getBusinessName());
        data.put("contactNumber", owner.getContactNumber());
        data.put("addressLine1", owner.getAddressLine1());
        data.put("addressLine2", owner.getAddressLine2());
        data.put("city", owner.getCity());
        data.put("state", owner.getState());
        data.put("pinCode", owner.getPinCode());
        data.put("upiId", owner.getUpiId());
        data.put("bankAccountNumber", owner.getBankAccountNumber());
        data.put("ifscCode", owner.getIfscCode());
        data.put("verificationStatus", owner.getVerificationStatus().name());
        data.put("totalEarnings", owner.getTotalEarnings());
        data.put("pendingSettlement", owner.getPendingSettlement());
        data.put("isActive", owner.isActive());

        // Add turf IDs
        List<TurfListing> turfs = turfListingRepository.findByOwnerId(owner.getId());
        data.put("turfIds", turfs.stream().map(TurfListing::getId).toList());

        return ResponseEntity.ok(ApiResponse.success(data, "Owner profile retrieved"));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateMyProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody Map<String, String> requestData) {

        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(userDetails.getUser().getId());
        TurfOwner owner = ownerOpt.orElseGet(() -> {
            TurfOwner newOwner = new TurfOwner();
            newOwner.setUser(userDetails.getUser());
            newOwner.setBusinessName("Your Business");
            newOwner.setContactNumber("Not Set");
            newOwner.setAddressLine1("Not Set");
            newOwner.setCity("Not Set");
            newOwner.setState("Not Set");
            newOwner.setPinCode("Not Set");
            newOwner.setUpiId("Not Set");
            newOwner.setVerificationStatus(com.solapur.turf.enums.VerificationStatus.PENDING);
            return newOwner;
        });

        if (requestData.containsKey("contactNumber")) {
            owner.setContactNumber(requestData.get("contactNumber"));
        }
        if (requestData.containsKey("businessName")) {
            owner.setBusinessName(requestData.get("businessName"));
        }
        if (requestData.containsKey("upiId")) {
            owner.setUpiId(requestData.get("upiId"));
        }
        if (requestData.containsKey("bankAccountNumber")) {
            owner.setBankAccountNumber(requestData.get("bankAccountNumber"));
        }
        if (requestData.containsKey("ifscCode")) {
            owner.setIfscCode(requestData.get("ifscCode"));
        }
        if (requestData.containsKey("addressLine1")) {
            owner.setAddressLine1(requestData.get("addressLine1"));
        }
        if (requestData.containsKey("addressLine2")) {
            owner.setAddressLine2(requestData.get("addressLine2"));
        }
        if (requestData.containsKey("city")) {
            owner.setCity(requestData.get("city"));
        }
        if (requestData.containsKey("state")) {
            owner.setState(requestData.get("state"));
        }
        if (requestData.containsKey("pinCode")) {
            owner.setPinCode(requestData.get("pinCode"));
        }

        turfOwnerRepository.save(owner);

        return getMyProfile(userDetails);
    }
}
