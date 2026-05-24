-- =====================================================
-- UPDATE SUBSCRIPTION PRICING
-- =====================================================
-- Created: April 13, 2026
-- Purpose: Update subscription plans to new pricing structure
-- Pricing: 1 week = 50 GHS, 1 month = 190 GHS, 3 months = 550 GHS, 1 year = 2200 GHS
-- =====================================================

-- First, add duration_days column if it doesn't exist
ALTER TABLE subscription_plans
ADD COLUMN IF NOT EXISTS duration_days INTEGER;

-- Clear existing plans (except Free tier)
DELETE FROM subscription_plans WHERE id != 'free-tier';

-- Insert Free tier if it doesn't exist
INSERT INTO subscription_plans (id, name, description, price_monthly, price_yearly, duration_days, tier_level, features, benefits) VALUES
('free-tier', 'Free Trial', 'Basic access to all events', 0.00, 0.00, 3, 1,
'{
  "tier": "Free",
  "color": "#9E9E9E",
  "points_multiplier": 1,
  "discount_percentage": 0,
  "early_booking_hours": 0,
  "concierge_access": false,
  "concierge_hours": "none",
  "vip_entry": false,
  "priority_support": false,
  "free_reservations_per_month": 0,
  "vip_lounge_access": false,
  "points_per_booking": 10,
  "points_per_review": 5,
  "referral_limit": 5,
  "support_response_hours": 48,
  "badge_type": "basic"
}'::jsonb,
ARRAY['Browse all events', 'Basic booking', 'Standard support', 'View public reviews']
)
ON CONFLICT (id) DO NOTHING;

-- Insert new duration-based subscription plans
INSERT INTO subscription_plans (id, name, description, price_monthly, price_yearly, duration_days, tier_level, features, benefits) VALUES

-- 1 WEEK PLAN (50 GHS)
('weekly_plan', '1 Week Premium', 'Perfect for trying out premium features', 50.00, 0.00, 7, 2,
'{
  "tier": "Gold",
  "color": "#FFD700",
  "points_multiplier": 2,
  "discount_percentage": 10,
  "early_booking_hours": 24,
  "concierge_access": true,
  "concierge_hours": "business_hours",
  "vip_entry": false,
  "priority_support": true,
  "free_reservations_per_month": 1,
  "vip_lounge_access": true,
  "points_per_booking": 20,
  "points_per_review": 10,
  "referral_limit": 10,
  "support_response_hours": 24,
  "badge_type": "gold"
}'::jsonb,
ARRAY['10% discount on all bookings', '24-hour early booking', '1 free table reservation', 'VIP lounge access', 'Priority support', '2x reward points']
),

-- 1 MONTH PLAN (190 GHS)
('monthly_plan', '1 Month Premium', 'Most popular choice for regular users', 190.00, 0.00, 30, 2,
'{
  "tier": "Gold",
  "color": "#FFD700",
  "points_multiplier": 2,
  "discount_percentage": 10,
  "early_booking_hours": 48,
  "concierge_access": true,
  "concierge_hours": "business_hours",
  "vip_entry": false,
  "priority_support": true,
  "free_reservations_per_month": 3,
  "vip_lounge_access": true,
  "event_upgrades_per_month": 1,
  "concierge_requests_per_month": 3,
  "points_per_booking": 20,
  "points_per_review": 10,
  "referral_limit": 10,
  "support_response_hours": 12,
  "badge_type": "gold"
}'::jsonb,
ARRAY['10% discount on all bookings', '48-hour early booking', '3 free table reservations/month', 'VIP lounge access', 'Priority support', '2x reward points']
),

-- 3 MONTHS PLAN (550 GHS)
('quarterly_plan', '3 Months Premium', 'Save more with our quarterly plan', 550.00, 0.00, 90, 3,
'{
  "tier": "Platinum",
  "color": "#E5E4E2",
  "points_multiplier": 3,
  "discount_percentage": 15,
  "early_booking_hours": 72,
  "concierge_access": true,
  "concierge_hours": "24/7",
  "vip_entry": true,
  "priority_support": true,
  "free_reservations_per_month": 999,
  "vip_lounge_access": true,
  "all_access_vip_lounge": true,
  "event_upgrades_per_month": 999,
  "concierge_requests_per_month": 999,
  "meet_greet_per_year": 1,
  "backstage_access_per_year": 1,
  "free_parking": true,
  "personal_coordinator": true,
  "points_per_booking": 30,
  "points_per_review": 15,
  "referral_limit": 999,
  "support_response_hours": 6,
  "badge_type": "platinum"
}'::jsonb,
ARRAY['15% discount on all bookings', '72-hour early access', 'Unlimited table reservations', 'All-access VIP lounge', 'Personal event coordinator', 'Free parking', 'Backstage access', '3x reward points']
),

-- 1 YEAR PLAN (2200 GHS)
('annual_plan', '1 Year Premium', 'Ultimate experience with maximum savings', 2200.00, 2200.00, 365, 3,
'{
  "tier": "Platinum",
  "color": "#E5E4E2",
  "points_multiplier": 3,
  "discount_percentage": 15,
  "early_booking_hours": 72,
  "concierge_access": true,
  "concierge_hours": "24/7",
  "vip_entry": true,
  "priority_support": true,
  "free_reservations_per_month": 999,
  "vip_lounge_access": true,
  "all_access_vip_lounge": true,
  "event_upgrades_per_month": 999,
  "concierge_requests_per_month": 999,
  "meet_greet_per_year": 2,
  "backstage_access_per_year": 2,
  "free_parking": true,
  "personal_coordinator": true,
  "quarterly_gifts": true,
  "points_per_booking": 30,
  "points_per_review": 15,
  "referral_limit": 999,
  "support_response_hours": 2,
  "badge_type": "platinum",
  "animated_badge": true
}'::jsonb,
ARRAY['15% discount on all bookings', '72-hour early access', 'Unlimited table reservations', 'All-access VIP lounge', 'Personal event coordinator', 'Free parking', 'Backstage access', 'Quarterly luxury gifts', '3x reward points', 'Best value - Save 40% vs monthly']
)

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  price_monthly = EXCLUDED.price_monthly,
  price_yearly = EXCLUDED.price_yearly,
  duration_days = EXCLUDED.duration_days,
  tier_level = EXCLUDED.tier_level,
  features = EXCLUDED.features,
  benefits = EXCLUDED.benefits,
  updated_at = NOW();

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Subscription pricing updated successfully!';
  RAISE NOTICE '💰 New pricing:';
  RAISE NOTICE '  - 1 Week: GHS 50';
  RAISE NOTICE '  - 1 Month: GHS 190';
  RAISE NOTICE '  - 3 Months: GHS 550';
  RAISE NOTICE '  - 1 Year: GHS 2200';
END $$;
