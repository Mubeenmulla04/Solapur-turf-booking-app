package com.solapur.turf.service;

import com.solapur.turf.entity.*;
import com.solapur.turf.enums.VerificationStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final TurfListingRepository turfListingRepository;
    private final BookingRepository bookingRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final PlatformSettingsRepository settingsRepository;
    private final AuditLogRepository auditLogRepository;
    private final NotificationService notificationService;

    // ── Platform Stats ────────────────────────────────────────────────────────

    public Map<String, Object> getPlatformStats() {
        long totalUsers    = userRepository.count();
        long totalTurfs    = turfListingRepository.count();
        long totalBookings = bookingRepository.count();
        long pendingOwners = turfOwnerRepository.countByVerificationStatus(VerificationStatus.PENDING);

        // Aggregate SQL SUM – no longer loads all bookings into memory
        BigDecimal totalRevenue = bookingRepository.sumTotalRevenue();
        if (totalRevenue == null) totalRevenue = BigDecimal.ZERO;

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalUsers", totalUsers);
        stats.put("totalTurfs", totalTurfs);
        stats.put("totalBookings", totalBookings);
        stats.put("totalRevenue", totalRevenue);
        stats.put("pendingOwnerApprovals", pendingOwners);
        return stats;
    }

    // ── Revenue Analytics ─────────────────────────────────────────────────────

    public Map<String, Object> getRevenueAnalytics() {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM yyyy");
        LocalDate now = LocalDate.now();
        LocalDate sixMonthsAgo = now.minusMonths(5).withDayOfMonth(1);

        // Build ordered map of last 6 months initialized to zero
        Map<String, BigDecimal> monthlyRevenue = new LinkedHashMap<>();
        for (int i = 5; i >= 0; i--) {
            LocalDate month = now.minusMonths(i).withDayOfMonth(1);
            monthlyRevenue.put(month.format(fmt), BigDecimal.ZERO);
        }

        // Single aggregate DB query – replaces findAll() + Java stream
        List<Object[]> rows = bookingRepository.findMonthlyRevenueSince(sixMonthsAgo);
        for (Object[] row : rows) {
            if (row[0] == null || row[1] == null) continue;
            // row[0] is a java.sql.Date / LocalDate from date_trunc
            LocalDate monthDate;
            if (row[0] instanceof java.sql.Date) {
                monthDate = ((java.sql.Date) row[0]).toLocalDate();
            } else if (row[0] instanceof LocalDate) {
                monthDate = (LocalDate) row[0];
            } else {
                continue;
            }
            String key = monthDate.withDayOfMonth(1).format(fmt);
            if (monthlyRevenue.containsKey(key)) {
                monthlyRevenue.put(key, new BigDecimal(row[1].toString()));
            }
        }

        List<Map<String, Object>> chartData = new ArrayList<>();
        monthlyRevenue.forEach((month, amount) -> {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("month", month);
            entry.put("revenue", amount);
            chartData.add(entry);
        });

        BigDecimal totalRevenue = monthlyRevenue.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("chartData", chartData);
        result.put("totalRevenue", totalRevenue);
        result.put("averageMonthly", chartData.isEmpty() ? 0
                : totalRevenue.divide(BigDecimal.valueOf(chartData.size()), 2, java.math.RoundingMode.HALF_UP));
        return result;
    }

    // ── Push Notification Broadcast ───────────────────────────────────────────

    public Map<String, Object> broadcastNotification(String title, String message, String audience) {
        addAuditEntry("ADMIN", "Broadcast sent [" + audience + "]: " + title);
        
        List<User> targetUsers;
        if ("OWNERS".equalsIgnoreCase(audience)) {
            targetUsers = userRepository.findByRoleAndFcmTokenIsNotNull(com.solapur.turf.enums.UserRole.OWNER);
        } else if ("PLAYERS".equalsIgnoreCase(audience)) {
            targetUsers = userRepository.findByRoleAndFcmTokenIsNotNull(com.solapur.turf.enums.UserRole.USER);
        } else {
            targetUsers = userRepository.findByFcmTokenIsNotNull();
        }

        int successCount = 0;
        for (User user : targetUsers) {
            if (user.getFcmToken() != null && !user.getFcmToken().isBlank()) {
                notificationService.sendPushNotification(user.getFcmToken(), title, message);
                successCount++;
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "COMPLETED");
        result.put("title", title);
        result.put("message", message);
        result.put("audience", audience != null ? audience : "ALL");
        result.put("sentAt", LocalDateTime.now().toString());
        result.put("estimatedReach", targetUsers.size());
        result.put("actualSent", successCount);
        return result;
    }

    // ── Platform Settings ─────────────────────────────────────────────────────

    public PlatformSettings getSettings() {
        return settingsRepository.getSettings();
    }

    @Transactional
    public PlatformSettings updateSettings(PlatformSettings updates) {
        PlatformSettings existing = settingsRepository.getSettings();
        
        if (updates.getPlatformName() != null) existing.setPlatformName(updates.getPlatformName());
        if (updates.getPlatformFeePercentage() != null) existing.setPlatformFeePercentage(updates.getPlatformFeePercentage());
        if (updates.getPartialAdvanceAmount() != null) existing.setPartialAdvanceAmount(updates.getPartialAdvanceAmount());
        if (updates.getSupportEmail() != null) existing.setSupportEmail(updates.getSupportEmail());
        if (updates.getSupportContact() != null) existing.setSupportContact(updates.getSupportContact());
        if (updates.getMinimumCancellationHours() != null) existing.setMinimumCancellationHours(updates.getMinimumCancellationHours());
        if (updates.getMaxBookingsPerUser() != null) existing.setMaxBookingsPerUser(updates.getMaxBookingsPerUser());
        
        existing.setMaintenanceMode(updates.isMaintenanceMode());
        
        addAuditEntry("ADMIN", "Platform settings updated");
        return settingsRepository.save(existing);
    }

    // ── Audit Log ─────────────────────────────────────────────────────────────

    public List<AuditLog> getAuditLog() {
        return auditLogRepository.findTop100ByOrderByTimestampDesc();
    }

    // ── Owner Approval ────────────────────────────────────────────────────────

    public List<Map<String, Object>> getPendingOwners() {
        return turfOwnerRepository.findByVerificationStatus(VerificationStatus.PENDING)
                .stream().map(this::ownerToMap).toList();
    }

    @Transactional
    public Map<String, Object> approveOwner(UUID ownerId) {
        TurfOwner owner = turfOwnerRepository.findById(ownerId)
                .orElseThrow(() -> new ApiException("Owner not found", HttpStatus.NOT_FOUND));

        owner.setVerificationStatus(VerificationStatus.APPROVED);
        owner.setActive(true);
        if (owner.getTrialEndsAt() == null) {
            owner.setTrialStartsAt(java.time.LocalDateTime.now());
            owner.setTrialEndsAt(java.time.LocalDateTime.now().plusDays(30));
        }
        turfOwnerRepository.save(owner);

        User user = owner.getUser();
        user.setVerified(true);
        user.setActive(true);
        userRepository.save(user);

        addAuditEntry("ADMIN", "Approved owner: " + owner.getBusinessName() + " [" + user.getEmail() + "]");
        return ownerToMap(owner);
    }

    @Transactional
    public Map<String, Object> rejectOwner(UUID ownerId, String reason) {
        TurfOwner owner = turfOwnerRepository.findById(ownerId)
                .orElseThrow(() -> new ApiException("Owner not found", HttpStatus.NOT_FOUND));

        owner.setVerificationStatus(VerificationStatus.REJECTED);
        owner.setActive(false);
        turfOwnerRepository.save(owner);

        User user = owner.getUser();
        user.setVerified(false);
        user.setActive(false);
        userRepository.save(user);

        addAuditEntry("ADMIN", "Rejected owner: " + owner.getBusinessName() + " — " + reason);
        return ownerToMap(owner);
    }

    // ── Turf Management ───────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<TurfListing> getAllTurfs() {
        return turfListingRepository.findAll();
    }

    @Transactional
    @CacheEvict(value = "activeTurfs", allEntries = true)
    public TurfListing toggleTurfStatus(UUID turfId, boolean isActive) {
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));
        turf.setActive(isActive);
        addAuditEntry("ADMIN", (isActive ? "Enabled" : "Disabled") + " turf: " + turf.getName());
        return turfListingRepository.save(turf);
    }

    @Transactional
    @CacheEvict(value = "activeTurfs", allEntries = true)
    public TurfListing toggleTurfFeatured(UUID turfId, boolean isFeatured) {
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Featured is a paid add-on (₹199/month).
        // Admin toggles this AFTER verifying payment — works for both TRIAL and ACTIVE owners.
        // The feature is NOT auto-granted during free trial, only when explicitly purchased.
        turf.setFeatured(isFeatured);
        addAuditEntry("ADMIN", (isFeatured ? "Featured" : "Unfeatured") + " turf: " + turf.getName()
                + " (owner status: " + (turf.getOwner() != null ? turf.getOwner().getSubscriptionStatus() : "N/A") + ")");
        return turfListingRepository.save(turf);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private Map<String, Object> ownerToMap(TurfOwner o) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ownerId", o.getId());
        m.put("businessName", o.getBusinessName());
        m.put("contactNumber", o.getContactNumber());
        m.put("city", o.getCity());
        m.put("state", o.getState());
        m.put("pinCode", o.getPinCode());
        m.put("upiId", o.getUpiId());
        m.put("gstNumber", o.getGstNumber());
        m.put("panNumber", o.getPanNumber());
        m.put("verificationDocuments", o.getVerificationDocuments());
        m.put("verificationStatus", o.getVerificationStatus());
        m.put("userEmail", o.getUser().getEmail());
        m.put("userPhone", o.getUser().getPhone());
        m.put("userName", o.getUser().getFullName());
        return m;
    }

    private void addAuditEntry(String actor, String action) {
        try {
            auditLogRepository.save(AuditLog.builder()
                    .actor(actor)
                    .action(action)
                    .timestamp(LocalDateTime.now())
                    .success(true)
                    .userEmail(actor)
                    .userRole("ADMIN")
                    .build());
        } catch (Exception ignored) {
            // Audit log failure should not break the main operation
        }
    }
}
