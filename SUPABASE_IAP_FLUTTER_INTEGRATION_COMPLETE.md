# Supabase IAP Flutter Integration - Implementation Complete

This document summarizes the completed integration of Flutter with Supabase IAP backend.

---

## ✅ What Was Implemented

### Part A: Purchase Stream → `verify-apple-sub` Edge Function

**File Modified**: `lib/core/services/purchase_manager.dart`

**Changes Made**:

1. **Added Supabase import**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

2. **Updated `_handleSuccessfulPurchase` to be async**:
   - Now calls backend verification BEFORE completing purchase
   - Ensures subscription is stored in Supabase before UI updates

3. **Added `_verifyPurchaseWithBackend()` method**:
   - Extracts receipt data (base64) from purchase
   - Gets current Supabase user ID
   - Determines sandbox mode (based on build config)
   - Calls `verify-apple-sub` Edge Function with:
     - `receiptData`: Base64 receipt from StoreKit
     - `userId`: Supabase user ID
     - `sandbox`: Boolean flag for environment
   - Validates response (checks `success` and `isSubscribed` fields)
   - Logs detailed success/failure information

4. **Added callback for backend verification success**:
   - New field: `onBackendVerificationSuccess`
   - Called after successful verification
   - Allows app to refresh subscription state

**Flow After Purchase**:
```
User purchases → StoreKit completes → purchaseStream emits PurchaseStatus.purchased
→ _handleSuccessfulPurchase() called
→ _verifyPurchaseWithBackend() called
→ Supabase Edge Function verify-apple-sub invoked
→ Apple validates receipt
→ Subscription stored in Supabase database
→ onBackendVerificationSuccess callback fired
→ onPurchaseSuccess callback fired
→ Purchase completed
```

---

### Part B: Subscription Status Provider → `get-subscription-status` Edge Function

**File Created**: `lib/features/subscription/provider/backend_subscription_provider.dart`

**New Classes**:

1. **`BackendSubscriptionStatus`**:
   - Data model for subscription status from backend
   - Fields: `isSubscribed`, `productId`, `expiry`, `platform`, `status`, `autoRenewEnabled`, `sandbox`
   - Method `isActive`: Checks if subscription is truly active (not just subscribed)
     - Status must be in `['active', 'grace_period']`
     - Expiry must be null or in the future

2. **`backendSubscriptionStatusProvider`** (FutureProvider):
   - THE single source of truth for subscription state
   - Checks if user is logged in (returns not subscribed if no user)
   - Calls `get-subscription-status` Edge Function with user ID
   - Returns `BackendSubscriptionStatus` object
   - On error, returns not subscribed (fail-safe)

3. **`hasPremiumAccessProvider`** (Provider<bool>):
   - Simple boolean: does user have premium?
   - Watches `backendSubscriptionStatusProvider`
   - Returns `status.isActive`
   - UI should primarily use this provider

4. **`SubscriptionStatusRefresher`** (utility class):
   - `refresh(ref)`: Invalidates provider, triggers re-fetch
   - `refreshAndWait(ref)`: Invalidates and waits for completion
   - Used after successful purchase

**Example Usage**:
```dart
// In any widget
final hasPremium = ref.watch(hasPremiumAccessProvider);

if (hasPremium) {
  // Show premium content
} else {
  // Show paywall
}

// After purchase
await SubscriptionStatusRefresher.refreshAndWait(ref);
```

---

### Part C: Updated `SubscriptionUtils` to Use Backend Provider

**File Modified**: `lib/features/subscription/utils/subscription_utils.dart`

**Changes Made**:

1. **Imported backend provider**:
```dart
import '../provider/backend_subscription_provider.dart';
```

2. **Updated `hasPremiumAccess()` method**:
   - **PRIMARY SOURCE**: Backend subscription status from Supabase
   - **FALLBACK**: Profile `is_premium` flag (for manually granted premium)
   - Backend is checked first, profile flag is only used as fallback

