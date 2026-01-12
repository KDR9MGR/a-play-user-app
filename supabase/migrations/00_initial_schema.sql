-- =====================================================
-- A-PLAY STAGING DATABASE - INITIAL SCHEMA
-- =====================================================
-- Created: December 16, 2024
-- Purpose: Complete database setup for staging environment
-- Order: Run this file FIRST
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. PROFILES TABLE
-- =====================================================
-- Stores user profile information
-- Links to Supabase auth.users table

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  bio TEXT,
  location TEXT,

  -- Subscription tier (denormalized for quick access)
  current_tier TEXT DEFAULT 'Free' CHECK (current_tier IN ('Free', 'Gold', 'Platinum', 'Black')),

  -- Account status
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,

  -- Preferences
  preferences JSONB DEFAULT '{}',
  notification_settings JSONB DEFAULT '{"email": true, "push": true, "sms": false}',

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for profiles
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_current_tier ON profiles(current_tier);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- =====================================================
-- 2. SUBSCRIPTION PLANS TABLE (NEW SCHEMA)
-- =====================================================
-- Updated to match admin panel schema

CREATE TABLE IF NOT EXISTS subscription_plans (
  id TEXT PRIMARY KEY,  -- Changed from UUID to TEXT
  name TEXT NOT NULL UNIQUE,
  description TEXT,

  -- NEW: Separate monthly and annual pricing
  price_monthly DECIMAL(10, 2) NOT NULL DEFAULT 0,
  price_yearly DECIMAL(10, 2) NOT NULL DEFAULT 0,

  -- NEW: Tier level for ordering (1=Free, 2=Gold, 3=Platinum, 4=Black)
  tier_level INTEGER NOT NULL CHECK (tier_level BETWEEN 1 AND 4),

  -- NEW: Rich features as JSONB
  features JSONB NOT NULL DEFAULT '{}',

  -- NEW: Benefits array
  benefits TEXT[] DEFAULT '{}',

  -- Metadata
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(tier_level)
);

-- Indexes for subscription_plans
CREATE INDEX idx_subscription_plans_tier_level ON subscription_plans(tier_level);
CREATE INDEX idx_subscription_plans_active ON subscription_plans(is_active);

-- =====================================================
-- 3. USER SUBSCRIPTIONS TABLE (UPDATED)
-- =====================================================
-- Tracks user's current subscription

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan_id TEXT NOT NULL REFERENCES subscription_plans(id),  -- Changed from UUID to TEXT

  tier TEXT NOT NULL CHECK (tier IN ('Free', 'Gold', 'Platinum', 'Black')),
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired', 'trial')) DEFAULT 'active',

  -- NEW: Billing cycle
  billing_cycle TEXT NOT NULL CHECK (billing_cycle IN ('monthly', 'annual', 'lifetime')) DEFAULT 'lifetime',

  -- Subscription period
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,

  -- Auto-renewal
  auto_renew BOOLEAN DEFAULT true,

  -- Payment details
  payment_method TEXT,
  payment_reference TEXT,
  amount_paid DECIMAL(10, 2),
  currency TEXT DEFAULT 'GHS',

  -- NEW: Reward points
  reward_points INTEGER DEFAULT 0,

  -- NEW: Referral code (unique per user)
  referral_code TEXT UNIQUE,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for user_subscriptions
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_plan_id ON user_subscriptions(plan_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX idx_user_subscriptions_referral_code ON user_subscriptions(referral_code);
CREATE INDEX idx_user_subscriptions_end_date ON user_subscriptions(end_date);

-- Partial unique index to ensure only one active subscription per user
CREATE UNIQUE INDEX idx_user_subscriptions_user_active
  ON user_subscriptions(user_id)
  WHERE status = 'active';

-- =====================================================
-- 4. POINT REDEMPTIONS TABLE (NEW)
-- =====================================================
-- Tracks point redemptions

CREATE TABLE IF NOT EXISTS point_redemptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  points_spent INTEGER NOT NULL CHECK (points_spent > 0),
  reward_type TEXT NOT NULL,  -- 'discount', 'free_event', 'upgrade', etc.
  reward_value DECIMAL(10, 2) NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'redeemed', 'expired', 'cancelled')) DEFAULT 'pending',

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  redeemed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for point_redemptions
CREATE INDEX idx_point_redemptions_user_id ON point_redemptions(user_id);
CREATE INDEX idx_point_redemptions_status ON point_redemptions(status);
CREATE INDEX idx_point_redemptions_created_at ON point_redemptions(created_at DESC);

