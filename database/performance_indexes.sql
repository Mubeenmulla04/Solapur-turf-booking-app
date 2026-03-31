-- Performance Optimization Indexes
-- Add these indexes to improve query performance

-- =====================================================
-- BOOKING INDEXES
-- =====================================================

-- User bookings lookup (most common query)
CREATE INDEX IF NOT EXISTS idx_bookings_user_status ON bookings(user_id, booking_status, booking_date DESC);

-- Owner bookings lookup
CREATE INDEX IF NOT EXISTS idx_bookings_turf_owner ON bookings(turf_id, booking_status, booking_date DESC);

-- Date range queries
CREATE INDEX IF NOT EXISTS idx_bookings_date_range ON bookings(booking_date, booking_status) WHERE booking_status IN ('CONFIRMED', 'PENDING');

-- Payment status filtering
CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON bookings(payment_status, booking_status) WHERE payment_status = 'PENDING';

-- Settlement processing
CREATE INDEX IF NOT EXISTS idx_bookings_settlement ON bookings(turf_id, payment_status, booking_status, booking_date) 
  WHERE payment_status = 'PAID' AND booking_status = 'COMPLETED';

-- Composite index for common booking queries
CREATE INDEX IF NOT EXISTS idx_bookings_user_date_status ON bookings(user_id, booking_date DESC, booking_status);

-- =====================================================
-- AVAILABILITY SLOTS INDEXES
-- =====================================================

-- Slot availability check (critical for booking)
CREATE INDEX IF NOT EXISTS idx_slots_availability ON availability_slots(turf_id, slot_date, start_time, end_time, status);

-- Booking slot lookup
CREATE INDEX IF NOT EXISTS idx_slots_booking ON availability_slots(booking_id) WHERE booking_id IS NOT NULL;

-- Available slots query
CREATE INDEX IF NOT EXISTS idx_slots_available ON availability_slots(turf_id, slot_date, status) 
  WHERE status = 'AVAILABLE';

-- =====================================================
-- TURF LISTINGS INDEXES
-- =====================================================

-- Active turfs search (most common)
CREATE INDEX IF NOT EXISTS idx_turf_active_search ON turf_listings(is_active, city, sport_type) WHERE is_active = TRUE;

-- Full-text search on turf name and description
CREATE INDEX IF NOT EXISTS idx_turf_search_text ON turf_listings USING gin(to_tsvector('english', turf_name || ' ' || COALESCE(description, '')));

-- Price range queries
CREATE INDEX IF NOT EXISTS idx_turf_price ON turf_listings(price_per_hour) WHERE is_active = TRUE;

-- Rating sorting
CREATE INDEX IF NOT EXISTS idx_turf_rating ON turf_listings(rating DESC NULLS LAST) WHERE is_active = TRUE;

-- Location-based queries
CREATE INDEX IF NOT EXISTS idx_turf_location ON turf_listings USING gist(location) WHERE is_active = TRUE;

-- =====================================================
-- TRANSACTIONS INDEXES
-- =====================================================

-- User transaction history
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id, created_at DESC);

-- Booking transaction lookup
CREATE INDEX IF NOT EXISTS idx_transactions_booking ON transactions(booking_id) WHERE booking_id IS NOT NULL;

-- Payment gateway queries
CREATE INDEX IF NOT EXISTS idx_transactions_gateway ON transactions(payment_gateway, status, created_at DESC);

-- =====================================================
-- TOURNAMENTS INDEXES
-- =====================================================

-- Active tournaments
CREATE INDEX IF NOT EXISTS idx_tournaments_active ON tournaments(tournament_status, registration_status, start_date) 
  WHERE tournament_status = 'UPCOMING' AND registration_status = 'OPEN';

-- Tournament registrations
CREATE INDEX IF NOT EXISTS idx_tournament_registrations_team ON tournament_registrations(team_id, status);
CREATE INDEX IF NOT EXISTS idx_tournament_registrations_tournament ON tournament_registrations(tournament_id, status, payment_status);

-- =====================================================
-- SETTLEMENTS INDEXES
-- =====================================================

-- Owner settlements
CREATE INDEX IF NOT EXISTS idx_settlements_owner ON settlements(owner_id, status, settlement_date DESC);

-- Pending settlements processing
CREATE INDEX IF NOT EXISTS idx_settlements_pending ON settlements(status, settlement_date) WHERE status = 'PENDING';

-- =====================================================
-- TEAMS INDEXES
-- =====================================================

-- User teams lookup
CREATE INDEX IF NOT EXISTS idx_team_members_user ON team_members(user_id, is_active) WHERE is_active = TRUE;

-- Team code lookup (already unique, but explicit index)
CREATE INDEX IF NOT EXISTS idx_teams_code ON teams(team_code);

-- =====================================================
-- COMPOSITE INDEXES FOR COMMON QUERIES
-- =====================================================

-- Turf owner verification status
CREATE INDEX IF NOT EXISTS idx_turf_owner_verified ON turf_owners(user_id, verification_status) WHERE verification_status = 'VERIFIED';

-- Reviews for turf
CREATE INDEX IF NOT EXISTS idx_reviews_turf ON reviews(turf_id, rating DESC, created_at DESC);

-- User wallet transactions
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet ON wallet_transactions(wallet_id, created_at DESC);

-- =====================================================
-- QUERY OPTIMIZATION NOTES
-- =====================================================

-- 1. Use EXPLAIN ANALYZE to check query plans
-- 2. Monitor slow queries (> 1000ms)
-- 3. Update statistics: ANALYZE table_name;
-- 4. Consider partitioning for large tables (bookings, transactions)
-- 5. Use covering indexes where possible
-- 6. Monitor index usage: pg_stat_user_indexes

-- =====================================================
-- MATERIALIZED VIEWS FOR ANALYTICS
-- =====================================================

-- Daily booking summary (refresh periodically)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_daily_bookings AS
SELECT 
  DATE(booking_date) as date,
  turf_id,
  COUNT(*) as total_bookings,
  COUNT(CASE WHEN booking_status = 'CONFIRMED' THEN 1 END) as confirmed_bookings,
  SUM(final_amount) as total_revenue
FROM bookings
WHERE booking_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(booking_date), turf_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_bookings ON mv_daily_bookings(date, turf_id);

-- Refresh materialized view (run periodically, e.g., daily)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_bookings;

