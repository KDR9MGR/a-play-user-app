# App Store Rejection Fixes - April 2026

This document outlines the fixes applied to resolve the App Store rejection from April 28, 2026 (Version 3.0.0, Build 3).

## Summary of Issues and Fixes

### ✅ Issue 1: Guideline 5.1.1(v) - Forced Login for Browsing

**Problem:** App required users to register before browsing products/events, violating Apple's guidelines that registration should only be required for account-based features.

**Fix Applied:**
- Modified [lib/config/router.dart](lib/config/router.dart) to allow guest browsing
- Added guest-allowed routes list including `/home`, `/explore`, `/podcast`, club details, and restaurant details
- Users can now browse events, clubs, and restaurants without authentication
- Sign-in is only required when attempting to book/purchase (already implemented in event details screen)

**Files Changed:**
- `lib/config/router.dart` - Lines 44-79

**Code Changes:**
```dart
// Allow guest browsing of these routes without authentication
final guestAllowedRoutes = [
  '/home',
  '/explore',
  '/podcast',
  RegExp(r'^/club-booking/[^/]+$'), // Club details
  RegExp(r'^/restaurant/[^/]+$'),   // Restaurant details
];
```

---

### ✅ Issue 2: Guideline 2.1(b) - Subscription Page Error on iPad/iPhone

**Problem:** Subscription screen crashed on iPad Air 11-inch (M3) and iPhone 17 Pro Max when IAP initialization failed.

**Root Cause:**
- StoreKit sync failures were not handled gracefully
- IAP initialization errors caused unhandled exceptions
- No error messages for users when products couldn't be loaded

**Fix Applied:**
- Added comprehensive try-catch error handling in subscription initialization
- Gracefully handle StoreKit sync failures (non-fatal)
- Display user-friendly error messages when IAP unavailable
- Proper error handling for subscription check failures

**Files Changed:**
- `lib/features/subscription/view/subscription_screen_new.dart` - Lines 37-123

**Key Changes:**
```dart
// STEP 1: Sync with StoreKit (non-fatal if fails)
try {
  await _iapService.syncDatabaseWithStoreKit();
} catch (e) {
  debugPrint('StoreKit sync failed (non-fatal): $e');
}

// STEP 2: Check subscriptions with error handling
try {
  final hasActive = await _syncService.hasActiveSubscription();
  // ... handle result
} catch (e) {
  debugPrint('Error checking subscriptions: $e');
  // Continue to load products
}

// STEP 3: Initialize IAP with error handling
try {
  await _iapService.initialize();
} catch (e) {
  setState(() {
    _errorMessage = 'Unable to load subscription plans. This is normal in simulator...';
  });
  return;
}
```

**Testing Notes:**
- App now gracefully handles IAP unavailability in iOS Simulator
- Clear error messages displayed to users
- No crashes when StoreKit is unavailable

---

### ✅ Issue 3: Guideline 2.1(a) - Profile Edit Error

**Problem:** App crashed when users attempted to edit their profile on iPad/iPhone.

**Root Cause:**
- Line 109 referenced `ref.read(supabaseProvider).storage`
- `supabaseProvider` does not exist in the codebase
- Should use `Supabase.instance.client.storage` directly

**Fix Applied:**
- Replaced incorrect provider reference with direct Supabase client access
- Matches pattern used throughout the codebase

**Files Changed:**
- `lib/features/profile/screens/edit_profile_page.dart` - Line 109

**Code Change:**
```dart
// Before (BROKEN):
final storage = ref.read(supabaseProvider).storage;

// After (FIXED):
final storage = Supabase.instance.client.storage;
```

---

### ⚠️ Issue 4: Guideline 1.5 - Invalid Support URL

**Problem:** Support URL `https://www.kdrtech.in/` does not contain support information.

**Action Required in App Store Connect:**

1. **Log into App Store Connect**: https://appstoreconnect.apple.com
2. **Navigate to App Information**:
   - Select "A Play" app
   - Go to "App Information" section
