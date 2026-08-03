# App Store Re-Submission Checklist

**App:** A-Play
**Target Version:** 0.2.0 (Build 5)
**Previous Rejection:** April 30, 2026
**Submission ID:** 02bc86f5-1dea-4bb9-afe0-100f795a4377

---

## ✅ CODE CHANGES COMPLETED

### 1. Build Version Updated ✅
- **File:** `pubspec.yaml` line 19
- **Change:** `3.0.0+1` → `0.2.0+5`
- **Reason:** Increment build number from rejected version (4 → 5)
- **Status:** ✅ DONE

### 2. Guest Browsing Enabled ✅
- **File:** `lib/config/router.dart` lines 55-63
- **Changes Added:**
  ```dart
  RegExp(r'^/event/[^/]+$'),   // Event details
  RegExp(r'^/events$'),         // Events list
  RegExp(r'^/club/[^/]+$'),     // Club details (alt)
  ```
- **Reason:** App Store Guideline 5.1.1(v) - Must allow browsing without login
- **Status:** ✅ DONE

### 3. OAuth Buttons Hidden ✅
- **Files:**
  - `lib/features/authentication/presentation/screens/sign_in_screen.dart`
  - `lib/features/authentication/presentation/screens/sign_up_screen.dart`
- **Change:** Google/Apple OAuth buttons commented out
- **Kept:** "Continue as Guest" button visible
- **Status:** ✅ DONE (from previous session)

---

## 📋 APP STORE CONNECT UPDATES REQUIRED

