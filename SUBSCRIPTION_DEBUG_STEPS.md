# Subscription Debug Steps

## Issue
Different users are seeing the same subscription status - this suggests either:
1. User authentication is not working properly
2. Database RLS policies are not filtering by user correctly
3. The subscription data is somehow shared/cached

## Debug Steps to Run

### 1. Check Current User Authentication
Run the app and check console for these logs when you open subscription screen:

```
SubscriptionSync: Checking active subscription for user: <USER_ID>
SubscriptionSync: getActiveSubscription for userId: <USER_ID>
```

**Expected**: Different USER_IDs for different test accounts
**If same USER_ID**: Authentication is broken - user is not logging out properly

### 2. Check Database Query Results
Look for these console logs:

```
SubscriptionSync: profileResponse = {data}
SubscriptionSync: subResponse = {data}
```

**Expected**: NULL or empty for users without subscriptions
**If showing data for wrong user**: RLS policies are broken

### 3. Verify in Supabase Dashboard

Go to Supabase Dashboard → Table Editor:

1. **Check `profiles` table**:
   - Find your test user by email
   - Check `is_subscribed` column
   - Check `subscription_tier` column
   - Note the user's `id` (UUID)

2. **Check `user_subscriptions` table**:
   - Filter by `status = 'active'`
   - Check `user_id` column - does it match the correct user?
   - Are there multiple active subscriptions?

### 4. Check RLS Policies

In Supabase Dashboard → Authentication → Policies:

**For `user_subscriptions` table, verify these policies exist**:

```sql
-- SELECT policy
CREATE POLICY "user_subscriptions_select_own"
  ON user_subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- INSERT policy
CREATE POLICY "user_subscriptions_insert_own"
  ON user_subscriptions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

**For `profiles` table**:
```sql
-- SELECT policy
CREATE POLICY "profiles_select_own"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);
```

### 5. Test User Isolation

**Steps**:
1. Login as User A (who has subscription)
2. Note the console logs showing USER_ID
3. Logout completely
4. Login as User B (fresh account, no subscription)
5. Note the console logs showing USER_ID
6. Navigate to subscription screen
7. Check console logs

**Expected Result**: User B should see empty data, purchase options
**Actual Result**: If User B sees User A's subscription, it's a caching/auth issue

## Possible Fixes

### Fix 1: Clear Auth State on Logout
Ensure logout is properly clearing all cached data.

### Fix 2: Fix RLS Policies
If policies are missing or wrong, apply the migration properly.

### Fix 3: Check for Hardcoded Data
Search codebase for any hardcoded subscription data or test data.

## Console Output Needed

Please run the app with **two different users** and share:

1. **User A (with subscription)** console output showing:
   - Login userId
   - hasActiveSubscription check
   - getActiveSubscription data

2. **User B (fresh account)** console output showing:
   - Login userId
   - hasActiveSubscription check
   - getActiveSubscription data

This will help identify if it's auth, RLS, or caching issue.
