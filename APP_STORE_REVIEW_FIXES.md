# App Store Review Issues - Action Plan

**Submission ID:** 02bc86f5-1dea-4bb9-afe0-100f795a4377
**Review Date:** April 30, 2026
**Version Reviewed:** 3.0.0 (4)
**Review Device:** iPad Air (5th generation), iPadOS 26.4.2

---

## Issues to Fix

### ❌ Issue 1: Invalid Support URL (Guideline 1.5 - Safety)

**Problem:**
Support URL `https://www.kdrtech.in/` doesn't provide app support information.

**Solution:**
Update Support URL in App Store Connect to point to a valid support page.

**Action Required:**
1. **Option A:** Create support page at `https://www.aplayworld.com/support`
   - Add FAQ section
   - Add contact form/email
   - Add app features documentation

2. **Option B:** Use temporary support page:
   - Create GitHub Pages or simple HTML page
   - Include: Contact email, FAQ, privacy policy link

**Recommended Support Page Content:**
```
A-Play Support

Contact Us:
Email: support@aplayworld.com

FAQs:
Q: How do I create an account?
A: Click "Sign Up" and enter your email and password.

Q: How do I book an event?
A: Browse events, select your event, choose tickets, and complete payment.

Q: How do I reset my password?
A: Click "Forgot Password" on the sign-in screen.

Q: What payment methods are accepted?
A: We accept PayStack payments and Apple In-App Purchases.

Privacy Policy: https://www.aplayworld.com/privacy
Terms of Service: https://www.aplayworld.com/terms
```

**Where to Update:**
- App Store Connect → Your App → App Information → Support URL

---

### ❌ Issue 2: Invalid Demo Account (Guideline 2.1 - Information Needed)

**Problem:**
Demo account credentials don't work:
- Email: godofwar.2rs@gmail.com
- Password: 123456

**Error:** Could be:
1. Account doesn't exist
2. Password is wrong
3. Account was deleted
4. Email verification required

**Solution:**
Create a NEW valid demo account with full access.

**Action Required:**

#### Step 1: Create Demo Account
```sql
-- Run in Supabase SQL Editor or use app sign-up

-- Option 1: Create via Supabase Dashboard
1. Go to Supabase Dashboard → Authentication → Users
2. Click "Add User"
3. Email: applereview@aplayworld.com
4. Password: AppleReview2026!
5. Auto-confirm user: YES
6. Save

-- Option 2: Create via app and SQL
1. Sign up in app: applereview@aplayworld.com / AppleReview2026!
2. Manually verify email in Supabase Dashboard
```

#### Step 2: Give Premium Access
```sql
-- Run in Supabase SQL Editor
-- Replace USER_ID with actual UUID from step 1

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
  auto_renew_enabled
) VALUES (
  'USER_ID_HERE',  -- Get from Supabase Dashboard
  'platinum-yearly',
  'Platinum',
  'active',
  'yearly',
  NOW(),
  NOW() + INTERVAL '1 year',
  'app_store',
  true,  -- Mark as sandbox for demo
  true
)
ON CONFLICT (user_id, plan_id) DO UPDATE
SET status = 'active',
    end_date = NOW() + INTERVAL '1 year';

-- Update profile tier
UPDATE profiles
SET tier = 'Platinum'
WHERE id = 'USER_ID_HERE';
```

#### Step 3: Add Test Bookings (Optional)
```sql
-- Add some sample bookings so reviewers can see booking history
-- This makes the app look more functional
```

#### Step 4: Update App Store Connect
**Where to Update:**
- App Store Connect → Your App → App Review Information → Demo Account
  - Username: applereview@aplayworld.com
  - Password: AppleReview2026!
  - Notes: "Premium account with full access to all features"

---

### ❌ Issue 3: Registration Error on iPad (Guideline 2.1(a) - App Completeness)

**Problem:**
"An error message was displayed when we attempted to register after creating an account."

