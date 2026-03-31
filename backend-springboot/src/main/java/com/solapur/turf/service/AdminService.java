package com.solapur.turf.service;

import com.solapur.turf.entity.*;
import com.solapur.turf.enums.VerificationStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.*;
import lombok.RequiredArgsConstructor;
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

    // ── Platform Stats ────────────────────────────────────────────────────────

    public Map<String, Object> getPlatformStats() {
        long totalUsers    = userRepository.count();
        long totalTurfs    = turfListingRepository.count();
        long totalBookings = bookingRepository.count();
        long pendingOwners = turfOwnerRepository.countByVerificationStatus(VerificationStatus.PENDING);

        BigDecimal totalRevenue = bookingRepository.findAll().stream()
                .map(b -> b.getFinalAmount() != null ? b.getFinalAmount() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

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
        Map<String, BigDecimal> monthlyRevenue = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM yyyy");
        LocalDate now = LocalDate.now();

        for (int i = 5; i >= 0; i--) {
            LocalDate month = now.minusMonths(i).withDayOfMonth(1);
            monthlyRevenue.put(month.format(fmt), BigDecimal.ZERO);
        }

        bookingRepository.findAll().forEach(booking -> {
            if (booking.getBookingDate() == null || booking.getFinalAmount() == null) return;
            String key = booking.getBookingDate().withDayOfMonth(1).format(fmt);
            if (monthlyRevenue.containsKey(key)) {
                monthlyRevenue.merge(key, booking.getFinalAmount(), BigDecimal::add);
            }
        });

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
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "QUEUED");
        result.put("title", title);
        result.put("message", message);
        result.put("audience", audience != null ? audience : "ALL");
        result.put("scheduledAt", LocalDateTime.now().toString());
        result.put("estimatedReach", userRepository.count());
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
        if (updates.getSupportEmail() != null) existing.setSupportEmail(updates.getSupportEmail());
        if (updates.getSupportContact() != null) existing.setSupportContact(updates.getSupportContact());
        if (updates.getMinimumCancellationHours() != null) existing.setMinimumCancellationHours(updates.getMinimumCancellationHours());
        
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

    public List<TurfListing> getAllTurfs() {
        return turfListingRepository.findAll();
    }

    @Transactional
    public TurfListing toggleTurfStatus(UUID turfId, boolean isActive) {
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));
        turf.setActive(isActive);
        addAuditEntry("ADMIN", (isActive ? "Enabled" : "Disabled") + " turf: " + turf.getName());
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
        m.put("verificationStatus", o.getVerificationStatus());
        m.put("userEmail", o.getUser().getEmail());
        m.put("userPhone", o.getUser().getPhone());
        m.put("userName", o.getUser().getFullName());
        return m;
    }

    private void addAuditEntry(String actor, String action) {
        auditLogRepository.save(AuditLog.builder()
                .actor(actor)
                .action(action)
                .timestamp(LocalDateTime.now())
                .build());
    }
}
