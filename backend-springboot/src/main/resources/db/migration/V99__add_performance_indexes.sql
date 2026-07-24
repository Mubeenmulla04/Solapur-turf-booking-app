-- ============================================================
-- Performance Indexes Migration
-- Apply these indexes to the PostgreSQL database to fix
-- the N+1 query and full-scan issues identified in the audit.
-- ============================================================

-- 1. Speeds up GET /api/turfs (findByIsActiveTrueAndIsVerifiedTrue)
CREATE INDEX IF NOT EXISTS idx_turfs_active_verified
    ON turf_listings(is_active, is_verified)
    WHERE is_active = true AND is_verified = true;

-- 2. Speeds up turf search by sport type
CREATE INDEX IF NOT EXISTS idx_turfs_sport_type
    ON turf_listings(sport_type);

-- 3. Speeds up booking conflict detection (pessimistic lock query)
CREATE INDEX IF NOT EXISTS idx_bookings_turf_date_status
    ON bookings(turf_id, booking_date, booking_status);

-- 4. Speeds up user booking history (GET /api/bookings/my-bookings)
CREATE INDEX IF NOT EXISTS idx_bookings_user_id
    ON bookings(user_id);

-- 5. Speeds up owner dashboard (GET /api/bookings/owner-bookings)
CREATE INDEX IF NOT EXISTS idx_bookings_owner
    ON bookings(turf_id);

-- 6. Speeds up OTP verification (forgot-password flow)
CREATE INDEX IF NOT EXISTS idx_otp_email_expires
    ON otp_codes(email, expires_at);

-- 7. Speeds up settlement queries
CREATE INDEX IF NOT EXISTS idx_settlements_owner_status
    ON settlements(owner_id, status);

-- 8. Speeds up user management (admin panel)
CREATE INDEX IF NOT EXISTS idx_users_role
    ON users(role);

-- 9. Speeds up turf lookup by owner
CREATE INDEX IF NOT EXISTS idx_turfs_owner_id
    ON turf_listings(owner_id);

-- 10. Speeds up scheduled security audit queries
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp
    ON audit_logs(timestamp);

-- 11. Speeds up user login and authentication lookups
CREATE INDEX IF NOT EXISTS idx_users_email
    ON users(email);

CREATE INDEX IF NOT EXISTS idx_users_phone
    ON users(phone);