-- =====================================================
-- 5. REFERRALS TABLE (NEW)
-- =====================================================
-- Tracks referral relationships

CREATE TABLE IF NOT EXISTS referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  referred_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  referral_code TEXT NOT NULL,

  -- Subscription details when referral completed
  subscription_plan_id TEXT REFERENCES subscription_plans(id),
  tier TEXT,

  -- Status
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'expired')) DEFAULT 'pending',

  -- Rewards
  points_awarded INTEGER DEFAULT 0,
  bonus_applied BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,

  -- Constraints
  CONSTRAINT referrals_no_self_referral CHECK (referrer_user_id != referred_user_id)
);

-- Indexes for referrals
CREATE INDEX idx_referrals_referrer_user_id ON referrals(referrer_user_id);
CREATE INDEX idx_referrals_referred_user_id ON referrals(referred_user_id);
CREATE INDEX idx_referrals_code ON referrals(referral_code);
CREATE INDEX idx_referrals_status ON referrals(status);

-- =====================================================
-- 6. EVENTS TABLE
-- =====================================================
-- Stores all events

CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,

  -- Event details
  category TEXT,
  tags TEXT[],

  -- Dates
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,

  -- Location
  location TEXT NOT NULL,
  venue_id UUID,  -- Link to clubs/venues (if applicable)
  address TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Media
  cover_image TEXT,
  images TEXT[],
  video_url TEXT,

  -- Pricing
  price DECIMAL(10, 2) DEFAULT 0,
  currency TEXT DEFAULT 'GHS',

  -- Capacity
  total_capacity INTEGER,
  available_capacity INTEGER,

  -- Features
  is_featured BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,

  -- Organizer
  organizer_id UUID REFERENCES profiles(id),
  organizer_name TEXT,
  organizer_contact TEXT,

  -- Metadata
  metadata JSONB DEFAULT '{}',

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Constraints
  CONSTRAINT events_valid_dates CHECK (end_date > start_date),
  CONSTRAINT events_valid_capacity CHECK (available_capacity >= 0 AND available_capacity <= total_capacity)
);

-- Indexes for events
CREATE INDEX idx_events_start_date ON events(start_date);
CREATE INDEX idx_events_end_date ON events(end_date);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_is_featured ON events(is_featured);
CREATE INDEX idx_events_venue_id ON events(venue_id);
CREATE INDEX idx_events_is_active ON events(is_active);
-- Note: Composite index for active events (removed NOW() predicate due to immutability constraint)
CREATE INDEX idx_events_active_start_date ON events(is_active, start_date) WHERE is_active = true;

-- =====================================================
-- 7. BOOKINGS TABLE
-- =====================================================
-- Stores event bookings

CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

  -- Booking details
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  zone TEXT,
  seat_numbers TEXT[],

  -- Pricing
  unit_price DECIMAL(10, 2) NOT NULL,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  total_price DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'GHS',

  -- Payment
  payment_status TEXT NOT NULL CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')) DEFAULT 'pending',
  payment_method TEXT,
  payment_reference TEXT,

  -- Booking status
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'attended')) DEFAULT 'pending',

  -- QR Code for ticket
  qr_code TEXT,

  -- Points awarded
  points_awarded INTEGER DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  cancelled_at TIMESTAMP WITH TIME ZONE,
  attended_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for bookings
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_event_id ON bookings(event_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at DESC);

-- =====================================================
-- 8. CLUBS TABLE
-- =====================================================
-- Stores club/venue information

CREATE TABLE IF NOT EXISTS clubs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,

  -- Media
  logo_url TEXT,
  cover_image_url TEXT,
  images TEXT[],

  -- Location
  address TEXT NOT NULL,
  city TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Contact
  phone TEXT,
  email TEXT,
  website_url TEXT,

  -- Operating hours
  operating_hours JSONB,

  -- Features
  has_vip_section BOOLEAN DEFAULT false,
  has_restaurant BOOLEAN DEFAULT false,
  has_parking BOOLEAN DEFAULT false,

  -- Ratings
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,

  -- Price range (1-4, $ to $$$$)
  price_range INTEGER CHECK (price_range BETWEEN 1 AND 4),

  -- Status
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for clubs
CREATE INDEX idx_clubs_city ON clubs(city);
CREATE INDEX idx_clubs_is_featured ON clubs(is_featured);
CREATE INDEX idx_clubs_is_active ON clubs(is_active);
CREATE INDEX idx_clubs_average_rating ON clubs(average_rating DESC);

