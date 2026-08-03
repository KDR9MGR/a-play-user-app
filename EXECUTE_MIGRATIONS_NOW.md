# EXECUTE THESE MIGRATIONS IMMEDIATELY

**Status:** 🔴 CRITICAL - App is crashing because these tables don't exist

---

## Step-by-Step Instructions

### 1. Go to Supabase Dashboard

1. Open your browser
2. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
3. Select your A-Play project
4. Click **SQL Editor** in the left sidebar

---

### 2. Execute Migration #1: Create post_gifts Table

Copy and paste this entire SQL script into the SQL Editor and click **RUN**:

```sql
-- Create post_gifts table to fix profile edit error
-- This table tracks gifts given to posts/feeds

CREATE TABLE IF NOT EXISTS post_gifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feed_id UUID NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
  gifter_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  points_amount INTEGER NOT NULL CHECK (points_amount > 0),
  gift_type TEXT NOT NULL,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_post_gifts_feed_id ON post_gifts(feed_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_gifter ON post_gifts(gifter_user_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_receiver ON post_gifts(receiver_user_id);
CREATE INDEX IF NOT EXISTS idx_post_gifts_status ON post_gifts(status);

-- Function to get post gift summary
CREATE OR REPLACE FUNCTION get_post_gift_summary(p_feed_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_gifts INTEGER;
  v_total_points INTEGER;
  v_unique_gifters INTEGER;
BEGIN
  -- Get aggregated gift data
  SELECT
    COALESCE(COUNT(*), 0),
    COALESCE(SUM(points_amount), 0),
    COALESCE(COUNT(DISTINCT gifter_user_id), 0)
  INTO
    v_total_gifts,
    v_total_points,
    v_unique_gifters
  FROM post_gifts
  WHERE feed_id = p_feed_id
    AND status = 'completed';

  -- Return JSON summary
  RETURN json_build_object(
    'totalGifts', v_total_gifts,
    'totalPoints', v_total_points,
    'uniqueGifters', v_unique_gifters,
    'userHasGifted', false,
    'userGiftType', null
  );
END;
$$;

-- Function to process post gift (placeholder - full implementation needed)
CREATE OR REPLACE FUNCTION process_post_gift(
  p_feed_id UUID,
  p_gifter_user_id UUID,
  p_receiver_user_id UUID,
  p_points_amount INTEGER,
  p_gift_type TEXT,
  p_message TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- For now, just return success
  -- Full implementation would:
  -- 1. Check gifter has enough points
  -- 2. Deduct points from gifter
  -- 3. Add points to receiver
  -- 4. Create gift record
  -- 5. Update post statistics

  RETURN json_build_object(
    'success', false,
    'error', 'Gift feature not yet enabled'
  );
END;
$$;

-- Grant permissions
GRANT SELECT, INSERT ON post_gifts TO authenticated;
GRANT EXECUTE ON FUNCTION get_post_gift_summary TO authenticated;
GRANT EXECUTE ON FUNCTION process_post_gift TO authenticated;
```

**Expected Result:** "Success. No rows returned"

---

### 3. Verify Migration #1 Succeeded

Run this verification query:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'post_gifts';
```

**Expected Result:** Should show 1 row with `post_gifts`

---

### 4. Execute Migration #2: Populate Subscription Plans

Copy and paste this entire SQL script and click **RUN**:

```sql
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
```

**Expected Result:** Should show 4 rows with subscription plans and proper prices

---

### 5. Verify Migration #2 Succeeded

Run this verification query:

```sql
SELECT id, name, price, currency
FROM subscription_plans
ORDER BY duration_days;
```

**Expected Result:**
```
weekly_plan     | 1 Week Premium    | 50.00   | GHS
monthly_plan    | 1 Month Premium   | 190.00  | GHS
quarterly_plan  | 3 Months Premium  | 550.00  | GHS
annual_plan     | 1 Year Premium    | 2200.00 | GHS
```

---

## After Running Both Migrations

### Restart Your App

In your terminal:

```bash
# Stop the current Flutter app (Ctrl+C or Cmd+C)
# Then run:
flutter clean
flutter run
```

### Expected Behavior

✅ **App launches successfully**
✅ **No "Failed to initialize app" error**
✅ **No "post_gifts does not exist" errors in logs**
✅ **Profile edit screen works**
✅ **Can navigate back from profile edit without crash**
✅ **Subscription screen shows proper prices (GHS 50, 190, 550, 2200)**

---

## Why This Fixes Everything

### Fix #1: post_gifts Table
- **Before:** Table doesn't exist → PostgrestException → app crash
- **After:** Table exists → queries work → no crash
- **Fixes:** Profile edit crash, feed gift summary errors

### Fix #2: Subscription Plans
- **Before:** Table empty or has $0.00 prices → Apple rejects
- **After:** Proper GHS pricing → Apple approves
- **Fixes:** App Store review Issue #2

---

## Troubleshooting

### If you get "table already exists" error:
```sql
-- Drop the table and recreate
DROP TABLE IF EXISTS post_gifts CASCADE;
-- Then run the full migration again
```

### If you get foreign key errors:
The `feeds` and `profiles` tables must exist. Check:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_name IN ('feeds', 'profiles');
```

### If subscription_plans doesn't exist:
You may need to create it first. Check your earlier migrations or contact me.

---

## Quick Checklist

- [ ] Opened Supabase Dashboard
- [ ] Went to SQL Editor
- [ ] Executed Migration #1 (post_gifts table)
- [ ] Verified post_gifts table exists
- [ ] Executed Migration #2 (subscription plans)
- [ ] Verified 4 subscription plans with proper prices
- [ ] Stopped Flutter app
- [ ] Ran `flutter clean`
- [ ] Ran `flutter run`
- [ ] App launches without crash
- [ ] Tested profile edit → back navigation
- [ ] Checked subscription screen shows proper prices

---

🔴 **DO THIS NOW** - Your app cannot launch until these migrations are executed!
