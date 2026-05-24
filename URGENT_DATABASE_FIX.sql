-- =====================================================
-- URGENT DATABASE FIX - RUN THIS IN SUPABASE SQL EDITOR
-- =====================================================
-- Fixes:
-- 1. Plan IDs: Change dashes to underscores
-- 2. Free tier: Set duration to 3 days
-- =====================================================

-- Step 1: Fix plan IDs to match app code
UPDATE subscription_plans SET id = 'weekly_plan' WHERE id = 'weekly-premium';
UPDATE subscription_plans SET id = 'monthly_plan' WHERE id = 'monthly-premium';
UPDATE subscription_plans SET id = 'quarterly_plan' WHERE id = 'quarterly-premium';
UPDATE subscription_plans SET id = 'annual_plan' WHERE id = 'annual-premium';

-- Step 2: Update free tier duration to 3 days and name to "Free Trial"
UPDATE subscription_plans
SET duration_days = 3,
    name = 'Free Trial'
WHERE id = 'free-tier';

-- Step 3: Verify all changes
SELECT
    id,
    name,
    price_monthly,
    duration_days,
    tier_level
FROM subscription_plans
ORDER BY duration_days;

-- Expected output:
-- id             | name              | price_monthly | duration_days | tier_level
-- ---------------|-------------------|---------------|---------------|------------
-- free-tier      | Free Trial        | 0.00          | 3             | 1
-- weekly_plan    | 1 Week Premium    | 50.00         | 7             | 2
-- monthly_plan   | 1 Month Premium   | 190.00        | 30            | 2
-- quarterly_plan | 3 Months Premium  | 550.00        | 90            | 3
-- annual_plan    | 1 Year Premium    | 2200.00       | 365           | 3
