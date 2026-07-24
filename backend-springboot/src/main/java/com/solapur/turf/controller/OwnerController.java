package com.solapur.turf.controller;

import com.solapur.turf.dto.ApiResponse;
import com.solapur.turf.dto.UpdateOwnerProfileRequest;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.OwnerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.core.env.Environment;
import com.razorpay.RazorpayClient;
import com.razorpay.Order;
import org.json.JSONObject;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/owners")
@RequiredArgsConstructor
public class OwnerController {

    private final OwnerService ownerService;
    private final Environment env;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMyProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Map<String, Object> profile = ownerService.getOwnerProfile(userDetails.getUser());
        return ResponseEntity.ok(ApiResponse.success(profile, "Owner profile retrieved"));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateMyProfile(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody UpdateOwnerProfileRequest requestData) {
        // Convert validated DTO → Map for the existing service layer
        Map<String, Object> dataMap = new java.util.LinkedHashMap<>();
        if (requestData.getBusinessName()     != null) dataMap.put("businessName",      requestData.getBusinessName());
        if (requestData.getPhone()            != null) dataMap.put("contactNumber",      requestData.getPhone());
        if (requestData.getAddress()          != null) dataMap.put("addressLine1",       requestData.getAddress());
        if (requestData.getCity()             != null) dataMap.put("city",               requestData.getCity());
        if (requestData.getPanNumber()        != null) dataMap.put("panNumber",          requestData.getPanNumber());
        if (requestData.getGstNumber()        != null) dataMap.put("gstNumber",          requestData.getGstNumber());
        if (requestData.getBankAccountNumber()!= null) dataMap.put("bankAccountNumber",  requestData.getBankAccountNumber());
        if (requestData.getIfscCode()         != null) dataMap.put("ifscCode",           requestData.getIfscCode());
        if (requestData.getBankName()         != null) dataMap.put("bankName",           requestData.getBankName());
        Map<String, Object> profile = ownerService.updateOwnerProfile(userDetails.getUser(), dataMap);
        return ResponseEntity.ok(ApiResponse.success(profile, "Owner profile updated"));
    }

    /**
     * Creates a Razorpay order for ₹699 monthly subscription.
     * Flutter opens Razorpay checkout after getting this order ID.
     */
    @PostMapping("/me/subscription/order")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createSubscriptionOrder(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            String keyId = env.getProperty("razorpay.key.id");
            String keySecret = env.getProperty("razorpay.key.secret");

            if (keyId == null || keyId.isBlank() || keySecret == null || keySecret.isBlank()) {
                return ResponseEntity.status(503).body(ApiResponse.error("Payment gateway not configured"));
            }

            RazorpayClient razorpayClient = new RazorpayClient(keyId, keySecret);
            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", 69900); // ₹699 in paise
            orderRequest.put("currency", "INR");
            orderRequest.put("receipt", "sub_" + userDetails.getUser().getId().toString().substring(0, 8));
            orderRequest.put("notes", new JSONObject().put("purpose", "Monthly Subscription"));
            Order order = razorpayClient.orders.create(orderRequest);

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("orderId", order.get("id"));
            response.put("amount", 69900);
            response.put("currency", "INR");
            response.put("keyId", keyId);
            return ResponseEntity.ok(ApiResponse.success(response, "Subscription order created"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.error("Failed to create order: " + e.getMessage()));
        }
    }

    @PostMapping("/me/renew")
    public ResponseEntity<ApiResponse<Map<String, Object>>> renewSubscription(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody(required = false) Map<String, String> body) {
        String keySecret = env.getProperty("razorpay.key.secret");
        if (keySecret == null || keySecret.isBlank()) {
            return ResponseEntity.status(503).body(ApiResponse.error("Payment gateway not configured"));
        }
        Map<String, Object> profile = ownerService.renewSubscription(userDetails.getUser(), body, keySecret);
        return ResponseEntity.ok(ApiResponse.success(profile, "Subscription renewed successfully"));
    }

    @PostMapping("/me/documents")
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadVerificationDocument(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") String documentType) {
        Map<String, Object> profile = ownerService.uploadVerificationDocument(userDetails.getUser(), file, documentType);
        return ResponseEntity.ok(ApiResponse.success(profile, "Verification document uploaded successfully"));
    }
}