**Possible Causes:**
1. **Email validation issue** - iPad keyboard behavior
2. **Password validation too strict** - Reviewer's password doesn't meet requirements
3. **Welcome email failure** - Blocking registration
4. **Profile creation failure** - Database trigger error
5. **OAuth redirect issue** - If they tried OAuth
6. **iPad-specific UI issue** - Layout/orientation bug

**Solution:**

#### Fix 1: Make Password Validation More Lenient
Currently requires: 8+ chars + number + special char

**Update:** `lib/features/authentication/presentation/screens/sign_up_screen.dart`
```dart
// Current validation (line 314-323)
if (value.length < 8) {
  return 'Password must be at least 8 characters';
}
final hasNumber = RegExp(r'[0-9]').hasMatch(value);
final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
if (!hasNumber || !hasSpecial) {
  return 'Password must include a number and a special character';
}

// CHANGE TO:
if (value.length < 6) {  // Reduce from 8 to 6
  return 'Password must be at least 6 characters';
}
// Remove special character requirement for easier demo
```

#### Fix 2: Make Welcome Email Non-Blocking
**Update:** `lib/features/authentication/presentation/providers/auth_provider.dart`

Welcome email should NEVER block registration. Already implemented with try-catch, but verify:
```dart
// Line 376-389
try {
  await EmailService().sendWelcomeEmail(...);
} catch (e) {
  debugPrint('Failed to send welcome email: $e');
  // Don't block sign-up - this is correct!
}
```

#### Fix 3: Add Better Error Messages
Show specific error messages instead of generic ones.

#### Fix 4: Test on iPad Simulator
```bash
# Test on iPad Air 5th gen
flutter run -d "iPad Air (5th generation)"

# Test registration flow
1. Open sign-up screen
2. Enter: test@example.com / Test1234!
3. Verify registration completes
4. Check for any error messages
```

---

### ❌ Issue 4: Forced Registration (Guideline 5.1.1(v) - Privacy)

**Problem:**
"The app requires users to register or log in to access features that are not account based."

Apple requires:
- ✅ Guest browsing of events (NO login required)
- ✅ Guest viewing of event details (NO login required)
- ❌ Login required for: Add to cart, checkout, bookings, profile

**Current State:**
Router redirects unauthenticated users to /sign-in for most routes.

**Solution:**
Allow guest access to browse features.

**Already Partially Implemented:**
`lib/config/router.dart` lines 55-73 has guest-allowed routes:
```dart
final guestAllowedRoutes = [
  '/home',
  '/explore',
  '/feed',
  '/podcast',
  '/help-support',
  RegExp(r'^/club-booking/[^/]+$'), // Club details
  RegExp(r'^/restaurant/[^/]+$'),   // Restaurant details
];
```

**Additional Routes to Allow:**
Need to add event details and browsing:
```dart
final guestAllowedRoutes = [
  '/home',
  '/explore',
  '/feed',
  '/podcast',
  '/help-support',
  RegExp(r'^/event/[^/]+$'),        // Event details ← ADD THIS
  RegExp(r'^/events$'),              // Events list ← ADD THIS
  RegExp(r'^/club-booking/[^/]+$'),
  RegExp(r'^/restaurant/[^/]+$'),
];
```

**Also Need:**
1. Show "Sign In to Book" button on event details when not logged in
2. Show "Continue as Guest" button prominently on sign-in screen ✅ (Already done)
3. Allow navigation throughout app without forced login

---

### ✅ Issue 5: Update Build Version to 0.2.0

**Current Version:** 3.0.0+1
**Target Version:** 0.2.0+5

**Why 0.2.0?**
- Indicates beta/pre-release status
- Shows this is second iteration
- Build number 5 (increment from 4)

**Action Required:**
Update `pubspec.yaml` line 19:
```yaml
# Change from:
version: 3.0.0+1

# Change to:
version: 0.2.0+5
```

**Note:** Build number must be higher than last submission (4), so use 5.

