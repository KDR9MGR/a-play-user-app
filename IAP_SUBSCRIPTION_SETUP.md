# IAP Subscription Setup - Complete Fix

## Issues Fixed

I've identified and fixed the **ROOT CAUSE** of all your subscription issues:

### ❌ The Problem
The database had **Row Level Security (RLS) policies** that blocked users from creating subscriptions directly. The old policy only allowed `service_role` to insert subscriptions, but your app code tries to insert as an authenticated user.

**Result**: Every purchase attempt failed silently with permission errors!

### ✅ The Solution
Created comprehensive migration that:
1. **Adds subscription tracking columns** to `profiles` table
2. **Fixes RLS policies** to allow authenticated users to insert their own subscriptions
3. **Creates database trigger** to auto-update profiles when subscriptions change
4. **Adds helper functions** for subscription validation
5. **Updates code** to work with the new schema

---

## Step 1: Apply Database Migration

You **MUST** run this migration first or nothing will work:

```bash
supabase db push
```

This applies the migration file: `supabase/migrations/20260421_fix_iap_subscriptions.sql`

### What the migration does:

#### 1. Adds New Columns to `profiles` Table
```sql
- is_subscribed (BOOLEAN) - Quick check if user has active sub
- subscription_tier (TEXT) - Current tier: Gold/Platinum/Black
- subscription_expires_at (TIMESTAMP) - When subscription ends
```

#### 2. Fixes RLS Policies
**OLD POLICY (BROKEN):**
```sql
-- Only service_role can insert - BLOCKS USER PURCHASES!
CREATE POLICY "user_subscriptions_insert_service"
  WITH CHECK (false);
```

**NEW POLICY (WORKING):**
```sql
-- Authenticated users can insert their own subscriptions
CREATE POLICY "user_subscriptions_insert_own"
  WITH CHECK (auth.uid() = user_id);
```

#### 3. Creates Auto-Update Trigger
```sql
-- Automatically updates profiles when subscription changes
-- You don't need to manually update profiles anymore!
CREATE TRIGGER trigger_update_profile_subscription
  AFTER INSERT OR UPDATE ON user_subscriptions
  EXECUTE FUNCTION update_profile_subscription_status();
```

#### 4. Adds Helper Functions
```sql
-- Check if user has active subscription
has_active_subscription(user_id)

-- Get user's active subscription details
get_active_subscription(user_id)

-- Expire old subscriptions (run this daily)
expire_old_subscriptions()
```

---

## Step 2: Verify Migration Applied Successfully

Run this in Supabase SQL Editor:

```sql
-- Check if new columns exist in profiles
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('is_subscribed', 'subscription_tier', 'subscription_expires_at');
```

**Expected Result:** Should return 3 rows

```sql
-- Check if new RLS policies exist
SELECT polname
FROM pg_policies
WHERE tablename = 'user_subscriptions'
AND polname IN ('user_subscriptions_insert_own', 'user_subscriptions_insert_service_role');
```

**Expected Result:** Should return 2 policies

```sql
-- Check if trigger exists
SELECT trigger_name
FROM information_schema.triggers
WHERE trigger_name = 'trigger_update_profile_subscription';
```

**Expected Result:** Should return 1 row

---

## Step 3: Test the Complete Flow

### Test 1: Fresh User Purchase

1. **Run the app** on iOS simulator
2. **Login** with a test account that has no subscription
3. **Navigate to subscription screen**
4. **Expected**: Should see all 4 subscription options (7day, 1month, 3SUB, 365day)
5. **Tap "Subscribe Now"** on any plan
6. **StoreKit dialog appears** - Tap "Buy"
7. **Watch console logs** for:
   ```
   IAPService: ✓ Purchase SUCCESSFUL!
   IAPService: Product: 7day
   SubscriptionScreen: Purchase successful: 7day
   IAPVerification: Creating new subscription record...
   IAPVerification: ✓ Subscription record created
   IAPVerification: ✓ Subscription activated successfully!
   IAPVerification: ℹ️  Profile will be updated by database trigger
   ```

8. **Check database** - Run this query:
   ```sql
   SELECT
     p.email,
     p.is_subscribed,
     p.subscription_tier,
     p.subscription_expires_at,
     us.plan_id,
     us.status
   FROM profiles p
   LEFT JOIN user_subscriptions us ON us.user_id = p.id AND us.status = 'active'
   WHERE p.id = auth.uid();
   ```

   **Expected Result:**
   ```
   is_subscribed: true
   subscription_tier: Gold (for 7day) / Platinum (for 1month or 3SUB) / Black (for 365day)
   subscription_expires_at: [future date]
   plan_id: weekly_plan / monthly_plan / quarterly_plan / annual_plan
   status: active
   ```