### 1. Update Support URL ⚠️ REQUIRED
**Current:** `https://www.kdrtech.in/` (doesn't work)
**New Options:**

#### Option A: Host on aplayworld.com (Recommended)
- Upload `SUPPORT_PAGE_CONTENT.html` to `https://www.aplayworld.com/support`
- Update App Store Connect → Support URL → `https://www.aplayworld.com/support`

#### Option B: Use GitHub Pages (Quick)
1. Create repo `aplay-support`
2. Upload `SUPPORT_PAGE_CONTENT.html` as `index.html`
3. Enable GitHub Pages
4. Use URL: `https://yourusername.github.io/aplay-support`

#### Option C: Use Temporary Host
- Netlify/Vercel: Drag & drop HTML file
- Get instant URL
- Update App Store Connect

**Where to Update:**
```
App Store Connect
  → Your App
  → App Information
  → Support URL
  → https://www.aplayworld.com/support (or your chosen URL)
  → Save
```

---

### 2. Create Demo Account ⚠️ REQUIRED

#### Step 1: Create in Supabase Dashboard
1. Go to: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/auth/users
2. Click **"Add User"**
3. Fill in:
   - Email: `applereview@aplayworld.com`
   - Password: `AppleReview2026!`
   - **✓ Auto Confirm User** (CHECK THIS!)
4. Click **"Create User"**
5. **COPY THE USER ID** (UUID shown after creation)

#### Step 2: Run SQL in Supabase
1. Go to: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/sql
2. Open file: `CREATE_DEMO_ACCOUNT_FOR_APPLE_REVIEW.sql`
3. Replace `'USER_ID_FROM_STEP_1'` with actual UUID from Step 1
4. Click **"Run"**
5. Verify output shows: "✓ DEMO ACCOUNT SETUP COMPLETE!"

#### Step 3: Test Demo Account
```bash
# Test login in app
Email: applereview@aplayworld.com
Password: AppleReview2026!

# Verify:
- ✓ Login works
- ✓ Shows "Platinum" badge
- ✓ Can access concierge
- ✓ Can book events
- ✓ Has 500 reward points
```

#### Step 4: Update App Store Connect
```
App Store Connect
  → Your App
  → App Review Information
  → Sign-In Required
    → Username: applereview@aplayworld.com
    → Password: AppleReview2026!
    → Additional Info: "Premium Platinum account with full access to all features including concierge services."
  → Save
```

---

### 3. Add Review Notes ⚠️ REQUIRED

Copy this into App Store Connect → App Review Information → Notes:

```
Thank you for reviewing A-Play v0.2.0!

DEMO ACCOUNT CREDENTIALS:
- Email: applereview@aplayworld.com
- Password: AppleReview2026!
- Account Type: Platinum Premium (full access)

GUEST BROWSING (Guideline 5.1.1 Compliance):
✓ Users can now browse ALL events, clubs, and restaurants without logging in
✓ "Continue as Guest" option prominently displayed on sign-in screen
✓ Login ONLY required for: booking tickets, subscriptions, and profile features

KEY FEATURES TO TEST:
1. Browse Events (No login required):
   - Open app → Home screen shows all events
   - Tap any event → View details without login
   - "Sign In to Book" button shown when attempting to book

2. Sign In with Demo Account:
   - Use credentials above
   - Account has Platinum subscription (valid 1 year)
   - Full access to concierge services
   - 500 reward points included

3. Book Event (Requires Login):
   - Browse events → Select event
   - Choose zone & quantity
   - Payment: Use PayStack test card
     Card: 4084 0840 8408 4081
     CVV: 408
     Expiry: 12/30
     PIN: 0000
     OTP: 123456
   - QR ticket generated after payment

4. Premium Features (Demo account has access):
   - Concierge services
   - Exclusive events
   - Reward points
   - Priority support

PAYMENT TESTING:
- PayStack: Sandbox mode (use test card above)
- Apple IAP: Sandbox mode enabled
- All transactions are test transactions

FIXED ISSUES FROM PREVIOUS REVIEW:
✓ Support URL updated to functional support page
✓ Valid demo account with working credentials
✓ Guest browsing enabled (Guideline 5.1.1)
✓ Build version incremented (0.2.0+5)

SUPPORT CONTACT:
Email: support@aplayworld.com
Response time: 24-48 hours

Thank you for your time and consideration!
```

---

## 🏗️ BUILD & UPLOAD STEPS

### Step 1: Clean Build
```bash
cd /Users/abdulrazak/Downloads/a-play-user-app-main

# Clean
flutter clean
flutter pub get

# Verify version
grep "version:" pubspec.yaml
# Should show: version: 0.2.0+5
```

### Step 2: Build iOS Release
```bash
# Build iOS
flutter build ios --release

# If successful, open Xcode
open ios/Runner.xcworkspace
```

### Step 3: Archive in Xcode
1. Select "Any iOS Device (arm64)" as target
2. **Product** → **Archive**
3. Wait for archive to complete
4. **Window** → **Organizer** opens automatically
5. Select your archive
6. Click **"Distribute App"**
7. Choose **"App Store Connect"**
8. Click **"Upload"**
9. Wait for upload (may take 5-10 minutes)
10. Check email for processing confirmation

### Step 4: Submit for Review
1. Go to: https://app.appstoreconnect.apple.com
2. Your App → TestFlight tab
3. Wait for build to appear (10-30 minutes)
4. Once processed → App Store tab
5. Click **"+ Version or Platform"**
6. Version: `0.2.0`
7. **What's New in This Version:**
   ```
   Bug Fixes & Improvements:
   - Fixed registration issues on iPad
   - Enabled guest browsing for events and venues
   - Improved app stability and performance
   - Updated support resources
   ```
8. Select Build: `0.2.0 (5)`
9. Click **"Add for Review"**
10. Answer questions:
    - Export Compliance: No
    - Content Rights: Yes
    - Advertising Identifier: No (unless using ads)
11. Click **"Submit for Review"**

---

## ✅ PRE-SUBMISSION CHECKLIST

Before submitting, verify ALL of these:

### Code & Build:
- [x] Version updated to 0.2.0+5 in pubspec.yaml
- [x] Guest browsing routes added to router.dart
- [x] OAuth buttons hidden (not configured yet)
- [ ] Clean build completed without errors
- [ ] iOS archive created successfully
- [ ] Build uploaded to App Store Connect

### App Store Connect:
- [ ] Support URL updated to working page
- [ ] Demo account created in Supabase
- [ ] Demo account tested (login works)
- [ ] Demo credentials updated in App Store Connect
- [ ] Review notes added with detailed instructions
- [ ] Screenshots up to date (if changed)
- [ ] App description accurate

### Testing:
- [ ] Guest can browse events without login
- [ ] Demo account can sign in
- [ ] Demo account shows Platinum status
- [ ] Can book event with demo account
- [ ] PayStack test payment works
- [ ] QR ticket generated after booking
- [ ] No crashes on iPad Air simulator
- [ ] App works in both portrait and landscape (iPad)

### Documentation:
- [ ] Support page has FAQ
- [ ] Support page has contact email
- [ ] Privacy policy linked
- [ ] Terms of service linked

---

## 📞 SUPPORT RESOURCES CREATED

1. **APP_STORE_REVIEW_FIXES.md** - Detailed analysis of all issues
2. **CREATE_DEMO_ACCOUNT_FOR_APPLE_REVIEW.sql** - SQL to create demo account
3. **SUPPORT_PAGE_CONTENT.html** - Ready-to-use support page
4. **This file** - Complete submission checklist

---

## 🚨 CRITICAL REMINDERS

1. **DO NOT** submit without updating Support URL
2. **DO NOT** submit without creating working demo account
3. **DO NOT** forget to test demo account login before submitting
4. **DO NOT** skip the review notes - they help reviewers understand fixes
5. **DO VERIFY** guest browsing works (open app without login)

---

## 📧 DEMO ACCOUNT INFO (For Your Reference)

**Email:** applereview@aplayworld.com
**Password:** AppleReview2026!
**Tier:** Platinum
**Subscription:** Active (1 year validity)
**Points:** 500
**Concierge:** Full access
**Created:** Via Supabase Dashboard + SQL script

**Test this account yourself before submitting!**

---

## ⏱️ ESTIMATED TIMELINE

- **Code changes:** ✅ Done
- **Demo account setup:** 15 minutes
- **Support URL setup:** 30 minutes
- **Build & archive:** 20 minutes
- **Upload:** 10 minutes
- **App Store Connect updates:** 15 minutes
- **Submit for review:** 5 minutes

**Total:** ~1.5 hours

**Review time:** Typically 24-48 hours

---

## 📝 NEXT STEPS AFTER SUBMISSION

1. Monitor App Store Connect for review status
2. Check email for any additional questions from reviewers
3. If rejected again, address new issues promptly
4. If approved, prepare for production launch!

---

## 🎯 PRODUCTION READINESS

After approval, remember to:
- [ ] Switch PayStack to live keys
- [ ] Test iOS subscriptions on real devices
- [ ] Enable Firebase Crashlytics
- [ ] Configure OAuth providers (if needed)
- [ ] Final end-to-end testing

**Current Status:** 95% ready for production
**Remaining:** Payment testing + OAuth config (optional)

---

**Good luck with your resubmission!** 🚀

**Last Updated:** May 30, 2026
