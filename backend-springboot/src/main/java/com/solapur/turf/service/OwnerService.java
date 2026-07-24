package com.solapur.turf.service;

import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.entity.User;
import com.solapur.turf.enums.VerificationStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import com.solapur.turf.util.ValidationUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OwnerService {

    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;
    private final EmailService emailService;
    private final FileStorageService fileStorageService;

    @Transactional
    public Map<String, Object> getOwnerProfile(User user) {
        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(user.getId());

        if (ownerOpt.isEmpty()) {
            return new LinkedHashMap<>();
        }

        TurfOwner owner = ownerOpt.get();

        // On-the-fly trial/subscription expiration checks
        boolean updated = false;
        if ("TRIAL".equalsIgnoreCase(owner.getSubscriptionStatus()) 
                && owner.getTrialEndsAt() != null 
                && LocalDateTime.now().isAfter(owner.getTrialEndsAt())) {
            owner.setSubscriptionStatus("EXPIRED");
            updated = true;
        }
        if ("ACTIVE".equalsIgnoreCase(owner.getSubscriptionStatus()) 
                && owner.getSubscriptionExpiresAt() != null 
                && LocalDateTime.now().isAfter(owner.getSubscriptionExpiresAt())) {
            owner.setSubscriptionStatus("EXPIRED");
            updated = true;
        }
        if (updated) {
            turfOwnerRepository.save(owner);
        }

        return buildProfileMap(owner);
    }

    @Transactional
    public Map<String, Object> updateOwnerProfile(User user, Map<String, Object> requestData) {
        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(user.getId());
        TurfOwner owner = ownerOpt.orElseGet(() -> {
            TurfOwner newOwner = new TurfOwner();
            newOwner.setUser(user);
            newOwner.setBusinessName("Your Business");
            newOwner.setContactNumber("Not Set");
            newOwner.setAddressLine1("Not Set");
            newOwner.setCity("Not Set");
            newOwner.setState("Not Set");
            newOwner.setPinCode("Not Set");
            newOwner.setUpiId("Not Set");
            newOwner.setVerificationStatus(VerificationStatus.PENDING);
            newOwner.setTrialStartsAt(LocalDateTime.now());
            newOwner.setTrialEndsAt(LocalDateTime.now().plusDays(60)); // 2 Months trial
            newOwner.setSubscriptionStatus("TRIAL");
            return newOwner;
        });

        if (requestData.containsKey("contactNumber")) {
            owner.setContactNumber(cleanField(requestData, "contactNumber"));
        }
        if (requestData.containsKey("businessName")) {
            owner.setBusinessName(cleanField(requestData, "businessName"));
        }
        if (requestData.containsKey("upiId")) {
            owner.setUpiId(cleanField(requestData, "upiId"));
        }
        if (requestData.containsKey("bankAccountNumber")) {
            owner.setBankAccountNumber(cleanField(requestData, "bankAccountNumber"));
        }
        if (requestData.containsKey("ifscCode")) {
            owner.setIfscCode(cleanField(requestData, "ifscCode"));
        }
        if (requestData.containsKey("gstNumber")) {
            owner.setGstNumber(cleanField(requestData, "gstNumber"));
        }
        if (requestData.containsKey("panNumber")) {
            owner.setPanNumber(cleanField(requestData, "panNumber"));
        }
        if (requestData.containsKey("verificationDocuments")) {
            Object docs = requestData.get("verificationDocuments");
            if (docs instanceof Map) {
                Map<String, Object> cleanedDocs = new HashMap<>();
                ((Map<?, ?>) docs).forEach((key, val) -> {
                    if (key instanceof String && val instanceof String) {
                        cleanedDocs.put((String) key, ValidationUtil.sanitizeInput((String) val));
                    }
                });
                owner.setVerificationDocuments(cleanedDocs);
            } else if (docs == null) {
                owner.setVerificationDocuments(null);
            } else {
                throw new ApiException("Invalid format for verificationDocuments", HttpStatus.BAD_REQUEST);
            }
        }
        if (requestData.containsKey("addressLine1")) {
            owner.setAddressLine1(cleanField(requestData, "addressLine1"));
        }
        if (requestData.containsKey("addressLine2")) {
            owner.setAddressLine2(cleanField(requestData, "addressLine2"));
        }
        if (requestData.containsKey("city")) {
            owner.setCity(cleanField(requestData, "city"));
        }
        if (requestData.containsKey("state")) {
            owner.setState(cleanField(requestData, "state"));
        }
        if (requestData.containsKey("pinCode")) {
            owner.setPinCode(cleanField(requestData, "pinCode"));
        }

        turfOwnerRepository.save(owner);
        return buildProfileMap(owner);
    }

    @Transactional
    public Map<String, Object> renewSubscription(User user, Map<String, String> body, String keySecret) {
        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(user.getId());
        if (ownerOpt.isEmpty()) {
            throw new ApiException("Profile not found", HttpStatus.NOT_FOUND);
        }

        if (body == null || !body.containsKey("razorpayPaymentId") || !body.containsKey("razorpayOrderId") || !body.containsKey("razorpaySignature")) {
            throw new ApiException("Payment verification details (paymentId, orderId, signature) are required", HttpStatus.BAD_REQUEST);
        }

        String paymentId = body.get("razorpayPaymentId");
        String orderId = body.get("razorpayOrderId");
        String signature = body.get("razorpaySignature");

        try {
            org.json.JSONObject options = new org.json.JSONObject();
            options.put("razorpay_order_id", orderId);
            options.put("razorpay_payment_id", paymentId);
            options.put("razorpay_signature", signature);

            boolean isValid = com.razorpay.Utils.verifyPaymentSignature(options, keySecret);
            if (!isValid) {
                throw new ApiException("Invalid payment signature", HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            throw new ApiException("Payment verification failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }

        TurfOwner owner = ownerOpt.get();
        LocalDateTime newExpiry = LocalDateTime.now().plusDays(30);
        if (owner.getSubscriptionExpiresAt() != null && owner.getSubscriptionExpiresAt().isAfter(LocalDateTime.now())) {
            newExpiry = owner.getSubscriptionExpiresAt().plusDays(30);
        }
        owner.setSubscriptionExpiresAt(newExpiry);
        owner.setSubscriptionStatus("ACTIVE");
        turfOwnerRepository.save(owner);

        try {
            emailService.sendSubscriptionRenewal(
                user.getEmail(),
                user.getFullName(),
                owner.getBusinessName(),
                newExpiry
            );
        } catch (Exception ignored) {}

        return buildProfileMap(owner);
    }

    @Transactional
    public Map<String, Object> uploadVerificationDocument(User user, MultipartFile file, String documentType) {
        Optional<TurfOwner> ownerOpt = turfOwnerRepository.findByUserId(user.getId());
        if (ownerOpt.isEmpty()) {
            throw new ApiException("Owner profile not found", HttpStatus.NOT_FOUND);
        }
        
        TurfOwner owner = ownerOpt.get();
        
        String folder = "documents/" + owner.getId().toString();
        String fileUrl = fileStorageService.storeFile(file, folder);
        
        Map<String, Object> docs = owner.getVerificationDocuments();
        if (docs == null) {
            docs = new HashMap<>();
        }
        docs.put(documentType, fileUrl);
        owner.setVerificationDocuments(docs);
        turfOwnerRepository.save(owner);
        
        return buildProfileMap(owner);
    }

    private String cleanField(Map<String, Object> data, String key) {
        Object val = data.get(key);
        if (val == null) {
            return null;
        }
        if (!(val instanceof String)) {
            throw new ApiException("Invalid data type for " + key + ": expected string", HttpStatus.BAD_REQUEST);
        }
        return ValidationUtil.sanitizeInput((String) val);
    }

    private Map<String, Object> buildProfileMap(TurfOwner owner) {
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
        data.put("gstNumber", owner.getGstNumber());
        data.put("panNumber", owner.getPanNumber());
        data.put("verificationDocuments", owner.getVerificationDocuments());
        data.put("verificationStatus", owner.getVerificationStatus().name());
        data.put("totalEarnings", owner.getTotalEarnings());
        data.put("pendingSettlement", owner.getPendingSettlement());
        data.put("isActive", owner.isActive());
        data.put("subscriptionStatus", owner.getSubscriptionStatus());
        data.put("trialEndsAt", owner.getTrialEndsAt() != null ? owner.getTrialEndsAt().toString() : null);
        data.put("subscriptionExpiresAt", owner.getSubscriptionExpiresAt() != null ? owner.getSubscriptionExpiresAt().toString() : null);

        List<TurfListing> turfs = turfListingRepository.findByOwnerId(owner.getId());
        data.put("turfIds", turfs.stream().map(TurfListing::getId).toList());

        return data;
    }
}