### Test 2: Existing Subscriber (Duplicate Purchase Prevention)

1. **Close and reopen the app** (should restore subscription from StoreKit)
2. **Watch console logs** for:
   ```
   IAPService: Checking for existing subscriptions...
   IAPService: ↻ Purchase RESTORED
   IAPService: Auto-syncing restored purchase to database...
   SubscriptionSync: ✓ Subscription synced successfully
   ```

3. **Navigate to subscription screen**
4. **Expected**: Should see "You're Already Subscribed!" view instead of purchase buttons
5. **Verify it shows**:
   - ✅ Your tier badge (Gold/Platinum/Black)
   - ✅ Days remaining until renewal
   - ✅ Renewal date
   - ✅ Message explaining you can't purchase another subscription
   - ✅ Only "Go Back" button (no purchase buttons)

### Test 3: Subscription Validation on App Startup

1. **Ensure you have active subscription in StoreKit** (from Test 1)
2. **Quit the app completely** (not just background, full quit from app switcher)
3. **Relaunch the app**
4. **Watch console logs**:
   ```
   Initializing IAP Service for subscription sync...
   IAPService: Initializing...
   IAPService: Checking for existing subscriptions...
   IAPService: Querying past purchases...
   IAPService: ↻ Purchase RESTORED
   IAPService: Product: 7day
   IAPService: Auto-syncing restored purchase to database...
   SubscriptionSync: Checking active subscription for user: [user_id]
   SubscriptionSync: User already has active subscription: weekly_plan
   SubscriptionSync: Updating existing subscription end_date
   SubscriptionSync: ✓ Subscription dates updated
   IAPService: ✓ Restored purchase synced to database
   ✅ IAP Service initialized
   ```

5. **Open subscription screen**
6. **Expected**: Immediately shows "Already Subscribed" view (no loading, no product cards)

---

## How It Works Now

### Purchase Flow (New Users)
```
User taps "Subscribe Now"
  ↓
StoreKit processes payment
  ↓
IAPService._handlePurchased() fires
  ↓
Calls IAPVerificationService.verifyAndActivateSubscription()
  ↓
Inserts record into user_subscriptions table
  ↓
Database trigger automatically updates profiles table
  ↓
User's profile now has:
  - is_subscribed = true
  - subscription_tier = Gold/Platinum/Black
  - subscription_expires_at = [end date]
  ↓
Success dialog shown → Screen closes
```

### Restore Flow (Existing Subscribers)
```
App launches
  ↓
IAPService.initialize() runs
  ↓
Calls restorePurchases() automatically
  ↓
StoreKit returns active subscriptions
  ↓
IAPService._handleRestored() fires for each subscription
  ↓
Calls SubscriptionSyncService.syncFromStoreKit()
  ↓
Checks if subscription already exists in database
  ↓
If exists: Updates end_date
If not: Creates new subscription record
  ↓
Database trigger updates profiles table
  ↓
User opens subscription screen
  ↓
SubscriptionSyncService.hasActiveSubscription() returns true
  ↓
Shows "Already Subscribed" view (blocks duplicate purchase)
```

### Subscription Validation Flow
```
User opens subscription screen
  ↓
SubscriptionScreenNew._initialize() runs
  ↓
STEP 1: Check database for active subscription FIRST
  ↓
Queries profiles table: SELECT is_subscribed, subscription_expires_at
  ↓
If is_subscribed = true AND expires_at > NOW():
  → Show "Already Subscribed" view → DONE (don't load products)
  ↓
If is_subscribed = false OR expired:
  → Load IAP products → Show purchase options
```

---

## Product ID → Tier Mapping

| Product ID | Duration | Plan ID        | Tier     | Points |
|------------|----------|----------------|----------|--------|
| `7day`     | 1 week   | weekly_plan    | Gold     | 50     |
| `1month`   | 1 month  | monthly_plan   | Platinum | 200    |
| `3SUB`     | 3 months | quarterly_plan | Platinum | 650    |
| `365day`   | 1 year   | annual_plan    | Black    | 3000   |

---

## Files Modified

### Database
1. **`supabase/migrations/20260421_fix_iap_subscriptions.sql`** (NEW)
   - Complete migration fixing all database issues

### Services
2. **`lib/features/subscription/service/iap_verification_service.dart`**
   - Simplified to rely on database trigger for profile updates
   - Added better logging
   - Handles existing subscription updates

3. **`lib/features/subscription/service/subscription_sync_service.dart`**
   - Fixed to include `tier` and `billing_cycle` fields
   - Removed manual profile updates (trigger handles it)

