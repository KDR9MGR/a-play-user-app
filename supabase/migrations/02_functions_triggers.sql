-- =====================================================
-- A-PLAY STAGING DATABASE - FUNCTIONS & TRIGGERS
-- =====================================================
-- Created: December 16, 2024
-- Purpose: Database functions and triggers for automation
-- Order: Run this file THIRD (after 01_rls_policies.sql)
-- =====================================================

-- =====================================================
-- 1. UPDATED_AT TRIGGER FUNCTION
-- =====================================================
-- Automatically update updated_at timestamp

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON subscription_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON clubs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lounges_updated_at BEFORE UPDATE ON lounges
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pubs_updated_at BEFORE UPDATE ON pubs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_arcade_centers_updated_at BEFORE UPDATE ON arcade_centers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_beaches_updated_at BEFORE UPDATE ON beaches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_live_shows_updated_at BEFORE UPDATE ON live_shows
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurants_updated_at BEFORE UPDATE ON restaurants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 2. HANDLE NEW USER FUNCTION
-- =====================================================
-- Automatically create profile when user signs up

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );

  -- Create free subscription for new user
  INSERT INTO user_subscriptions (
    user_id,
    plan_id,
    tier,
    billing_cycle,
    start_date,
    end_date,
    referral_code
  )
  VALUES (
    NEW.id,
    'free-tier',  -- Free plan ID
    'Free',
    'lifetime',
    NOW(),
    NOW() + INTERVAL '100 years',  -- Essentially lifetime
    'REF' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8))  -- Generate unique code
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- 3. INCREMENT REWARD POINTS FUNCTION
-- =====================================================
-- Add points to user's subscription

CREATE OR REPLACE FUNCTION increment_reward_points(
  user_id_param UUID,
  points_to_add INTEGER
)
RETURNS void AS $$
BEGIN
  UPDATE user_subscriptions
  SET reward_points = reward_points + points_to_add
  WHERE user_id = user_id_param
    AND status = 'active';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No active subscription found for user %', user_id_param;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. AWARD BOOKING POINTS TRIGGER
-- =====================================================
-- Automatically award points when booking is confirmed

CREATE OR REPLACE FUNCTION award_booking_points()
RETURNS TRIGGER AS $$
DECLARE
  points_per_booking INTEGER;
  points_multiplier INTEGER;
BEGIN
  -- Only award points when booking is confirmed and paid
  IF NEW.status = 'confirmed' AND NEW.payment_status = 'paid'
     AND (OLD IS NULL OR OLD.status != 'confirmed' OR OLD.payment_status != 'paid') THEN

    -- Get points configuration from user's subscription plan
    SELECT
      (sp.features->>'points_per_booking')::INTEGER,
      (sp.features->>'points_multiplier')::INTEGER
    INTO points_per_booking, points_multiplier
    FROM user_subscriptions us
    JOIN subscription_plans sp ON sp.id = us.plan_id
    WHERE us.user_id = NEW.user_id
      AND us.status = 'active';

    -- Calculate total points
    IF points_per_booking IS NOT NULL THEN
      PERFORM increment_reward_points(
        NEW.user_id,
        points_per_booking * COALESCE(points_multiplier, 1)
      );

      -- Update booking with points awarded
      UPDATE bookings
      SET points_awarded = points_per_booking * COALESCE(points_multiplier, 1)
      WHERE id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER award_points_on_booking
  AFTER INSERT OR UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION award_booking_points();

-- =====================================================
-- 5. UPDATE EVENT CAPACITY TRIGGER
-- =====================================================
-- Automatically update available capacity when booking created/cancelled

CREATE OR REPLACE FUNCTION update_event_capacity()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.status = 'confirmed') THEN
    -- Decrease available capacity
    UPDATE events
    SET available_capacity = available_capacity - NEW.quantity
    WHERE id = NEW.event_id;

  ELSIF (TG_OP = 'UPDATE') THEN
    -- If booking cancelled, increase capacity
    IF OLD.status != 'cancelled' AND NEW.status = 'cancelled' THEN
      UPDATE events
      SET available_capacity = available_capacity + OLD.quantity
      WHERE id = OLD.event_id;

    -- If booking confirmed from pending, decrease capacity
    ELSIF OLD.status != 'confirmed' AND NEW.status = 'confirmed' THEN
      UPDATE events
      SET available_capacity = available_capacity - NEW.quantity
      WHERE id = NEW.event_id;
    END IF;

  ELSIF (TG_OP = 'DELETE' AND OLD.status = 'confirmed') THEN
    -- Increase capacity if confirmed booking deleted
    UPDATE events
    SET available_capacity = available_capacity + OLD.quantity
    WHERE id = OLD.event_id;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_capacity_on_booking
  AFTER INSERT OR UPDATE OR DELETE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_event_capacity();