---

## Complete Fix Checklist

### Code Changes:

- [ ] **1. Update pubspec.yaml version** → `0.2.0+5`
- [ ] **2. Reduce password requirement** → 6 chars (optional number/special)
- [ ] **3. Add guest routes** → Event details + events list
- [ ] **4. Test registration on iPad** → Verify no errors
- [ ] **5. Add "Sign In to Book" button** → Event details page

### App Store Connect Changes:

- [ ] **6. Update Support URL** → `https://www.aplayworld.com/support` or temp page
- [ ] **7. Create demo account** → applereview@aplayworld.com
- [ ] **8. Give demo premium access** → SQL insert
- [ ] **9. Update demo credentials** → App Store Connect
- [ ] **10. Add review notes** → Explain features

### Testing:

- [ ] **11. Test sign-up on iPad** → Simulator + real device
- [ ] **12. Test guest browsing** → Events, clubs, restaurants
- [ ] **13. Test demo account** → Login + booking
- [ ] **14. Test all features** → End-to-end
- [ ] **15. Build iOS release** → Archive + upload

---

## Priority Order

### CRITICAL (Must Fix):
1. ✅ Update build version (0.2.0+5)
2. ✅ Add guest browsing routes
3. ✅ Create valid demo account
4. ✅ Update Support URL

### HIGH (Should Fix):
5. Test registration on iPad
6. Reduce password requirements
7. Add "Sign In to Book" prompts

### MEDIUM (Nice to Have):
8. Better error messages
9. More sample data for demo account
10. Support page with FAQ

---

## Implementation Steps

### Step 1: Code Changes (30 min)
```bash
# 1. Update version
# Edit pubspec.yaml line 19

# 2. Add guest routes
# Edit lib/config/router.dart

# 3. Reduce password requirement (optional)
# Edit lib/features/authentication/presentation/screens/sign_up_screen.dart

# 4. Test
flutter run -d "iPad Air (5th generation)"
```

### Step 2: Create Demo Account (10 min)
```sql
-- Supabase SQL Editor
-- See Issue 2 above for SQL
```

### Step 3: App Store Connect Updates (10 min)
```
1. Support URL → New URL
2. Demo Account → New credentials
3. Review Notes → Add helpful info
```

### Step 4: Build & Submit (20 min)
```bash
# Clean build
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Archive → Upload to App Store
```

---

## Review Notes to Include

Add this in App Store Connect → App Review Information → Notes:

```
Thank you for reviewing A-Play.

DEMO ACCOUNT:
- Email: applereview@aplayworld.com
- Password: AppleReview2026!
- Account has Platinum subscription with full access

FEATURES OVERVIEW:
1. Browse events without login (guest mode available)
2. Sign up with email/password
3. Book events with PayStack (test mode)
4. Subscribe via IAP (sandbox mode)
5. Access premium concierge features (demo account has access)

GUEST BROWSING:
- Users can browse events, clubs, and restaurants without login
- Login is only required for booking, subscriptions, and profile features
- "Continue as Guest" option available on sign-in screen

PAYMENT TESTING:
- PayStack: Use test card 4084 0840 8408 4081
- IAP: Sandbox mode, use test account

If you have any questions, please contact support@aplayworld.com

Thank you!
```

---

## Timeline

- **Code changes:** 30 minutes
- **Demo account setup:** 10 minutes
- **App Store Connect:** 10 minutes
- **Build & upload:** 20 minutes
- **Testing:** 30 minutes

**Total:** ~2 hours

---

## Files to Modify

| File | Change | Line |
|------|--------|------|
| `pubspec.yaml` | Update version to 0.2.0+5 | 19 |
| `lib/config/router.dart` | Add guest routes | 55-73 |
| `lib/features/authentication/presentation/screens/sign_up_screen.dart` | Reduce password req (optional) | 314-323 |

---

**Last Updated:** May 30, 2026
**Status:** Ready to implement
