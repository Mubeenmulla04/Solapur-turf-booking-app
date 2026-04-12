-- =====================================================
-- Solapur Turf Booking App - PostgreSQL Database Schema
-- =====================================================
-- Complete schema with tables, relationships, constraints
-- Includes seed data for testing
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search
CREATE EXTENSION IF NOT EXISTS "cube"; -- Required for earthdistance
CREATE EXTENSION IF NOT EXISTS "earthdistance"; -- For location-based search

-- =====================================================
-- 1. CORE TABLES
-- =====================================================

-- Users table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('USER', 'OWNER', 'ADMIN')),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    profile_image_url TEXT,
    loyalty_points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Turf owners table
CREATE TABLE turf_owners (
    owner_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    gst_number VARCHAR(50),
    pan_number VARCHAR(20),
    bank_account_number VARCHAR(50),
    bank_ifsc VARCHAR(20),
    bank_account_name VARCHAR(255),
    verification_status VARCHAR(20) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    verification_documents JSONB,
    total_earnings DECIMAL(12, 2) DEFAULT 0.00,
    pending_settlement DECIMAL(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Turf amenities master table
CREATE TABLE turf_amenities_master (
    amenity_id SERIAL PRIMARY KEY,
    amenity_name VARCHAR(100) UNIQUE NOT NULL,
    icon_url TEXT
);

-- Turf listings table
CREATE TABLE turf_listings (
    turf_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES turf_owners(owner_id) ON DELETE CASCADE,
    turf_name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    sport_type VARCHAR(50) NOT NULL CHECK (sport_type IN ('FOOTBALL', 'CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON', 'MULTI_SPORT')),
    surface_type VARCHAR(50) NOT NULL CHECK (surface_type IN ('NATURAL_GRASS', 'ARTIFICIAL_GRASS', 'CONCRETE', 'WOODEN', 'CLAY')),
    size VARCHAR(100),
    hourly_rate DECIMAL(10, 2) NOT NULL CHECK (hourly_rate > 0),
    peak_hour_rate DECIMAL(10, 2),
    peak_hours JSONB, -- e.g., ["18:00-22:00", "19:00-21:00"]
    amenities JSONB, -- Array of amenity names
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    rating_average DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating_average >= 0 AND rating_average <= 5),
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Turf images table
CREATE TABLE turf_images (
    image_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    turf_id UUID NOT NULL REFERENCES turf_listings(turf_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. BOOKING & PAYMENT TABLES
-- =====================================================

-- Coupons table (created before bookings as it's referenced there)
CREATE TABLE coupons (
    coupon_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED')),
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_amount DECIMAL(10, 2) DEFAULT 0.00,
    max_discount DECIMAL(10, 2),
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (valid_until > valid_from),
    CHECK (used_count <= usage_limit OR usage_limit IS NULL)
);

-- Bookings table
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    turf_id UUID NOT NULL REFERENCES turf_listings(turf_id) ON DELETE RESTRICT,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    duration_hours DECIMAL(4, 2) NOT NULL CHECK (duration_hours > 0),
    base_amount DECIMAL(10, 2) NOT NULL CHECK (base_amount >= 0),
    peak_surcharge DECIMAL(10, 2) DEFAULT 0.00 CHECK (peak_surcharge >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    final_amount DECIMAL(10, 2) NOT NULL CHECK (final_amount >= 0),
    platform_commission DECIMAL(10, 2) DEFAULT 0.00 CHECK (platform_commission >= 0),
    owner_share DECIMAL(10, 2) DEFAULT 0.00 CHECK (owner_share >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('FULL_ONLINE', 'PARTIAL_ONLINE_CASH', 'CASH_ON_BOOKING', 'WALLET')),
    advance_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (advance_amount >= 0),
    cash_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (cash_amount >= 0),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'PARTIALLY_PAID', 'FAILED', 'REFUNDED')),
    booking_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (booking_status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    payment_gateway_order_id VARCHAR(255),
    payment_gateway_transaction_id VARCHAR(255),
    booking_code VARCHAR(20) UNIQUE NOT NULL, -- QR code identifier
    coupon_id UUID REFERENCES coupons(coupon_id),
    cancellation_reason TEXT,
    cancellation_time TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    rescheduled_at TIMESTAMP WITH TIME ZONE,
    reschedule_reason TEXT,
    reschedule_notes TEXT,
    old_date_time TIMESTAMP WITH TIME ZONE,
    additional_amount DECIMAL(10, 2) DEFAULT 0.00,
    refund_method VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Availability slots table (created after bookings table)
CREATE TABLE availability_slots (
    slot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    turf_id UUID NOT NULL REFERENCES turf_listings(turf_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'BOOKED', 'BLOCKED')),
    booking_id UUID REFERENCES bookings(booking_id) ON DELETE SET NULL,
    blocked_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(turf_id, date, start_time, end_time)
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(booking_id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('PAYMENT', 'REFUND', 'SETTLEMENT', 'WALLET_TOPUP', 'WALLET_DEBIT')),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(30),
    payment_gateway VARCHAR(50),
    gateway_order_id VARCHAR(255),
    gateway_payment_id VARCHAR(255),
    gateway_signature TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED', 'PENDING')),
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Settlements table
CREATE TABLE settlements (
    settlement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES turf_owners(owner_id) ON DELETE RESTRICT,
    booking_id UUID UNIQUE REFERENCES bookings(booking_id) ON DELETE RESTRICT,
    settlement_amount DECIMAL(10, 2) NOT NULL CHECK (settlement_amount >= 0),
    commission_amount DECIMAL(10, 2) NOT NULL CHECK (commission_amount >= 0),
    transaction_fee DECIMAL(10, 2) DEFAULT 0.00 CHECK (transaction_fee >= 0),
    settlement_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED')),
    payment_reference_id VARCHAR(255),
    bank_transaction_id VARCHAR(255),
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User wallet table
CREATE TABLE user_wallet (
    wallet_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0.00 CHECK (balance >= 0),
    total_added DECIMAL(12, 2) DEFAULT 0.00,
    total_spent DECIMAL(12, 2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Wallet transactions table
CREATE TABLE wallet_transactions (
    wallet_transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES user_wallet(wallet_id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('CREDIT', 'DEBIT')),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    reference_type VARCHAR(50), -- REFUND, TOP_UP, BOOKING
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Reviews table
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID UNIQUE NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    turf_id UUID NOT NULL REFERENCES turf_listings(turf_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    owner_response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User favorites table
CREATE TABLE user_favorites (
    favorite_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    turf_id UUID NOT NULL REFERENCES turf_listings(turf_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, turf_id)
);

-- =====================================================
-- 3. TEAMS TABLES
-- =====================================================

-- Teams table
CREATE TABLE teams (
    team_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_name VARCHAR(255) NOT NULL,
    team_code VARCHAR(10) UNIQUE NOT NULL, -- 6-8 alphanumeric code
    sport_type VARCHAR(50) NOT NULL CHECK (sport_type IN ('FOOTBALL', 'CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON')),
    description TEXT,
    logo_url TEXT,
    home_city VARCHAR(100),
    admin_user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    member_count INTEGER DEFAULT 1 CHECK (member_count > 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_name, admin_user_id) -- Team name unique per admin
);

-- Team members table
CREATE TABLE team_members (
    team_member_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'MEMBER' CHECK (role IN ('ADMIN', 'MEMBER')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(team_id, user_id)
);

-- Team matches table
CREATE TABLE team_matches (
    team_match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(booking_id) ON DELETE SET NULL,
    opponent_team_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    match_type VARCHAR(20) NOT NULL CHECK (match_type IN ('FRIENDLY', 'TOURNAMENT')),
    tournament_id UUID REFERENCES tournaments(tournament_id) ON DELETE SET NULL,
    result VARCHAR(20) CHECK (result IN ('WIN', 'LOSS', 'DRAW', 'PENDING')),
    score_team INTEGER DEFAULT 0 CHECK (score_team >= 0),
    score_opponent INTEGER DEFAULT 0 CHECK (score_opponent >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. TOURNAMENT TABLES
-- =====================================================

-- Tournaments table
CREATE TABLE tournaments (
    tournament_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    creator_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    creator_type VARCHAR(20) NOT NULL CHECK (creator_type IN ('OWNER', 'ADMIN')),
    turf_id UUID REFERENCES turf_listings(turf_id) ON DELETE SET NULL,
    tournament_name VARCHAR(255) NOT NULL,
    sport_type VARCHAR(50) NOT NULL CHECK (sport_type IN ('FOOTBALL', 'CRICKET', 'BASKETBALL', 'VOLLEYBALL', 'TENNIS', 'BADMINTON')),
    format VARCHAR(20) NOT NULL CHECK (format IN ('KNOCKOUT', 'LEAGUE', 'ROUND_ROBIN')),
    entry_fee_per_team DECIMAL(10, 2) DEFAULT 0.00 CHECK (entry_fee_per_team >= 0),
    prize_pool_winner DECIMAL(10, 2) DEFAULT 0.00 CHECK (prize_pool_winner >= 0),
    prize_pool_runner_up DECIMAL(10, 2) DEFAULT 0.00 CHECK (prize_pool_runner_up >= 0),
    max_teams INTEGER NOT NULL CHECK (max_teams > 0),
    min_teams INTEGER NOT NULL CHECK (min_teams > 0 AND min_teams <= max_teams),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    registration_status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (registration_status IN ('OPEN', 'CLOSED', 'CANCELLED')),
    tournament_status VARCHAR(20) NOT NULL DEFAULT 'UPCOMING' CHECK (tournament_status IN ('UPCOMING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    rules_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date >= start_date),
    CHECK (registration_deadline <= start_date)
);

-- Tournament registrations table
CREATE TABLE tournament_registrations (
    registration_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'REFUNDED')),
    payment_transaction_id UUID REFERENCES transactions(transaction_id),
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'REGISTERED' CHECK (status IN ('REGISTERED', 'WITHDRAWN', 'DISQUALIFIED')),
    UNIQUE(tournament_id, team_id)
);

-- Tournament matches table
CREATE TABLE tournament_matches (
    tournament_match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL CHECK (round_number > 0),
    match_number INTEGER NOT NULL CHECK (match_number > 0),
    team1_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    team2_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    booking_id UUID REFERENCES bookings(booking_id) ON DELETE SET NULL,
    scheduled_date DATE,
    scheduled_time TIME,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    winner_team_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    team1_score INTEGER DEFAULT 0 CHECK (team1_score >= 0),
    team2_score INTEGER DEFAULT 0 CHECK (team2_score >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tournament_id, round_number, match_number)
);

-- Tournament brackets table (for knockout format)
CREATE TABLE tournament_brackets (
    bracket_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL CHECK (round_number > 0),
    match_number INTEGER NOT NULL CHECK (match_number > 0),
    parent_match1_id UUID REFERENCES tournament_matches(tournament_match_id) ON DELETE SET NULL,
    parent_match2_id UUID REFERENCES tournament_matches(tournament_match_id) ON DELETE SET NULL,
    team1_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    team2_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
    bracket_position INTEGER NOT NULL,
    UNIQUE(tournament_id, round_number, match_number)
);

-- =====================================================
-- 5. NOTIFICATIONS TABLE
-- =====================================================

CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- BOOKING_CONFIRMED, PAYMENT_SUCCESS, TOURNAMENT_UPDATE, etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50), -- BOOKING, TOURNAMENT, etc.
    reference_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 6. INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- Turf listings indexes
CREATE INDEX idx_turf_listings_owner ON turf_listings(owner_id);
CREATE INDEX idx_turf_listings_city ON turf_listings(city);
CREATE INDEX idx_turf_listings_sport ON turf_listings(sport_type);
CREATE INDEX idx_turf_listings_active ON turf_listings(is_active) WHERE is_active = TRUE;
-- Location index for proximity searches (using earthdistance extension)
CREATE INDEX idx_turf_listings_location ON turf_listings USING GIST (ll_to_earth(latitude, longitude));
-- Alternative simple index for basic lat/long queries
CREATE INDEX idx_turf_listings_lat_lng ON turf_listings(latitude, longitude);

-- Bookings indexes
CREATE INDEX idx_bookings_user ON bookings(user_id, created_at DESC);
CREATE INDEX idx_bookings_turf ON bookings(turf_id, booking_date, start_time);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_code ON bookings(booking_code);

-- Availability slots indexes
CREATE INDEX idx_availability_turf_date ON availability_slots(turf_id, date);
CREATE INDEX idx_availability_status ON availability_slots(status) WHERE status = 'AVAILABLE';
CREATE INDEX idx_availability_booking ON availability_slots(booking_id) WHERE booking_id IS NOT NULL;

-- Transactions indexes
CREATE INDEX idx_transactions_user ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_booking ON transactions(booking_id);
CREATE INDEX idx_transactions_status ON transactions(status);

-- Settlements indexes
CREATE INDEX idx_settlements_owner ON settlements(owner_id, status);
CREATE INDEX idx_settlements_status ON settlements(status);
CREATE INDEX idx_settlements_date ON settlements(settlement_date);

-- Teams indexes
CREATE INDEX idx_teams_admin ON teams(admin_user_id);
CREATE INDEX idx_teams_code ON teams(team_code);
CREATE INDEX idx_team_members_team ON team_members(team_id);
CREATE INDEX idx_team_members_user ON team_members(user_id);

-- Tournaments indexes
CREATE INDEX idx_tournaments_status ON tournaments(tournament_status, registration_status);
CREATE INDEX idx_tournaments_date ON tournaments(start_date, end_date);
CREATE INDEX idx_tournaments_creator ON tournaments(creator_id);
CREATE INDEX idx_tournament_registrations_tournament ON tournament_registrations(tournament_id);
CREATE INDEX idx_tournament_registrations_team ON tournament_registrations(team_id);
CREATE INDEX idx_tournament_matches_tournament ON tournament_matches(tournament_id, round_number);

-- Reviews indexes
CREATE INDEX idx_reviews_turf ON reviews(turf_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);

-- Wallet indexes
CREATE INDEX idx_wallet_transactions_wallet ON wallet_transactions(wallet_id, created_at DESC);

-- =====================================================
-- 7. TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_turf_owners_updated_at BEFORE UPDATE ON turf_owners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_turf_listings_updated_at BEFORE UPDATE ON turf_listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_settlements_updated_at BEFORE UPDATE ON settlements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_wallet_updated_at BEFORE UPDATE ON user_wallet FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tournaments_updated_at BEFORE UPDATE ON tournaments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tournament_matches_updated_at BEFORE UPDATE ON tournament_matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update turf rating when review is added/updated
CREATE OR REPLACE FUNCTION update_turf_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE turf_listings
    SET 
        rating_average = (
            SELECT COALESCE(AVG(rating), 0)
            FROM reviews
            WHERE turf_id = NEW.turf_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE turf_id = NEW.turf_id
        )
    WHERE turf_id = NEW.turf_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_turf_rating_on_review AFTER INSERT OR UPDATE OR DELETE ON reviews FOR EACH ROW EXECUTE FUNCTION update_turf_rating();

-- Function to update team member count
CREATE OR REPLACE FUNCTION update_team_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE teams SET member_count = member_count + 1 WHERE team_id = NEW.team_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE teams SET member_count = member_count - 1 WHERE team_id = OLD.team_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_team_member_count_trigger AFTER INSERT OR DELETE ON team_members FOR EACH ROW EXECUTE FUNCTION update_team_member_count();

-- Function to generate unique booking code
CREATE OR REPLACE FUNCTION generate_booking_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booking_code IS NULL OR NEW.booking_code = '' THEN
        NEW.booking_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.booking_id::TEXT) FROM 1 FOR 8));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER generate_booking_code_trigger BEFORE INSERT ON bookings FOR EACH ROW EXECUTE FUNCTION generate_booking_code();

-- Function to generate unique team code
CREATE OR REPLACE FUNCTION generate_team_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.team_code IS NULL OR NEW.team_code = '' THEN
        NEW.team_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.team_id::TEXT) FROM 1 FOR 8));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER generate_team_code_trigger BEFORE INSERT ON teams FOR EACH ROW EXECUTE FUNCTION generate_team_code();

-- =====================================================
-- 8. SAMPLE SEED DATA
-- =====================================================

-- Insert admin user
INSERT INTO users (user_id, email, phone, password_hash, full_name, role, is_verified, is_active) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@turfapp.com', '9999999999', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'Admin User', 'ADMIN', TRUE, TRUE);

-- Insert regular users
INSERT INTO users (user_id, email, phone, password_hash, full_name, role, is_verified, is_active) VALUES
('10000000-0000-0000-0000-000000000001', 'user1@example.com', '9876543210', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'John Doe', 'USER', TRUE, TRUE),
('10000000-0000-0000-0000-000000000002', 'user2@example.com', '9876543211', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'Jane Smith', 'USER', TRUE, TRUE),
('10000000-0000-0000-0000-000000000003', 'user3@example.com', '9876543212', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'Bob Wilson', 'USER', TRUE, TRUE);

-- Insert turf owner user
INSERT INTO users (user_id, email, phone, password_hash, full_name, role, is_verified, is_active) VALUES
('20000000-0000-0000-0000-000000000001', 'owner1@example.com', '9876543220', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'Raj Sports', 'OWNER', TRUE, TRUE),
('20000000-0000-0000-0000-000000000002', 'owner2@example.com', '9876543221', '$2b$10$rOzJqN3KqXqXqXqXqXqXqeKqXqXqXqXqXqXqXqXqXqXqXqXqXq', 'Solapur Turf Club', 'OWNER', TRUE, TRUE);

-- Insert turf owners
INSERT INTO turf_owners (owner_id, user_id, business_name, gst_number, pan_number, bank_account_number, bank_ifsc, bank_account_name, verification_status) VALUES
('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Raj Sports Arena', '29ABCDE1234F1Z5', 'ABCDE1234F', '1234567890123456', 'SBIN0001234', 'Raj Sports Arena', 'VERIFIED'),
('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'Solapur Turf Club', '29FGHIJ5678K2Z6', 'FGHIJ5678K', '6543210987654321', 'HDFC0005678', 'Solapur Turf Club', 'VERIFIED');

-- Insert amenities master data
INSERT INTO turf_amenities_master (amenity_name, icon_url) VALUES
('Parking', '/icons/parking.svg'),
('Lights', '/icons/lights.svg'),
('Changing Room', '/icons/changing-room.svg'),
('Water', '/icons/water.svg'),
('Washroom', '/icons/washroom.svg'),
('First Aid', '/icons/first-aid.svg'),
('Refreshments', '/icons/refreshments.svg'),
('Seating', '/icons/seating.svg'),
('Security', '/icons/security.svg'),
('WiFi', '/icons/wifi.svg');

-- Insert turf listings
INSERT INTO turf_listings (turf_id, owner_id, turf_name, address, city, state, pincode, latitude, longitude, sport_type, surface_type, size, hourly_rate, peak_hour_rate, peak_hours, amenities, description, is_active) VALUES
('40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Raj Sports Football Ground', '123 Sports Street, Solapur', 'Solapur', 'Maharashtra', '413001', 17.6599, 75.9064, 'FOOTBALL', 'ARTIFICIAL_GRASS', '100m x 60m', 500.00, 700.00, '["18:00-22:00"]', '["Parking", "Lights", "Changing Room", "Water", "Washroom"]', 'Premium football turf with artificial grass, well-maintained facilities', TRUE),
('40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'Raj Sports Cricket Ground', '123 Sports Street, Solapur', 'Solapur', 'Maharashtra', '413001', 17.6600, 75.9065, 'CRICKET', 'NATURAL_GRASS', '22 yards pitch', 800.00, 1000.00, '["18:00-22:00"]', '["Parking", "Lights", "Changing Room", "Water", "Refreshments"]', 'Professional cricket ground with natural grass pitch', TRUE),
('40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000002', 'Solapur Turf Multi-Sport', '456 Arena Road, Solapur', 'Solapur', 'Maharashtra', '413002', 17.6700, 75.9100, 'MULTI_SPORT', 'ARTIFICIAL_GRASS', 'Multi-purpose', 600.00, 800.00, '["18:00-22:00"]', '["Parking", "Lights", "Changing Room", "Water", "Washroom", "First Aid", "Seating"]', 'Versatile multi-sport turf suitable for various sports', TRUE);

-- Insert turf images
INSERT INTO turf_images (image_id, turf_id, image_url, image_order, is_primary) VALUES
('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'https://example.com/images/turf1-main.jpg', 1, TRUE),
('50000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001', 'https://example.com/images/turf1-2.jpg', 2, FALSE),
('50000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000002', 'https://example.com/images/turf2-main.jpg', 1, TRUE),
('50000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000003', 'https://example.com/images/turf3-main.jpg', 1, TRUE);

-- Create wallets for users
INSERT INTO user_wallet (wallet_id, user_id, balance, total_added, total_spent) VALUES
('60000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 500.00, 1000.00, 500.00),
('60000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 0.00, 0.00, 0.00),
('60000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', 0.00, 0.00, 0.00);

-- Insert sample coupons
INSERT INTO coupons (coupon_id, coupon_code, discount_type, discount_value, min_amount, max_discount, valid_from, valid_until, usage_limit, used_count, is_active) VALUES
('70000000-0000-0000-0000-000000000001', 'WELCOME100', 'FIXED', 100.00, 500.00, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 100, 5, TRUE),
('70000000-0000-0000-0000-000000000002', 'DISCOUNT10', 'PERCENTAGE', 10.00, 1000.00, 200.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '60 days', 50, 2, TRUE),
('70000000-0000-0000-0000-000000000003', 'FIRST50', 'PERCENTAGE', 50.00, 500.00, 300.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '15 days', 20, 0, TRUE);

-- Insert sample bookings
INSERT INTO bookings (booking_id, user_id, turf_id, booking_date, start_time, end_time, duration_hours, base_amount, peak_surcharge, discount_amount, final_amount, platform_commission, owner_share, payment_method, payment_status, booking_status, booking_code) VALUES
('80000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', CURRENT_DATE + INTERVAL '7 days', '18:00:00', '20:00:00', 2.00, 1000.00, 400.00, 100.00, 1300.00, 195.00, 1105.00, 'FULL_ONLINE', 'PAID', 'CONFIRMED', 'BOOK001'),
('80000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000003', CURRENT_DATE + INTERVAL '10 days', '19:00:00', '21:00:00', 2.00, 1200.00, 400.00, 0.00, 1600.00, 240.00, 1360.00, 'PARTIAL_ONLINE_CASH', 'PARTIALLY_PAID', 'CONFIRMED', 'BOOK002');

-- Insert sample teams
INSERT INTO teams (team_id, team_name, team_code, sport_type, description, home_city, admin_user_id, member_count) VALUES
('90000000-0000-0000-0000-000000000001', 'Solapur Strikers', 'STRIKER1', 'FOOTBALL', 'Local football team', 'Solapur', '10000000-0000-0000-0000-000000000001', 1),
('90000000-0000-0000-0000-000000000002', 'Cricket Champions', 'CRICKET1', 'CRICKET', 'Amateur cricket team', 'Solapur', '10000000-0000-0000-0000-000000000002', 1);

-- Insert team members
INSERT INTO team_members (team_member_id, team_id, user_id, role) VALUES
('a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'ADMIN'),
('a0000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'MEMBER'),
('a0000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'ADMIN');

-- Update team member counts (since triggers will handle this, but for seed data we set manually)
UPDATE teams SET member_count = 2 WHERE team_id = '90000000-0000-0000-0000-000000000001';

-- Insert sample tournament
INSERT INTO tournaments (tournament_id, creator_id, creator_type, turf_id, tournament_name, sport_type, format, entry_fee_per_team, prize_pool_winner, prize_pool_runner_up, max_teams, min_teams, start_date, end_date, registration_deadline, registration_status, tournament_status) VALUES
('b0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'OWNER', '40000000-0000-0000-0000-000000000001', 'Solapur Football Championship 2024', 'FOOTBALL', 'KNOCKOUT', 500.00, 5000.00, 2000.00, 16, 8, CURRENT_DATE + INTERVAL '30 days', CURRENT_DATE + INTERVAL '37 days', CURRENT_DATE + INTERVAL '25 days', 'OPEN', 'UPCOMING');

-- Insert tournament registration
INSERT INTO tournament_registrations (registration_id, tournament_id, team_id, payment_status, status) VALUES
('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', 'PAID', 'REGISTERED');

-- Insert sample reviews
INSERT INTO reviews (review_id, booking_id, user_id, turf_id, rating, review_text) VALUES
('d0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 5, 'Excellent turf with great facilities. Highly recommended!');

-- Insert sample transactions
INSERT INTO transactions (transaction_id, booking_id, user_id, transaction_type, amount, payment_method, payment_gateway, status) VALUES
('e0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'PAYMENT', 1300.00, 'ONLINE', 'RAZORPAY', 'SUCCESS'),
('e0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'PAYMENT', 800.00, 'ONLINE', 'RAZORPAY', 'SUCCESS');

-- Insert sample settlements
INSERT INTO settlements (settlement_id, owner_id, booking_id, settlement_amount, commission_amount, transaction_fee, settlement_date, status) VALUES
('f0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', 1105.00, 195.00, 10.00, CURRENT_DATE + INTERVAL '2 days', 'PENDING');

-- Insert sample notifications
INSERT INTO notifications (notification_id, user_id, type, title, message, reference_type, reference_id, is_read) VALUES
('10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'BOOKING_CONFIRMED', 'Booking Confirmed', 'Your booking BOOK001 has been confirmed', 'BOOKING', '80000000-0000-0000-0000-000000000001', FALSE),
('10000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'PAYMENT_SUCCESS', 'Payment Successful', 'Payment of ₹800 for booking BOOK002 was successful', 'BOOKING', '80000000-0000-0000-0000-000000000002', FALSE);

-- =====================================================
-- 9. VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for active turfs with owner info
CREATE OR REPLACE VIEW v_active_turfs AS
SELECT 
    t.turf_id,
    t.turf_name,
    t.address,
    t.city,
    t.sport_type,
    t.hourly_rate,
    t.rating_average,
    t.total_reviews,
    o.business_name as owner_name,
    u.email as owner_email,
    u.phone as owner_phone
FROM turf_listings t
JOIN turf_owners o ON t.owner_id = o.owner_id
JOIN users u ON o.user_id = u.user_id
WHERE t.is_active = TRUE AND o.verification_status = 'VERIFIED';

-- View for booking details with user and turf info
CREATE OR REPLACE VIEW v_booking_details AS
SELECT 
    b.booking_id,
    b.booking_code,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.final_amount,
    b.payment_status,
    b.booking_status,
    u.full_name as user_name,
    u.email as user_email,
    u.phone as user_phone,
    tl.turf_name,
    tl.address as turf_address,
    to_owner.business_name as owner_name
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN turf_listings tl ON b.turf_id = tl.turf_id
JOIN turf_owners to_owner ON tl.owner_id = to_owner.owner_id;

-- View for owner earnings summary
CREATE OR REPLACE VIEW v_owner_earnings AS
SELECT 
    o.owner_id,
    o.business_name,
    SUM(s.settlement_amount) as total_settled,
    SUM(s.commission_amount) as total_commission_paid,
    COUNT(s.settlement_id) as total_settlements,
    o.pending_settlement
FROM turf_owners o
LEFT JOIN settlements s ON o.owner_id = s.owner_id AND s.status = 'PROCESSED'
GROUP BY o.owner_id, o.business_name, o.pending_settlement;

-- View for tournament standings
CREATE OR REPLACE VIEW v_tournament_standings AS
SELECT 
    t.tournament_id,
    t.tournament_name,
    tm.team_id,
    tm.team_name,
    COUNT(CASE WHEN tm_result.result = 'WIN' THEN 1 END) as wins,
    COUNT(CASE WHEN tm_result.result = 'LOSS' THEN 1 END) as losses,
    COUNT(CASE WHEN tm_result.result = 'DRAW' THEN 1 END) as draws,
    COUNT(tm_result.team_match_id) as matches_played
FROM tournaments t
JOIN tournament_registrations tr ON t.tournament_id = tr.tournament_id
JOIN teams tm ON tr.team_id = tm.team_id
LEFT JOIN team_matches tm_result ON tm.team_id = tm_result.team_id AND tm_result.tournament_id = t.tournament_id
GROUP BY t.tournament_id, t.tournament_name, tm.team_id, tm.team_name
ORDER BY wins DESC, draws DESC;

-- =====================================================
-- END OF SCHEMA
-- =====================================================

