# Subscription Session Management - Security Analysis

**Date:** June 9, 2026
**Severity:** MEDIUM - Potential subscription bypass vulnerabilities

---

## Your Question:

> "in regards to sub session mangment for user are we doing it from backend or app codebase casue backend check is more realilbale"

**Answer:** You have a **HYBRID** approach, but **backend checks are insufficient** for critical features.

---

## Current Architecture

### ✅ BACKEND Verification (Secure)

#### 1. Supabase Edge Functions
**Location:** `supabase/functions/`

**`verify-apple-sub/index.ts`** ([verify-apple-sub/index.ts:62-93](supabase/functions/verify-apple-sub/index.ts#L62-L93)):
- ✅ Verifies receipts directly with Apple's servers
- ✅ Parses subscription status server-side
- ✅ Validates expiry: `expiresMs > Date.now()`
- ✅ Stores in `user_subscriptions` table
- ✅ Cannot be bypassed by client

**`get-subscription-status/index.ts`** ([get-subscription-status/index.ts:108-135](supabase/functions/get-subscription-status/index.ts#L108-L135)):
```typescript
// Server-side expiry check
.gt('end_date', new Date().toISOString())
```
- ✅ Uses server time (not client clock)
- ✅ Queries `user_subscriptions` directly
- ✅ Bypasses RLS with service role

#### 2. Database Triggers
**Location:** `supabase/migrations/02_functions_triggers.sql`

**`sync_profile_tier()`** ([02_functions_triggers.sql:374-389](supabase/migrations/02_functions_triggers.sql#L374-L389)):
- ✅ Auto-updates `profiles.current_tier` when subscription changes
- ✅ Triggers on `user_subscriptions` INSERT/UPDATE

**`expire_old_subscriptions()`** ([02_functions_triggers.sql:348-367](supabase/migrations/02_functions_triggers.sql#L348-L367)):
- ✅ Cron job to mark expired subscriptions
- ✅ Sets `status = 'expired'` when `end_date < NOW()`
- ⚠️ **Issue:** No evidence this is scheduled

---

### ⚠️ APP-SIDE Checks (Vulnerable)

#### 1. Subscription Status Provider
**Location:** [lib/features/subscription/provider/subscription_status_provider.dart](lib/features/subscription/provider/subscription_status_provider.dart)

**Problem Lines:**
```dart
// Line 53-56: Streams from profiles table
return supabase
    .from('profiles')
    .stream(primaryKey: ['id'])
    .eq('id', userId)

// Line 35: Client-side expiry check
bool get isActive => isSubscribed && (expiresAt?.isAfter(DateTime.now()) ?? false);
```

**Vulnerabilities:**
- ⚠️ Uses client's clock (`DateTime.now()`)
- ⚠️ Reads from `profiles` table (could be stale if trigger fails)
- ⚠️ Client can manipulate device time to extend access
- ⚠️ No server-side validation of expiry

#### 2. Subscription Sync Service
**Location:** [lib/features/subscription/service/subscription_sync_service.dart](lib/features/subscription/service/subscription_sync_service.dart)

**Problem Lines:**
```dart
// Line 40-47: Client-side expiry validation
if (expiresAtStr != null) {
  final expiresAt = DateTime.parse(expiresAtStr);
  final isExpired = expiresAt.isBefore(DateTime.now()); // Uses client clock!

  if (isExpired) {
    debugPrint('SubscriptionSync: Subscription expired on: $expiresAt');
    return false;
  }
}
```

**Vulnerabilities:**
- ⚠️ Client can change device time backward to extend subscription
- ⚠️ No server verification of current time

---

## Security Risks by Feature

### 🔴 HIGH RISK - Features Relying on Client Checks

1. **Premium Content Access**
   - If premium events/features check `subscriptionStatusProvider`
   - Attacker can manipulate device time

2. **Concierge Services**
   - If tier validation happens client-side
   - Could access higher tiers without payment

3. **Discount Application**
   - If tier discounts calculated in app
   - Could apply discounts without subscription

### 🟡 MEDIUM RISK - Protected Features

1. **Booking Creation**
   - If you validate tier server-side before confirming
   - But UI shows wrong state

2. **Point Rewards**
   - Database triggers handle points
   - But user sees incorrect tier benefits in UI

---

## Attack Scenarios

### Scenario 1: Time Manipulation
**Steps:**
1. User subscribes to 7-day plan ($3.99)
2. Subscription expires after 7 days
3. User changes device time backward by 1 month
4. App's `expiresAt.isAfter(DateTime.now())` returns true
5. User accesses premium features for free

**Current Protection:** ❌ None (client-side check only)

### Scenario 2: Database Desync
**Steps:**
1. `user_subscriptions` expires (status = 'expired')
2. Trigger fails to update `profiles.is_subscribed`
3. App streams from `profiles` and sees `is_subscribed = true`
4. User retains premium access

**Current Protection:** ⚠️ Partial (depends on trigger reliability)

### Scenario 3: Apple Receipt Replay
**Steps:**
1. User subscribes and gets Apple receipt
2. User cancels subscription
3. User replays old receipt to `verify-apple-sub`
4. Function re-validates and grants access

**Current Protection:** ✅ Apple returns current status, not historical

---

## Recommendations

### 🔥 CRITICAL FIXES (Implement Now)

#### 1. Add Backend Subscription Gate for Premium Features

Create new Edge Function: `check-premium-access`

```typescript
// supabase/functions/check-premium-access/index.ts
export async function checkPremiumAccess(userId: string, requiredTier: string) {
  // Server-side check using server time
  const { data } = await supabase
    .from('user_subscriptions')
    .select('tier, status, end_date')
    .eq('user_id', userId)
    .eq('status', 'active')
    .gt('end_date', new Date().toISOString()) // SERVER TIME
    .single();

  if (!data) return { hasAccess: false };

  const tierHierarchy = ['Free', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Black'];
  const userTierLevel = tierHierarchy.indexOf(data.tier);
  const requiredTierLevel = tierHierarchy.indexOf(requiredTier);

  return {
    hasAccess: userTierLevel >= requiredTierLevel,
    currentTier: data.tier,
    expiresAt: data.end_date
  };
}
```

#### 2. Add RLS Policy to Validate Subscriptions

```sql
-- Example: Events table - only show premium events to subscribers
CREATE POLICY "premium_events_require_subscription"
ON events
FOR SELECT
USING (
  is_premium = false
  OR
  EXISTS (
    SELECT 1 FROM user_subscriptions
    WHERE user_id = auth.uid()
    AND status = 'active'
    AND end_date > NOW() -- SERVER TIME, not client time!
  )
);
```

#### 3. Schedule `expire_old_subscriptions()` Cron Job

**In Supabase Dashboard:**
1. Go to Database → Extensions
2. Enable `pg_cron`
3. Add cron job:

```sql
-- Run every hour
SELECT cron.schedule(
  'expire-old-subscriptions',
  '0 * * * *', -- Every hour at minute 0
  'SELECT expire_old_subscriptions()'
);
```

#### 4. Update App to Use Backend Checks for Critical Operations

**Current (Vulnerable):**
```dart
// lib/features/subscription/view/subscription_screen_new.dart
final isSubscribed = ref.watch(isSubscribedProvider); // Client-side check!

if (isSubscribed) {
  // Show premium features
}
```

**Fixed (Secure):**
```dart
// Before showing premium features, verify with backend
final response = await supabase.functions.invoke(
  'check-premium-access',
  body: {'userId': userId, 'requiredTier': 'Gold'},
);

final hasAccess = response.data['hasAccess'] as bool;
if (hasAccess) {
  // Show premium features
}
```

### 🟢 GOOD PRACTICES (Already Doing)

1. ✅ Storing subscriptions in `user_subscriptions` table
2. ✅ Using Edge Functions for Apple receipt verification
3. ✅ Database triggers to sync profile
4. ✅ Server-side expiry validation in Edge Functions

---

## Implementation Priority

### Phase 1: IMMEDIATE (Before App Store Submission)
- [ ] Schedule `expire_old_subscriptions()` cron job
- [ ] Add RLS policies for premium events/features
- [ ] Test subscription expiry with backend validation

### Phase 2: SHORT TERM (Next 2 Weeks)
- [ ] Create `check-premium-access` Edge Function
- [ ] Update booking flow to verify tier server-side
- [ ] Update concierge requests to verify tier server-side
- [ ] Add server-side validation for discounts

### Phase 3: LONG TERM (Post-Launch)
- [ ] Add subscription event logging
- [ ] Create admin dashboard for subscription monitoring
- [ ] Implement subscription fraud detection
- [ ] Add webhook for Apple subscription notifications

---

## Testing Strategy

### Test 1: Time Manipulation
1. Subscribe to 7-day plan
2. Wait 7 days for expiry
3. Change device time backward by 1 month
4. Try to access premium features
5. **Expected:** Access denied (if backend checks in place)
6. **Current:** Access granted (vulnerable)

### Test 2: Expired Subscription
1. Create test subscription with `end_date` in the past
2. Run `expire_old_subscriptions()` function
3. Check `user_subscriptions.status` should be 'expired'
4. Check `profiles.is_subscribed` should be false
5. Try to access premium features
6. **Expected:** Access denied

### Test 3: Backend Validation
1. Subscribe to Gold tier
2. Try to access Platinum feature
3. **Expected:** Backend returns `hasAccess: false`

---

## Current State Summary

| Component | Security Level | Notes |
|-----------|---------------|-------|
| Apple Receipt Verification | 🟢 SECURE | Uses Apple's servers |
| Edge Function Expiry Check | 🟢 SECURE | Uses server time |
| Database Triggers | 🟡 MEDIUM | Need cron job scheduled |
| App Subscription Provider | 🔴 VULNERABLE | Uses client time |
| Subscription Sync Service | 🔴 VULNERABLE | Uses client time |
| Premium Feature Gates | ❓ UNKNOWN | Need to audit each feature |

---

## Answer to Your Question

**Q: "are we doing it from backend or app codebase cause backend check is more reliable"**

**A:** Currently doing **BOTH**, but:

1. **Backend checks (Edge Functions)** ✅
   - Secure and reliable
   - Use server time
   - Verify with Apple
   - **BUT:** Not enforced for all premium features

2. **App checks (Providers/Services)** ⚠️
   - Convenient for UI
   - Stream real-time updates
   - **BUT:** Use client time (vulnerable to manipulation)
   - **BUT:** Should only be used for UI, not access control

**Recommendation:**
- ✅ **Keep backend checks** for access control
- ✅ **Use app checks** only for UI display
- 🔴 **Add RLS policies** to enforce backend validation
- 🔴 **Schedule cron job** for auto-expiry
- 🔴 **Audit all premium features** to ensure backend validation

---

**Priority:** MEDIUM-HIGH
**Before App Store Submission:** Schedule cron job, add RLS for premium features
**After Launch:** Add `check-premium-access` Edge Function, audit all features

---

**Generated:** June 9, 2026
**Reviewed by:** Claude Code
**Status:** Ready for Implementation
