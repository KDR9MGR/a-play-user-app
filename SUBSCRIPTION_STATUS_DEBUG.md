# Subscription Status Inconsistency - Device vs Simulator

**Date:** June 6, 2026
**Issue:** Active subscription on device not showing on simulator
**Status:** Investigating

---

## Problem Description

**Device (Physical iPhone):**
- ✅ Subscription shows as active
- ✅ User has premium tier
- ✅ Can see subscription management view

**Simulator:**
- ❌ Shows subscription purchase screen
- ❌ Prompts to buy again
- ❌ Same account, different behavior

---

## Root Cause Analysis

### Possible Causes:

1. **StoreKit Sandbox Differences**
   - Device: Real StoreKit sandbox environment
   - Simulator: StoreKit testing environment
   - Purchase receipts might not sync between them

2. **Database Cache Issue**
   - Simulator might have cached old profile state
   - Need to verify database actually has subscription record

3. **Authentication State**
   - Same email but might be different user IDs
   - Verify both device and simulator are using same Supabase user

4. **Subscription Sync Service**
   - StoreKit sync might fail silently on simulator
   - Check console logs for sync errors

---

## Diagnostic Steps

### Step 1: Verify User ID
Check if device and simulator are using the same Supabase user:

**On Device:**
```
SubscriptionScreen: Current User ID = abc-123-def-456
SubscriptionScreen: Current User Email = test@example.com
```

**On Simulator:**
```
SubscriptionScreen: Current User ID = abc-123-def-456  ← Should match device
SubscriptionScreen: Current User Email = test@example.com
```

### Step 2: Check Database Subscription
Query the database to verify subscription exists:

```sql
-- Check profile status
SELECT
  id,
  email,
  is_subscribed,
  subscription_tier,
  current_tier,
  subscription_expires_at
FROM profiles
WHERE email = 'YOUR_TEST_EMAIL@example.com';

-- Check subscription record
SELECT
  user_id,
  plan_id,
  plan_type,
  tier,
  status,
  start_date,
  end_date,
  payment_method
FROM user_subscriptions
WHERE user_id = 'YOUR_USER_ID'
ORDER BY created_at DESC
LIMIT 1;
```

### Step 3: Check Console Logs

**Expected on Device (Active Subscription):**
```
SubscriptionScreen: Checking for existing subscriptions...
SubscriptionSync: Checking active subscription for user: abc-123...
SubscriptionSync: ✓ Active subscription found, expires: 2026-07-06
SubscriptionScreen: hasActive = true
SubscriptionScreen: ✓ User already has active subscription - SHOWING MANAGEMENT VIEW
```

**What Simulator Might Show:**
```
SubscriptionScreen: Checking for existing subscriptions...
SubscriptionSync: Checking active subscription for user: abc-123...
SubscriptionSync: User not subscribed                           ← WRONG!
SubscriptionScreen: hasActive = false
SubscriptionScreen: No active subscription found, loading products...
```

### Step 4: Force Refresh Profile
Add a manual refresh button to re-query the database:

```dart
Future<void> _forceRefreshSubscription() async {
  setState(() => _isLoading = true);

  // Clear cached state
  _hasActiveSubscription = false;
  _activeSubscription = null;

  // Re-check subscription
  final hasActive = await _syncService.hasActiveSubscription();
  final activeSub = await _syncService.getActiveSubscription();

  setState(() {
    _hasActiveSubscription = hasActive;
    _activeSubscription = activeSub;
    _isLoading = false;
  });
}
```

---

## Fixes to Try

### Fix 1: Add Refresh Button (Temporary)
Add a button to manually refresh subscription status from database.

### Fix 2: Bypass StoreKit Sync in Simulator
Detect simulator and skip StoreKit sync:

