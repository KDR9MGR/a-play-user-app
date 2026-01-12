-- =====================================================
-- A-PLAY STAGING DATABASE - ROW LEVEL SECURITY POLICIES
-- =====================================================
-- Created: December 16, 2024
-- Purpose: RLS policies for secure data access
-- Order: Run this file SECOND (after 00_initial_schema.sql)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lounges ENABLE ROW LEVEL SECURITY;
ALTER TABLE pubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE arcade_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE beaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_shows ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROFILES POLICIES
-- =====================================================

-- Users can view all profiles (for social features)
CREATE POLICY "profiles_select_all"
  ON profiles FOR SELECT
  USING (true);

-- Users can insert their own profile
CREATE POLICY "profiles_insert_own"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users cannot delete profiles (handle via auth)
-- No DELETE policy needed

-- =====================================================
-- SUBSCRIPTION PLANS POLICIES
-- =====================================================

-- Everyone can view active subscription plans
CREATE POLICY "subscription_plans_select_active"
  ON subscription_plans FOR SELECT
  USING (is_active = true);

-- Only service role can modify plans (admin only)
-- No INSERT/UPDATE/DELETE policies for users

-- =====================================================
-- USER SUBSCRIPTIONS POLICIES
-- =====================================================

-- Users can view their own subscriptions
CREATE POLICY "user_subscriptions_select_own"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can insert subscriptions (payment processing)
-- Users cannot directly insert (handled by backend)
CREATE POLICY "user_subscriptions_insert_service"
  ON user_subscriptions FOR INSERT
  WITH CHECK (false);  -- Only service role can insert

-- Users can update their own subscription (cancel, etc.)
CREATE POLICY "user_subscriptions_update_own"
  ON user_subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- POINT REDEMPTIONS POLICIES
-- =====================================================

-- Users can view their own point redemptions
CREATE POLICY "point_redemptions_select_own"
  ON point_redemptions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create redemptions (subject to business logic)
CREATE POLICY "point_redemptions_insert_own"
  ON point_redemptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can cancel pending redemptions
CREATE POLICY "point_redemptions_update_own"
  ON point_redemptions FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending')
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- REFERRALS POLICIES
-- =====================================================

-- Users can view referrals they made
CREATE POLICY "referrals_select_referrer"
  ON referrals FOR SELECT
  USING (auth.uid() = referrer_user_id);

-- Users can view referrals where they were referred
CREATE POLICY "referrals_select_referred"
  ON referrals FOR SELECT
  USING (auth.uid() = referred_user_id);

-- System creates referrals (not users directly)
CREATE POLICY "referrals_insert_service"
  ON referrals FOR INSERT
  WITH CHECK (false);  -- Only service role can insert

-- =====================================================
-- EVENTS POLICIES
-- =====================================================

-- Everyone can view active events
CREATE POLICY "events_select_active"
  ON events FOR SELECT
  USING (is_active = true);

-- Organizers can view their own events (including inactive)
CREATE POLICY "events_select_own"
  ON events FOR SELECT
  USING (auth.uid() = organizer_id);

-- Only admins/organizers can create events
-- Handled via service role

-- Organizers can update their own events
CREATE POLICY "events_update_own"
  ON events FOR UPDATE
  USING (auth.uid() = organizer_id)
  WITH CHECK (auth.uid() = organizer_id);

-- =====================================================
-- BOOKINGS POLICIES
-- =====================================================

-- Users can view their own bookings
CREATE POLICY "bookings_select_own"
  ON bookings FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create bookings
CREATE POLICY "bookings_insert_own"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own bookings (cancel, etc.)
CREATE POLICY "bookings_update_own"
  ON bookings FOR UPDATE
  USING (auth.uid() = user_id AND status != 'attended')
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- CLUBS POLICIES
-- =====================================================

-- Everyone can view active clubs
CREATE POLICY "clubs_select_active"
  ON clubs FOR SELECT
  USING (is_active = true);

-- =====================================================
-- LOUNGES POLICIES
-- =====================================================

-- Everyone can view active lounges
CREATE POLICY "lounges_select_active"
  ON lounges FOR SELECT
  USING (is_active = true);

-- =====================================================
-- PUBS POLICIES
-- =====================================================

-- Everyone can view active pubs
CREATE POLICY "pubs_select_active"
  ON pubs FOR SELECT
  USING (is_active = true);

-- =====================================================
-- ARCADE CENTERS POLICIES
-- =====================================================

-- Everyone can view active arcade centers
CREATE POLICY "arcade_centers_select_active"
  ON arcade_centers FOR SELECT
  USING (is_active = true);

-- =====================================================
-- BEACHES POLICIES
-- =====================================================

-- Everyone can view active beaches
CREATE POLICY "beaches_select_active"
  ON beaches FOR SELECT
  USING (is_active = true);

-- =====================================================
-- LIVE SHOWS POLICIES
-- =====================================================

-- Everyone can view active live shows
CREATE POLICY "live_shows_select_active"
  ON live_shows FOR SELECT
  USING (is_active = true);

-- =====================================================
-- RESTAURANTS POLICIES
-- =====================================================

-- Everyone can view active restaurants
CREATE POLICY "restaurants_select_active"
  ON restaurants FOR SELECT
  USING (is_active = true);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ RLS policies created successfully!';
  RAISE NOTICE '🔒 All tables now have row-level security enabled';
  RAISE NOTICE '🔄 Next step: Run 02_functions_triggers.sql';
END $$;