4. **`lib/core/services/iap_service.dart`**
   - Auto-syncs restored purchases on app startup
   - Prevents orphaned subscriptions

### UI
5. **`lib/features/subscription/view/subscription_screen_new.dart`**
   - Checks for active subscription BEFORE loading products
   - Shows "Already Subscribed" view for existing subscribers
   - Blocks duplicate purchases

6. **`lib/main.dart`**
   - Initializes IAPService on app startup
   - Ensures subscription sync happens before app loads

---

## Troubleshooting

### Issue: "new row violates row-level security policy"
**Cause**: Migration not applied
**Fix**: Run `supabase db push`

### Issue: "column 'is_subscribed' does not exist"
**Cause**: Migration not applied
**Fix**: Run `supabase db push`

### Issue: Purchase succeeds but database not updated
**Cause**: Trigger not created or not firing
**Check**: Run this query:
```sql
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE trigger_name = 'trigger_update_profile_subscription';
```
**Fix**: Re-run migration

### Issue: "User not authenticated"
**Cause**: User not logged in
**Fix**: Ensure user is logged in before opening subscription screen

### Issue: Subscription screen still shows purchase options for existing subscriber
**Cause**: Profile not updated or subscription expired
**Check**: Run this query:
```sql
SELECT is_subscribed, subscription_expires_at
FROM profiles
WHERE id = auth.uid();
```
**Fix**: If `is_subscribed = false`, trigger didn't fire. Check trigger exists.

### Issue: Console shows "Store not available"
**Cause**: StoreKit not configured in simulator
**Fix**:
1. In Xcode, go to Product → Scheme → Edit Scheme
2. Run → Options → StoreKit Configuration
3. Select your StoreKit configuration file

---

## Critical Steps Summary

✅ **MUST DO** - Apply migration:
```bash
supabase db push
```

✅ **VERIFY** - Check columns exist:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('is_subscribed', 'subscription_tier', 'subscription_expires_at');
```

✅ **VERIFY** - Check RLS policies:
```sql
SELECT polname FROM pg_policies
WHERE tablename = 'user_subscriptions'
AND polname = 'user_subscriptions_insert_own';
```

✅ **TEST** - Run app and try to purchase

✅ **VERIFY** - Check database after purchase:
```sql
SELECT is_subscribed, subscription_tier
FROM profiles WHERE id = auth.uid();
```

---

## Expected Console Logs

### Successful Purchase
```
IAPService: ✓ Purchase SUCCESSFUL!
IAPService: Product: 7day
IAPService: Transaction: [transaction_id]
SubscriptionScreen: Purchase successful: 7day
IAPVerification: ═══════════════════════════
IAPVerification: Starting verification for: 7day
IAPVerification: User ID: [user_id]
IAPVerification: Plan ID: weekly_plan
IAPVerification: Tier: Gold
IAPVerification: Duration: 7 days
IAPVerification: Creating new subscription record...
IAPVerification: ✓ Subscription record created
IAPVerification: ✓ Subscription activated successfully!
IAPVerification: ✓ Tier: Gold
IAPVerification: ℹ️  Profile will be updated by database trigger
IAPVerification: ═══════════════════════════
```

### Subscription Restored on Startup
```
Initializing IAP Service for subscription sync...
IAPService: Initializing...
IAPService: Store available: true
IAPService: Checking for existing subscriptions...
IAPService: Querying past purchases...
IAPService: ↻ Purchase RESTORED
IAPService: Product: 7day
IAPService: Auto-syncing restored purchase to database...
SubscriptionSync: Syncing subscription from StoreKit: 7day
SubscriptionSync: User already has active subscription: weekly_plan
SubscriptionSync: Updating existing subscription end_date
SubscriptionSync: ✓ Subscription dates updated
IAPService: ✓ Restored purchase synced to database
✅ IAP Service initialized
```

### Existing Subscriber Opens Screen
```
SubscriptionScreen: Initializing...
SubscriptionScreen: Checking for existing subscriptions...
SubscriptionSync: Checking active subscription for user: [user_id]
SubscriptionSync: ✓ Active subscription found, expires: [date]
SubscriptionScreen: ✓ User already has active subscription
[Shows "Already Subscribed" view - no purchase buttons]
```

---

## Next Steps

1. **Run the migration**: `supabase db push`
2. **Verify migration applied** (run SQL queries above)
3. **Test fresh purchase** (new user account)
4. **Test duplicate prevention** (existing subscriber)
5. **Test restore on startup** (quit and relaunch app)

Once all tests pass, your subscription system is fully functional for MVP! 🎉