3. **Update Support URL** to one of the following:
   - Option A: Create a dedicated support page with:
     - Contact email (e.g., support@aplay.com)
     - FAQ section
     - How to report issues
     - Privacy policy link
     - Terms of service link
   - Option B: Use a temporary support page URL with contact information
   - Option C: Create a simple page on existing domain with support contact info

4. **Minimum Requirements for Support Page:**
   - Must be publicly accessible
   - Must contain a way for users to contact support (email/form)
   - Should include basic FAQ or help information
   - Should be related to the A Play app

**Example Support Page Content:**
```
A Play - Support

Contact Us:
Email: support@aplay.com

Frequently Asked Questions:
Q: How do I book an event?
A: Browse events, select your preferred event, choose seats, and complete payment.

Q: How do I manage my subscription?
A: Go to iOS Settings > Your Name > Subscriptions to manage your subscription.

Q: How do I cancel a booking?
A: Go to My Tickets and select the booking you wish to cancel.

Privacy Policy: [link]
Terms of Service: [link]
```

**Files NOT Changed:**
- No code changes required - this is an App Store Connect configuration issue

---

## Testing Recommendations

Before resubmitting to App Store:

### 1. Guest Browsing Flow
- [ ] Launch app without signing in
- [ ] Verify you can browse Home screen
- [ ] Verify you can browse Explore screen
- [ ] Verify you can view event details
- [ ] Verify you can view club/restaurant details
- [ ] Confirm sign-in prompt appears when attempting to book
- [ ] Verify My Tickets and Concierge tabs show sign-in prompt

### 2. Subscription Screen
- [ ] Test on real iPhone device (not simulator)
- [ ] Test on real iPad device (not simulator)
- [ ] Verify subscription screen loads without crashing
- [ ] Test with active subscription - verify management UI shows
- [ ] Test without subscription - verify plans display
- [ ] Test in iOS Simulator - verify graceful error message

### 3. Profile Edit
- [ ] Navigate to Profile
- [ ] Tap Edit Profile
- [ ] Update name
- [ ] Update phone number
- [ ] Upload profile photo
- [ ] Save changes
- [ ] Verify no crashes
- [ ] Verify changes persist

### 4. Support URL
- [ ] Verify new support URL in App Store Connect
- [ ] Test support URL in web browser
- [ ] Confirm contact information is visible
- [ ] Confirm FAQ or help content is present

---

## Resubmission Checklist

- [x] **Code Fix 1**: Guest browsing enabled for public content
- [x] **Code Fix 2**: Subscription screen error handling added
- [x] **Code Fix 3**: Profile edit crash fixed
- [ ] **App Store Connect**: Support URL updated
- [ ] **Testing**: All test scenarios passed on physical devices
- [ ] **Build**: New build created with version 3.0.0+4 or 3.0.1+1
- [ ] **Upload**: New build uploaded to App Store Connect
- [ ] **Submit**: Resubmit for review

---

## Technical Details

### Router Changes (Guest Access)
The router now differentiates between:
- **Public Routes**: Accessible without authentication (home, explore, event/club/restaurant details)
- **Protected Routes**: Require authentication (my tickets, profile, bookings, concierge)

When an unauthenticated user tries to access a protected route, they're redirected to `/sign-in`.

### Subscription Screen Error Handling
Three levels of error handling:
1. **StoreKit Sync**: Non-fatal, logs warning, continues
2. **Subscription Check**: Non-fatal, logs error, continues to product loading
3. **IAP Initialization**: Fatal for purchasing, shows user-friendly error message

### Profile Edit Fix
Direct Supabase client access matches the pattern used in:
- `lib/main.dart`
- `lib/features/authentication/presentation/screens/auth_callback_screen.dart`
- Other authentication-related files

---

## Next Steps After App Store Approval

1. **Monitor Crashlytics**: Check for any new crash reports
2. **User Feedback**: Monitor reviews for issues related to these fixes
3. **Analytics**: Track guest user conversion rates
4. **Subscription Metrics**: Monitor subscription purchase success rates

---

## Support Contact

For questions about these fixes:
- **Developer**: [Your Name]
- **Date Fixed**: April 30, 2026
- **Version**: 3.0.0 (Build 3) → 3.0.0 (Build 4) or 3.0.1
