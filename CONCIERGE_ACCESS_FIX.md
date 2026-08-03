# Concierge Access Issue - Diagnosis & Fix

**Date:** May 29, 2026
**Issue:** User shows as premium but cannot access concierge features
**Root Cause:** Multiple subscription systems not synchronized

---

## Problem Analysis

The app has **THREE separate subscription tracking systems**:

1. **`profiles.is_premium`** - Boolean flag (shows premium badge)
2. **`user_subscriptions`** - New IAP system with database trigger
3. **`subscriptions`** - Old IAP system checked by backend provider

### Access Control Logic

**File:** `lib/features/subscription/utils/subscription_utils.dart` (lines 29-51)

```dart
static bool hasPremiumAccess(WidgetRef ref) {
  // PRIMARY CHECK: Backend IAP subscription status
  final backendStatus = ref.watch(backendSubscriptionStatusProvider);
  const hasBackendSub = backendStatus.when(
    data: (status) => status.isActive,
    loading: () => false,  // Returns false while loading
    error: (_, __) => false,  // Returns false on error
  );
  if (hasBackendSub) return true;

  // FALLBACK CHECK: Profile is_premium flag
  final profileAsync = ref.watch(profileFutureProvider);
  return profileAsync.when(
    data: (profile) => profile.isPremium,
    loading: () => false,
    error: (_, __) => false,
  );
}
```

### Why Access is Denied

The backend provider checks the **`subscriptions`** table (NOT `user_subscriptions`):

**File:** `supabase/functions/get-subscription-status/index.ts` (lines 112-113)
```typescript
const { data: functionResult } = await supabase
  .rpc('get_user_subscription', { p_user_id: userId });
```

**Database Function:** `supabase/migrations/20250108_create_subscriptions_table.sql` (lines 113-118)
```sql
SELECT ... FROM public.subscriptions s  -- Checks THIS table
WHERE s.user_id = p_user_id
  AND s.status IN ('active', 'grace_period')
  AND (s.expires_at IS NULL OR s.expires_at > NOW())
```

**Result:**
- If no record in `subscriptions` table → backend returns `false`
- Fallback checks `is_premium` → might return `true`
- BUT: If provider is in loading/error state → both return `false`
- **Concierge shows paywall** 🔒

---

## IMMEDIATE FIX: Verify Database State

### Step 1: Get Your User ID

Run this query in Supabase SQL Editor:

```sql
-- Find your user by email
SELECT id, email, raw_user_meta_data->>'full_name' as name
FROM auth.users
WHERE email = 'your-email@example.com';
```

Copy the `id` value (UUID).

---

### Step 2: Check All Subscription Tables

Replace `'YOUR_USER_ID'` with your actual UUID in this query:

```sql
-- 1. Check profiles table
SELECT
  id,
  full_name,
  is_premium,
  is_subscribed,
  subscription_tier,
  subscription_expires_at,
  current_tier
FROM profiles
WHERE id = 'YOUR_USER_ID';

-- 2. Check user_subscriptions table (trigger-based system)
SELECT
  id,
  user_id,
  platform,
  product_id,
  plan_id,
  status,
  start_date,
  end_date,
  expires_at,
  sandbox,
  created_at
FROM user_subscriptions
WHERE user_id = 'YOUR_USER_ID'
ORDER BY created_at DESC
LIMIT 5;

-- 3. Check subscriptions table (backend provider checks this)
SELECT
  id,
  user_id,
  platform,
  product_id,
  status,
  expires_at,
  created_at
FROM subscriptions
WHERE user_id = 'YOUR_USER_ID'
ORDER BY created_at DESC
LIMIT 5;
```

---

## DIAGNOSIS SCENARIOS

### Scenario A: All Tables Empty
**Symptoms:**
- No records in any subscription table
- `is_premium = false`

**Fix:**
```sql
-- Set premium flag manually (temporary)
UPDATE profiles
SET is_premium = true,
    is_subscribed = true,
    subscription_tier = 'Platinum',
    subscription_expires_at = NOW() + INTERVAL '30 days',
    current_tier = 'Platinum'
WHERE id = 'YOUR_USER_ID';
```

---

### Scenario B: Record in user_subscriptions, But NOT in subscriptions
**Symptoms:**
- `user_subscriptions` has active record
- `subscriptions` table empty
- Backend provider returns no subscription

**Fix Option 1: Copy to subscriptions table**
```sql
-- Copy from user_subscriptions to subscriptions
INSERT INTO subscriptions (
  user_id,
  platform,
  product_id,
  status,
  expires_at,
  created_at
)
SELECT
  user_id,
  platform,
  product_id,
  status,
  end_date as expires_at,
  created_at
FROM user_subscriptions
WHERE user_id = 'YOUR_USER_ID'
  AND status = 'active'
  AND end_date > NOW()
ORDER BY created_at DESC
LIMIT 1;
```

**Fix Option 2: Update profiles directly**
```sql
-- Ensure profile is synced with user_subscriptions
UPDATE profiles p
SET
  is_premium = true,
  is_subscribed = true,
  subscription_tier = 'Platinum',
  subscription_expires_at = us.end_date,
  current_tier = 'Platinum'
FROM user_subscriptions us
WHERE p.id = us.user_id
  AND p.id = 'YOUR_USER_ID'
  AND us.status = 'active'
  AND us.end_date > NOW();
```

---