-- =====================================================
-- 9. LOUNGES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS lounges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  website_url TEXT,
  operating_hours JSONB,
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,
  price_range INTEGER CHECK (price_range BETWEEN 1 AND 4),
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_lounges_is_featured ON lounges(is_featured);
CREATE INDEX idx_lounges_is_active ON lounges(is_active);

-- =====================================================
-- 10. PUBS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS pubs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  website_url TEXT,
  operating_hours JSONB,
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,
  price_range INTEGER CHECK (price_range BETWEEN 1 AND 4),
  has_sports_viewing BOOLEAN DEFAULT true,
  has_live_music BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_pubs_is_featured ON pubs(is_featured);
CREATE INDEX idx_pubs_is_active ON pubs(is_active);
CREATE INDEX idx_pubs_has_sports_viewing ON pubs(has_sports_viewing);

-- =====================================================
-- 11. ARCADE CENTERS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS arcade_centers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  website_url TEXT,
  operating_hours JSONB,
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,
  entry_fee DECIMAL(10, 2) DEFAULT 0,
  has_vr_games BOOLEAN DEFAULT false,
  has_console_games BOOLEAN DEFAULT true,
  has_arcade_machines BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_arcade_centers_is_featured ON arcade_centers(is_featured);
CREATE INDEX idx_arcade_centers_is_active ON arcade_centers(is_active);
CREATE INDEX idx_arcade_centers_has_vr ON arcade_centers(has_vr_games);

-- =====================================================
-- 12. BEACHES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS beaches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  website_url TEXT,
  operating_hours JSONB,
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,
  entry_fee DECIMAL(10, 2) DEFAULT 0,
  has_facilities BOOLEAN DEFAULT true,
  has_water_sports BOOLEAN DEFAULT false,
  has_restaurant BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_beaches_is_featured ON beaches(is_featured);
CREATE INDEX idx_beaches_is_active ON beaches(is_active);
CREATE INDEX idx_beaches_has_water_sports ON beaches(has_water_sports);

-- =====================================================
-- 13. LIVE SHOWS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS live_shows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  venue_name TEXT NOT NULL,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  website_url TEXT,
  show_date DATE,
  show_time TIME,
  ticket_price DECIMAL(10, 2) DEFAULT 0,
  available_tickets INTEGER DEFAULT 0,
  show_type TEXT DEFAULT 'music',
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_live_shows_is_featured ON live_shows(is_featured);
CREATE INDEX idx_live_shows_is_active ON live_shows(is_active);
CREATE INDEX idx_live_shows_show_date ON live_shows(show_date);
CREATE INDEX idx_live_shows_show_type ON live_shows(show_type);

-- =====================================================
-- 14. RESTAURANTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  images TEXT[],

  -- Location
  address TEXT NOT NULL,
  city TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Contact
  phone TEXT,
  email TEXT,
  website_url TEXT,

  -- Details
  cuisine_type TEXT[],
  operating_hours JSONB,
  price_range INTEGER CHECK (price_range BETWEEN 1 AND 4),

  -- Features
  has_delivery BOOLEAN DEFAULT false,
  has_takeaway BOOLEAN DEFAULT true,
  has_reservation BOOLEAN DEFAULT true,

  -- Ratings
  average_rating DECIMAL(3, 2) DEFAULT 0 CHECK (average_rating BETWEEN 0 AND 5),
  total_reviews INTEGER DEFAULT 0,

  -- Status
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_restaurants_city ON restaurants(city);
CREATE INDEX idx_restaurants_is_featured ON restaurants(is_featured);
CREATE INDEX idx_restaurants_is_active ON restaurants(is_active);
CREATE INDEX idx_restaurants_cuisine_type ON restaurants USING GIN(cuisine_type);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Initial schema created successfully!';
  RAISE NOTICE '📊 Tables created: 14';
  RAISE NOTICE '🔄 Next step: Run 01_rls_policies.sql';
END $$;