```dart
// In subscription_screen_new.dart
Future<void> _initialize() async {
  // Skip StoreKit sync in simulator (it's unreliable)
  if (!kIsWeb && Platform.isIOS) {
    final isSimulator = await _isSimulator();
    if (!isSimulator) {
      debugPrint('SubscriptionScreen: Syncing with StoreKit...');
      await _iapService.syncDatabaseWithStoreKit();
    } else {
      debugPrint('SubscriptionScreen: Skipping StoreKit sync (simulator)');
    }
  }

  // Always check database subscription status
  final hasActive = await _syncService.hasActiveSubscription();
  // ...
}
```

### Fix 3: Add Database-Only Mode
Add a flag to check subscription status from database only:

```dart
// In subscription_sync_service.dart
Future<bool> hasActiveSubscriptionDatabaseOnly() async {
  // Only checks database, ignores StoreKit
  // Useful for debugging and simulator testing
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return false;

  final response = await _supabase
      .from('user_subscriptions')
      .select()
      .eq('user_id', userId)
      .eq('status', 'active')
      .gte('end_date', DateTime.now().toIso8601String())
      .maybeSingle();

  return response != null;
}
```

### Fix 4: Clear Simulator Cache
Sometimes simulator caches stale data:

```bash
# On Mac, run these commands:
xcrun simctl shutdown all
xcrun simctl erase all

# Then rebuild:
flutter clean
flutter pub get
flutter run
```

---

## Recommended Solution

**For Production:**
1. Always trust database subscription state over StoreKit
2. Use StoreKit sync as a background task, not a blocker
3. Add retry logic for subscription status checks

**For Debugging:**
1. Add console logs showing user ID on both device and simulator
2. Verify database has subscription record for that user
3. Add manual refresh button to re-query database
4. Check if simulator and device are actually the same Supabase user

**Immediate Fix:**
Add a "Refresh Subscription Status" button that bypasses cache and re-queries the database.

---

## Code Location

**Subscription Check Logic:**
- [subscription_screen_new.dart:61-83](lib/features/subscription/view/subscription_screen_new.dart#L61-L83)
- [subscription_sync_service.dart:9-59](lib/features/subscription/service/subscription_sync_service.dart#L9-L59)

**Key Method:**
```dart
// lib/features/subscription/service/subscription_sync_service.dart:9
Future<bool> hasActiveSubscription() async {
  // Checks profiles.is_subscribed
  // Verifies subscription_expires_at is in future
  // Should work identically on device and simulator
}
```

---

## SQL Debugging Queries

### Check Specific User Subscription
```sql
-- Replace with your test account email
SELECT
  p.id,
  p.email,
  p.is_subscribed,
  p.subscription_tier,
  p.subscription_expires_at,
  s.plan_id,
  s.status,
  s.end_date
FROM profiles p
LEFT JOIN user_subscriptions s ON p.id = s.user_id AND s.status = 'active'
WHERE p.email = 'YOUR_TEST_EMAIL@example.com';
```

### Find All Active Subscriptions
```sql
SELECT
  user_id,
  plan_id,
  tier,
  status,
  end_date,
  payment_method,
  created_at
FROM user_subscriptions
WHERE status = 'active'
  AND end_date > NOW()
ORDER BY created_at DESC;
```

### Check Profile Subscription Fields
```sql
SELECT
  email,
  is_subscribed,
  subscription_tier,
  current_tier,
  subscription_expires_at,
  updated_at
FROM profiles
WHERE is_subscribed = true
ORDER BY updated_at DESC
LIMIT 10;
```

---

## Next Steps

1. **Get Console Logs:**
   - From device showing "User already has active subscription"
   - From simulator showing "No active subscription found"

2. **Run SQL Query:**
   - Verify subscription exists in database for test account

3. **Check User ID:**
   - Ensure device and simulator using same Supabase user

4. **Implement Fix:**
   - Add refresh button (quick fix)
   - Skip StoreKit sync in simulator (medium fix)
   - Improve subscription status logic (long-term fix)

---

**Status:** Awaiting diagnostic information to determine root cause
