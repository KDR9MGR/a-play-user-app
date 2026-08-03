-- Populate subscription_plans table with proper pricing
-- This fixes the Apple App Store review issue where prices showed as GHS 0.00

-- First, delete any existing plans to avoid conflicts
DELETE FROM subscription_plans;

-- Insert properly configured subscription plans
INSERT INTO subscription_plans (
  id,
  name,
  description,
  duration_days,
  price,
  price_monthly,
  currency,
  plan_type,
  tier_points_bonus,
  benefits,
  tier_level,
  is_active,
  is_popular,
  created_at,
  updated_at
) VALUES
  -- 1 Week Premium
  (
    'weekly_plan',
    '1 Week Premium',
    'Perfect for trying out premium features',
    7,
    50.00,
    50.00,
    'GHS',
    'weekly',
    50,
    ARRAY['10% discount on all bookings', '24-hour early booking', '1 free table reservation'],
    1,
    true,
    false,
    NOW(),
    NOW()
  ),
  -- 1 Month Premium (Most Popular)
  (
    'monthly_plan',
    '1 Month Premium',
    'Most popular choice for regular users',
    30,
    190.00,
    190.00,
    'GHS',
    'monthly',
    200,
    ARRAY['10% discount on all bookings', '48-hour early booking', '3 free table reservations/month'],
    2,
    true,
    true,
    NOW(),
    NOW()
  ),
  -- 3 Months Premium
  (
    'quarterly_plan',
    '3 Months Premium',
    'Save more with our quarterly plan',
    90,
    550.00,
    183.33,
    'GHS',
    'quarterly',
    650,
    ARRAY['15% discount on all bookings', '72-hour early booking', 'Unlimited table reservations'],
    3,
    true,
    false,
    NOW(),
    NOW()
  ),
  -- 1 Year Premium
  (
    'annual_plan',
    '1 Year Premium',
    'Ultimate experience with maximum savings',
    365,
    2200.00,
    183.33,
    'GHS',
    'annual',
    3000,
    ARRAY['20% discount on all bookings', '1-week early booking access', 'VIP lounge access nationwide'],
    4,
    true,
    false,
    NOW(),
    NOW()
  );

-- Verify the data was inserted
SELECT
  id,
  name,
  price,
  currency,
  duration_days,
  is_popular,
  benefits
FROM subscription_plans
ORDER BY duration_days;
