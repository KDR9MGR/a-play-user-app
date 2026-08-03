-- =====================================================
-- CREATE DEMO ACCOUNT FOR APPLE APP STORE REVIEW
-- =====================================================
-- Purpose: Create valid demo account with full access
-- Credentials: applereview@aplayworld.com / AppleReview2026!
-- =====================================================

-- STEP 1: CREATE USER IN SUPABASE AUTH DASHBOARD
-- =====================================================
-- You MUST do this manually in Supabase Dashboard:
-- 1. Go to: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/auth/users
-- 2. Click "Add User"
-- 3. Email: applereview@aplayworld.com
-- 4. Password: AppleReview2026!
-- 5. Auto-confirm user: YES (CHECK THIS BOX!)
-- 6. Click "Create User"
-- 7. COPY THE USER ID (UUID) - you'll need it for Step 2
-- =====================================================

-- STEP 2: RUN THIS SQL AFTER CREATING AUTH USER
-- =====================================================
-- Replace 'USER_ID_FROM_STEP_1' with the actual UUID from Supabase Dashboard

DO $$
DECLARE
  v_user_id UUID := 'USER_ID_FROM_STEP_1';  -- ← REPLACE THIS WITH ACTUAL UUID
  v_email TEXT := 'applereview@aplayworld.com';
BEGIN
  RAISE NOTICE '==========================================';
  RAISE NOTICE 'Creating Demo Account for Apple Review';
  RAISE NOTICE 'Email: %', v_email;
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE '==========================================';

  -- Create/update profile
  INSERT INTO profiles (
    id,
    email,
    full_name,
    tier,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_email,
    'Apple Review Demo',
    'Platinum',  -- Set to Platinum for full access
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email,
      full_name = EXCLUDED.full_name,
      tier = 'Platinum',
      updated_at = NOW();

  RAISE NOTICE '✓ Profile created/updated';

  -- Create Platinum subscription (1 year validity)
  INSERT INTO user_subscriptions (
    user_id,
    plan_id,
    tier,
    status,
    billing_cycle,
    start_date,
    end_date,
    platform,
    sandbox,
    auto_renew_enabled,
    product_id,
    reward_points,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    'platinum-yearly',
    'Platinum',
    'active',
    'yearly',
    NOW(),
    NOW() + INTERVAL '1 year',
    'app_store',
    true,  -- Mark as sandbox for demo
    true,
    'com.aplay.subscription.platinum.yearly',
    500,  -- Give some reward points
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id, plan_id) DO UPDATE
  SET status = 'active',
      end_date = NOW() + INTERVAL '1 year',
      tier = 'Platinum',
      sandbox = true,
      auto_renew_enabled = true,
      updated_at = NOW();

  RAISE NOTICE '✓ Platinum subscription created (valid for 1 year)';

  -- Give concierge request quota for current month
  INSERT INTO concierge_request_tracking (
    user_id,
    month,
    year,
    request_count,
    created_at
  ) VALUES (
    v_user_id,
    EXTRACT(MONTH FROM NOW())::INTEGER,
    EXTRACT(YEAR FROM NOW())::INTEGER,
    0,  -- Start with 0 requests used
    NOW()
  )
  ON CONFLICT (user_id, month, year) DO NOTHING;

  RAISE NOTICE '✓ Concierge access granted';

  -- Optional: Add sample booking (so reviewers can see booking history)
  -- Uncomment if you want to add a sample booking
  /*
  INSERT INTO bookings (
    user_id,
    event_id,
    quantity,
    zone,
    total_amount,
    payment_status,
    payment_reference,
    status,
    booking_date,
    created_at
  ) VALUES (
    v_user_id,
    (SELECT id FROM events LIMIT 1),  -- Use first available event
    2,
    'VIP',
    100.00,
    'paid',
    'DEMO_PAYMENT_REF_001',
    'confirmed',
    NOW(),
    NOW()
  );
  RAISE NOTICE '✓ Sample booking added';
  */

  RAISE NOTICE '==========================================';
  RAISE NOTICE 'DEMO ACCOUNT SETUP COMPLETE!';
  RAISE NOTICE '';
  RAISE NOTICE 'Credentials for App Store Connect:';
  RAISE NOTICE '  Email: %', v_email;
  RAISE NOTICE '  Password: AppleReview2026!';
  RAISE NOTICE '';
  RAISE NOTICE 'Account Features:';
  RAISE NOTICE '  - Platinum subscription (active for 1 year)';
  RAISE NOTICE '  - Full access to concierge features';
  RAISE NOTICE '  - 500 reward points';
  RAISE NOTICE '  - Email verified';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '1. Test login in app with these credentials';
  RAISE NOTICE '2. Update App Store Connect → Demo Account';
  RAISE NOTICE '3. Add to Review Notes: "Premium account with full access"';
  RAISE NOTICE '==========================================';
END $$;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify the demo account is set up correctly

-- Check profile
SELECT
  id,
  email,
  full_name,
  tier,
  created_at
FROM profiles
WHERE email = 'applereview@aplayworld.com';

-- Check subscription
SELECT
  user_id,
  plan_id,
  tier,
  status,
  start_date,
  end_date,
  platform,
  sandbox
FROM user_subscriptions
WHERE user_id IN (
  SELECT id FROM profiles WHERE email = 'applereview@aplayworld.com'
);

-- Check concierge access
SELECT
  user_id,
  month,
  year,
  request_count
FROM concierge_request_tracking
WHERE user_id IN (
  SELECT id FROM profiles WHERE email = 'applereview@aplayworld.com'
);

-- =====================================================
-- TROUBLESHOOTING
-- =====================================================

-- If you need to reset the password:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Find applereview@aplayworld.com
-- 3. Click the user → "Send Password Recovery"
-- OR set password manually in dashboard

-- If you need to delete and recreate:
-- DELETE FROM user_subscriptions WHERE user_id IN (SELECT id FROM profiles WHERE email = 'applereview@aplayworld.com');
-- DELETE FROM profiles WHERE email = 'applereview@aplayworld.com';
-- Then delete user from Supabase Auth Dashboard
-- Then start over from Step 1