-- =====================================================
-- 6. COMPLETE REFERRAL FUNCTION
-- =====================================================
-- Mark referral as completed and award points

CREATE OR REPLACE FUNCTION complete_referral(
  referred_user_id_param UUID,
  subscription_plan_id_param TEXT
)
RETURNS void AS $$
DECLARE
  referral_record RECORD;
  points_to_award INTEGER := 100;  -- Base referral points
BEGIN
  -- Find pending referral
  SELECT * INTO referral_record
  FROM referrals
  WHERE referred_user_id = referred_user_id_param
    AND status = 'pending'
  LIMIT 1;

  IF referral_record IS NOT NULL THEN
    -- Update referral status
    UPDATE referrals
    SET
      status = 'completed',
      subscription_plan_id = subscription_plan_id_param,
      completed_at = NOW(),
      points_awarded = points_to_award,
      bonus_applied = true
    WHERE id = referral_record.id;

    -- Award points to referrer
    PERFORM increment_reward_points(
      referral_record.referrer_user_id,
      points_to_award
    );

    -- Award bonus points to referred user (50 points)
    PERFORM increment_reward_points(
      referred_user_id_param,
      50
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. GET USER TIER FUNCTION
-- =====================================================
-- Get user's current subscription tier

CREATE OR REPLACE FUNCTION get_user_tier(user_id_param UUID)
RETURNS TEXT AS $$
DECLARE
  user_tier TEXT;
BEGIN
  SELECT tier INTO user_tier
  FROM user_subscriptions
  WHERE user_id = user_id_param
    AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1;

  RETURN COALESCE(user_tier, 'Free');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. CALCULATE DISCOUNTED PRICE FUNCTION
-- =====================================================
-- Calculate price with tier discount applied

CREATE OR REPLACE FUNCTION calculate_discounted_price(
  base_price DECIMAL,
  user_id_param UUID
)
RETURNS DECIMAL AS $$
DECLARE
  discount_percentage INTEGER;
  discount_amount DECIMAL;
BEGIN
  -- Get discount from user's subscription
  SELECT (sp.features->>'discount_percentage')::INTEGER
  INTO discount_percentage
  FROM user_subscriptions us
  JOIN subscription_plans sp ON sp.id = us.plan_id
  WHERE us.user_id = user_id_param
    AND us.status = 'active';

  discount_percentage := COALESCE(discount_percentage, 0);
  discount_amount := (base_price * discount_percentage) / 100;

  RETURN base_price - discount_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 9. CHECK EARLY ACCESS FUNCTION
-- =====================================================
-- Check if user has early booking access

CREATE OR REPLACE FUNCTION has_early_access(
  user_id_param UUID,
  event_start_date TIMESTAMP WITH TIME ZONE
)
RETURNS BOOLEAN AS $$
DECLARE
  early_booking_hours INTEGER;
  access_date TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Get early booking hours from subscription
  SELECT (sp.features->>'early_booking_hours')::INTEGER
  INTO early_booking_hours
  FROM user_subscriptions us
  JOIN subscription_plans sp ON sp.id = us.plan_id
  WHERE us.user_id = user_id_param
    AND us.status = 'active';

  early_booking_hours := COALESCE(early_booking_hours, 0);

  -- Calculate early access date
  access_date := event_start_date - (early_booking_hours || ' hours')::INTERVAL;

  RETURN NOW() >= access_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 10. EXPIRE OLD SUBSCRIPTIONS FUNCTION
-- =====================================================
-- Cron job to expire subscriptions

CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE user_subscriptions
  SET
    status = 'expired',
    auto_renew = false
  WHERE status = 'active'
    AND end_date < NOW()
    AND billing_cycle != 'lifetime';

  -- Update profile tier for expired subscriptions
  UPDATE profiles p
  SET current_tier = 'Free'
  FROM user_subscriptions us
  WHERE p.id = us.user_id
    AND us.status = 'expired'
    AND p.current_tier != 'Free';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 11. SYNC PROFILE TIER FUNCTION
-- =====================================================
-- Keep profile.current_tier in sync with subscription

CREATE OR REPLACE FUNCTION sync_profile_tier()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.status = 'active' THEN
    UPDATE profiles
    SET current_tier = NEW.tier
    WHERE id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER sync_tier_on_subscription_change
  AFTER INSERT OR UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION sync_profile_tier();

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Functions and triggers created successfully!';
  RAISE NOTICE '⚙️  Auto-update timestamps enabled';
  RAISE NOTICE '🎁 Points system configured';
  RAISE NOTICE '👥 Referral system ready';
  RAISE NOTICE '🔄 Next step: Run 03_seed_data.sql';
END $$;
