# Subscription Debug Guide

## Critical Issues to Check

### 1. Database Migration Status

**Check if migration was applied:**

```sql
-- Run this in Supabase SQL Editor
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('is_subscribed', 'subscription_tier', 'subscription_expires_at');
```

**Expected Result:** Should return 3 rows showing these columns exist.

**If columns don't exist:**
```bash
# Apply the migration
supabase db push
```

### 2. Check Current User Authentication

**Console Check:**
Look for this error in console logs:
```
IAPVerification: User not authenticated
```

**If you see this:** User is not logged in. Log in first before testing subscriptions.

### 3. Check Row Level Security (RLS) Policies

The verification might fail if RLS policies block the insert/update.

**Test RLS:**
```sql
-- Check if you can insert into user_subscriptions
INSERT INTO user_subscriptions (
  user_id,
  plan_id,
  plan_type,
  status,
  start_date,
  end_date,
  payment_method
) VALUES (
  auth.uid(),
  'weekly_plan',
  'weekly',
  'active',
  NOW(),
  NOW() + INTERVAL '7 days',
  'apple_iap'
);
```

**If this fails with permission error:**
```sql
-- Add RLS policy to allow inserts
CREATE POLICY "Users can insert their own subscriptions"
ON user_subscriptions
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Add RLS policy to allow users to read their own subscriptions
CREATE POLICY "Users can read their own subscriptions"
ON user_subscriptions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

### 4. Check profiles table update permissions

```sql
-- Add RLS policy for profile updates
CREATE POLICY "Users can update their own subscription status"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

### 5. Enable Detailed Console Logging

When running the app, watch for these specific log messages:

#### App Startup Logs
```
✅ SUCCESS INDICATORS:
IAPService: Initializing...
IAPService: Checking for existing subscriptions...
IAPService: ↻ Purchase RESTORED
IAPService: Product: 7day
IAPService: Auto-syncing restored purchase to database...
SubscriptionSync: ✓ Subscription synced successfully

❌ FAILURE INDICATORS:
IAPService: ✗ Failed to sync restored purchase: [ERROR]
SubscriptionSync: ✗ Sync failed: [ERROR]
```

#### Subscription Screen Logs
```
✅ SUCCESS (Existing Sub Detected):
SubscriptionScreen: Checking for existing subscriptions...
SubscriptionScreen: ✓ User already has active subscription

❌ FAILURE (Not Detecting Existing Sub):
SubscriptionScreen: Checking for existing subscriptions...
SubscriptionScreen: No active subscription found
```

#### Purchase Logs
```
✅ SUCCESS:
IAPService: ✓ Purchase SUCCESSFUL!
IAPService: Product: 7day
SubscriptionScreen: Purchase successful: 7day
IAPVerification: Creating subscription record...
IAPVerification: ✓ Subscription activated successfully

❌ FAILURE:
IAPVerification: ✗ Verification failed: [ERROR]
```

### 6. Common Errors and Fixes

#### Error: "new row violates row-level security policy"
**Fix:** Add RLS policies (see #3 above)

#### Error: "column 'is_subscribed' does not exist"
**Fix:** Run migration: `supabase db push`

#### Error: "User not authenticated"
**Fix:** Ensure user is logged in before opening subscription screen

#### Error: "Failed to sync restored purchase: null value in column 'id'"
**Fix:** Check if `user_subscriptions` table has `id` column set as primary key with auto-increment

### 7. Manual Verification Steps

#### Step 1: Check StoreKit Subscription
1. Open Xcode
2. Go to Debug > StoreKit > Manage Transactions
3. Verify you see active subscription there

#### Step 2: Check Supabase Database
```sql
-- Check if user has subscription in database
SELECT * FROM user_subscriptions
WHERE user_id = auth.uid()
AND status = 'active';

-- Check user profile
SELECT id, email, is_subscribed, subscription_tier, subscription_expires_at
FROM profiles
WHERE id = auth.uid();
```

#### Step 3: Test Purchase Flow (New User)
1. Create fresh test account
2. Open subscription screen
3. Should see product cards
4. Tap "Subscribe Now"
5. Watch console for errors

#### Step 4: Test Existing Subscription Detection
1. Use account with StoreKit subscription
2. Quit app completely
3. Relaunch app
4. Check console for "Purchase RESTORED" message
5. Open subscription screen
6. Should see "Already Subscribed" view

### 8. Database Schema Validation

Run this to ensure your schema is correct:

```sql
-- Validate user_subscriptions table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_subscriptions'
ORDER BY ordinal_position;

-- Expected columns:
-- id (uuid, not null, primary key)
-- user_id (uuid, not null)
-- plan_id (text, not null)
-- plan_type (text)
-- status (text, not null)
-- start_date (timestamp with time zone)
-- end_date (timestamp with time zone)
-- payment_method (text)
-- tier_points_earned (integer)
-- created_at (timestamp with time zone)
-- updated_at (timestamp with time zone)
```

### 9. Trigger Validation

Check if the trigger is working:

```sql
-- Check if trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'trigger_update_profile_subscription';

-- Expected: Should return one row
```

### 10. Test Trigger Manually

```sql
-- Insert test subscription
INSERT INTO user_subscriptions (
  user_id, plan_id, plan_type, status, start_date, end_date, payment_method, tier_points_earned
) VALUES (
  auth.uid(), 'weekly_plan', 'weekly', 'active',
  NOW(), NOW() + INTERVAL '7 days', 'apple_iap', 50
);

-- Check if profile was updated
SELECT is_subscribed, subscription_tier, subscription_expires_at
FROM profiles
WHERE id = auth.uid();

-- Expected: is_subscribed = true, subscription_tier = 'Gold'
```

## Quick Diagnostic Checklist

Run through this checklist and provide me the results:

- [ ] Migration applied (columns exist in profiles table)
- [ ] User is authenticated (console shows user ID)
- [ ] RLS policies exist for user_subscriptions
- [ ] RLS policies exist for profiles updates
- [ ] Trigger exists and is enabled
- [ ] StoreKit shows active subscription in Xcode
- [ ] Console shows "Purchase RESTORED" on app startup
- [ ] Console shows "Subscription synced successfully"
- [ ] Database has subscription record
- [ ] Profile has is_subscribed = true

Share which items are ❌ and I'll provide specific fixes.