3. **Updated `refreshPremiumStatus()` method**:
   - Now calls `SubscriptionStatusRefresher.refresh(ref)`
   - Forces new call to `get-subscription-status` Edge Function

4. **Added `refreshPremiumStatusAndWait()` method**:
   - Async version that waits for refresh to complete
   - Used after successful purchase to ensure UI updates immediately

**Old vs New**:
```dart
// OLD: Used local activeSubscriptionProvider
static bool hasPremiumAccess(WidgetRef ref) {
  if (hasActiveSubscription(ref)) return true;
  return checkProfileFlag(ref);
}

// NEW: Uses backend as source of truth
static bool hasPremiumAccess(WidgetRef ref) {
  // PRIMARY: Backend subscription status
  final backendStatus = ref.watch(backendSubscriptionStatusProvider);
  if (backendStatus.isActive) return true;

  // FALLBACK: Profile flag
  return checkProfileFlag(ref);
}
```

---

### Part D: Wired Purchase Success to Refresh Subscription

**File Modified**: `lib/features/subscription/screens/subscription_plans_screen.dart`

**Changes Made**:

1. **Added import**:
```dart
import '../utils/subscription_utils.dart';
```

2. **Updated purchase success callback** (line ~844):
```dart
// OLD: Just invalidated local providers
ref.invalidate(activeSubscriptionProvider);
ref.invalidate(subscriptionPlansProvider);

// NEW: Refresh backend subscription status and wait
await SubscriptionUtils.refreshPremiumStatusAndWait(ref);
```

**Complete Purchase Flow**:
```
1. User taps Subscribe button
2. StoreKit purchase completes
3. PurchaseManager._verifyPurchaseWithBackend() called
4. Edge Function verify-apple-sub stores subscription in DB
5. onPurchaseSuccess callback fired in subscription_plans_screen.dart
6. SubscriptionUtils.refreshPremiumStatusAndWait(ref) called
7. backendSubscriptionStatusProvider invalidated
8. get-subscription-status Edge Function called
9. Fresh subscription status returned
10. UI updates to show premium features
```

---

## 🔧 Configuration Required

### Environment Variables (Already Created)

Set these in Supabase Dashboard → Edge Functions → Environment Variables:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
APPLE_SHARED_SECRET=your_apple_shared_secret
```

### Build Configuration

For **sandbox mode** (TestFlight/Debug):
```bash
flutter run --dart-define=SANDBOX_MODE=true
```

For **production**:
```bash
flutter build ios --release
# SANDBOX_MODE defaults to false in release builds
```

---

## 📋 Testing Checklist

### Before Testing

- [ ] Edge Functions deployed to Supabase
- [ ] Environment variables set in Supabase
- [ ] SQL migration applied (subscriptions table exists)
- [ ] App built with correct sandbox mode flag

### Test Flow 1: Purchase Flow

1. Launch app (sandbox mode enabled)
2. Navigate to subscription screen
3. Sign in as test user
4. Select a subscription plan
5. Complete Apple purchase
6. **Verify**:
   - Console shows: "PurchaseManager: Starting backend verification..."
   - Console shows: "✅ PurchaseManager: Backend verification SUCCESS"
   - Console shows: "BackendSubscriptionProvider: Fetching subscription status..."
   - Success message appears
   - UI updates to show premium features

### Test Flow 2: App Restart

1. Close and restart app
2. Sign in with same user
3. **Verify**:
   - Console shows: "BackendSubscriptionProvider: Fetching subscription status..."
   - Console shows: "BackendSubscriptionProvider: Response data: {isSubscribed: true...}"
   - App immediately shows premium features (no paywall)

### Test Flow 3: Database Verification

1. Go to Supabase Dashboard → Table Editor
2. Open `subscriptions` table
3. **Verify**:
   - New row exists for user
   - `status` = 'active'
   - `product_id` matches purchased product (SUB7DAY, SUBM, etc.)
   - `expires_at` is in the future
   - `sandbox` = true (for sandbox purchases)

4. Open `subscription_events` table
5. **Verify**:
   - Event logged with `event_type` = 'purchased'

---

## 🔍 Debugging

### Enable Detailed Logging

All key points have debug prints enabled when running in debug mode:

**Purchase Manager**:
```
PurchaseManager: Starting backend verification...
PurchaseManager: User ID: abc-123
PurchaseManager: Sandbox mode: true
PurchaseManager: Calling verify-apple-sub Edge Function...
✅ PurchaseManager: Backend verification SUCCESS
   Product: SUBM
   Expires: 2025-12-31T00:00:00Z
   Status: active