### Scenario C: Expired Subscription
**Symptoms:**
- Record exists but `status = 'expired'` or `expires_at` in past
- `is_premium = true` (not updated)

**Fix:**
```sql
-- Update to active with future expiry
UPDATE user_subscriptions
SET
  status = 'active',
  end_date = NOW() + INTERVAL '30 days',
  expires_at = NOW() + INTERVAL '30 days'
WHERE user_id = 'YOUR_USER_ID'
  AND id = (
    SELECT id FROM user_subscriptions
    WHERE user_id = 'YOUR_USER_ID'
    ORDER BY created_at DESC
    LIMIT 1
  );

-- Trigger will auto-update profile
```

---

### Scenario D: Profile Flag Wrong
**Symptoms:**
- Active subscription exists
- `is_premium = false`

**Fix:**
```sql
-- Manually fire the trigger
UPDATE user_subscriptions
SET updated_at = NOW()
WHERE user_id = 'YOUR_USER_ID'
  AND status = 'active';

-- OR set flag directly
UPDATE profiles
SET is_premium = true,
    is_subscribed = true
WHERE id = 'YOUR_USER_ID';
```

---

## PERMANENT FIX: Sync Subscription Systems

### Option 1: Migrate to Single System (Recommended)

Create migration to consolidate tables:

```sql
-- Create function to sync subscriptions → user_subscriptions
CREATE OR REPLACE FUNCTION sync_subscription_tables()
RETURNS void AS $$
BEGIN
  -- Copy active subscriptions to user_subscriptions
  INSERT INTO user_subscriptions (
    user_id, platform, product_id, plan_id,
    status, start_date, end_date, expires_at,
    latest_transaction_id, original_transaction_id,
    sandbox, created_at
  )
  SELECT
    s.user_id,
    s.platform,
    s.product_id,
    s.product_id as plan_id,
    s.status,
    s.created_at as start_date,
    s.expires_at as end_date,
    s.expires_at,
    s.transaction_id as latest_transaction_id,
    s.transaction_id as original_transaction_id,
    COALESCE(s.is_sandbox, false) as sandbox,
    s.created_at
  FROM subscriptions s
  WHERE s.status = 'active'
    AND NOT EXISTS (
      SELECT 1 FROM user_subscriptions us
      WHERE us.user_id = s.user_id
        AND us.platform = s.platform
    )
  ON CONFLICT (latest_transaction_id) DO NOTHING;

  -- Trigger will auto-update profiles
END;
$$ LANGUAGE plpgsql;

-- Run sync
SELECT sync_subscription_tables();
```

---

### Option 2: Update Backend Provider to Check user_subscriptions

**File:** `supabase/functions/get-subscription-status/index.ts`

Change line 113 to check `user_subscriptions` instead:

```typescript
// Before (checks 'subscriptions' table)
const { data: functionResult } = await supabase
  .rpc('get_user_subscription', { p_user_id: userId });

// After (check user_subscriptions directly)
const { data: subscription } = await supabase
  .from('user_subscriptions')
  .select('*')
  .eq('user_id', userId)
  .eq('status', 'active')
  .gt('end_date', new Date().toISOString())
  .order('created_at', { ascending: false })
  .limit(1)
  .single();
```

Then redeploy:
```bash
supabase functions deploy get-subscription-status --project-ref yvnfhsipyfxdmulajbgl
```

---

## TESTING AFTER FIX

### 1. Restart App
- Force quit app
- Clear app cache (optional)
- Relaunch

### 2. Check Profile Screen
- Navigate to Profile
- Verify premium badge shows
- Check subscription tier displays

### 3. Test Concierge Access
- Navigate to Concierge tab
- Cards should NOT show lock icon
- Should be able to create requests
- No paywall should appear

### 4. Verify Console Logs
Look for these logs:
```
BackendSubscriptionProvider: Response: {isSubscribed: true, status: active, ...}
SubscriptionUtils: Has premium access: true
```

---

## DEBUG COMMANDS

### Check Provider State in App
Add temporary debug logging in `concierge_page.dart` after line 425:

```dart
final hasPremiumAccess = SubscriptionUtils.hasPremiumAccess(ref);

// ADD THIS DEBUG CODE
print('🔍 Concierge Access Debug:');
print('  hasPremiumAccess: $hasPremiumAccess');
final backendStatus = ref.watch(backendSubscriptionStatusProvider);
backendStatus.when(
  data: (status) => print('  Backend: isActive=${status.isActive}, status=${status.status}'),
  loading: () => print('  Backend: LOADING'),
  error: (e, st) => print('  Backend: ERROR - $e'),
);
final profile = ref.watch(profileFutureProvider);
profile.when(
  data: (p) => print('  Profile: isPremium=${p.isPremium}'),
  loading: () => print('  Profile: LOADING'),
  error: (e, st) => print('  Profile: ERROR - $e'),
);
```

---

## RECOMMENDED SOLUTION

**For immediate access:**
1. Run Scenario B Fix Option 2 (update profiles directly)
2. Restart app
3. Test concierge access

**For permanent fix:**
1. Consolidate to `user_subscriptions` table only
2. Update backend provider to check that table
3. Remove `subscriptions` table dependency
4. Keep `is_premium` as denormalized cache

---

**Status:** Ready to implement
**Estimated Fix Time:** 5-10 minutes (database update + app restart)
**Risk Level:** Low (non-destructive database update)