```

**Backend Provider**:
```
BackendSubscriptionProvider: Fetching subscription status from backend...
BackendSubscriptionProvider: User ID: abc-123
BackendSubscriptionProvider: Calling get-subscription-status Edge Function...
BackendSubscriptionProvider: Response status: 200
BackendSubscriptionProvider: Response data: {isSubscribed: true, productId: SUBM, ...}
BackendSubscriptionProvider: BackendSubscriptionStatus(isSubscribed: true, productId: SUBM, ...)
```

### Check Edge Function Logs

```bash
# View verify-apple-sub logs
supabase functions logs verify-apple-sub --tail

# View get-subscription-status logs
supabase functions logs get-subscription-status --tail
```

### Common Issues

**Issue**: "User not authenticated - cannot verify purchase"
- **Cause**: User not signed in to Supabase
- **Fix**: Ensure auth check happens before purchase (already implemented)

**Issue**: "Edge Function returned status 500"
- **Cause**: Environment variables not set or Edge Function error
- **Fix**: Check Supabase Edge Function logs, verify env vars

**Issue**: "Verification failed: invalid_receipt"
- **Cause**: Receipt is invalid or from wrong app
- **Fix**: Verify bundle ID matches, check sandbox mode flag

**Issue**: UI doesn't update after purchase
- **Cause**: Provider not being refreshed
- **Fix**: Check `SubscriptionUtils.refreshPremiumStatusAndWait()` is called

---

## 🎯 Key Architecture Points

### Single Source of Truth

```
Backend Subscription Status (Supabase Database)
        ↓
backendSubscriptionStatusProvider
        ↓
hasPremiumAccessProvider
        ↓
UI (shows/hides premium features)
```

### Purchase Flow

```
StoreKit Purchase
        ↓
PurchaseManager.purchaseStream
        ↓
_verifyPurchaseWithBackend()
        ↓
verify-apple-sub Edge Function
        ↓
Apple Receipt Validation
        ↓
Supabase Database (subscriptions table)
        ↓
onBackendVerificationSuccess callback
        ↓
refreshPremiumStatusAndWait()
        ↓
get-subscription-status Edge Function
        ↓
UI Update
```

### Security

- ✅ Client uses `anon_key` (safe to expose)
- ✅ Edge Functions use `service_role_key` (server-side only)
- ✅ RLS policies prevent direct subscription writes from client
- ✅ All receipts verified server-side with Apple
- ✅ Idempotent upserts prevent duplicate subscriptions

---

## 📝 Summary

**What was implemented**:
1. ✅ Purchase stream calls `verify-apple-sub` after successful purchase
2. ✅ Backend verification stores subscription in Supabase database
3. ✅ New provider fetches subscription status from `get-subscription-status`
4. ✅ UI uses backend provider as single source of truth
5. ✅ Subscription status refreshes after purchase

**What to do next**:
1. Deploy Edge Functions to Supabase
2. Set environment variables in Supabase Dashboard
3. Test with Apple Sandbox
4. Monitor Edge Function logs
5. Submit to App Store when ready

**Files Created**:
- `lib/features/subscription/provider/backend_subscription_provider.dart`
- `SUPABASE_IAP_FLUTTER_INTEGRATION_COMPLETE.md` (this file)

**Files Modified**:
- `lib/core/services/purchase_manager.dart`
- `lib/features/subscription/utils/subscription_utils.dart`
- `lib/features/subscription/screens/subscription_plans_screen.dart`

The integration is **complete and ready for testing**! 🎉
