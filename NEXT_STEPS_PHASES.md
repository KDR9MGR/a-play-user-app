# A-Play MVP - Next Steps (Detailed Phases)

**Date:** March 31, 2026
**Current Status:** Code Complete, Ready for Configuration & Testing
**Target:** Production Launch Q2 2026

---

## ✅ VERIFICATION: Non-MVP Features Hidden

### Hidden Features Status

| Feature | Home Screen | My Tickets | Profile | Router | Status |
|---------|-------------|------------|---------|--------|--------|
| **Restaurants** | ✅ Hidden | ✅ Tab Hidden | N/A | ✅ Coming Soon | **COMPLETE** |
| **Clubs** | ✅ Hidden | N/A | N/A | ✅ Coming Soon | **COMPLETE** |
| **Lounges** | ✅ Hidden | N/A | N/A | N/A | **COMPLETE** |
| **Pubs** | ✅ Hidden | N/A | N/A | N/A | **COMPLETE** |
| **Arcades** | ✅ Hidden | N/A | N/A | N/A | **COMPLETE** |
| **Beaches** | ✅ Hidden | N/A | N/A | N/A | **COMPLETE** |
| **Podcasts** | N/A | N/A | N/A | ✅ Coming Soon | **COMPLETE** |
| **Referrals** | N/A | N/A | ✅ Hidden | N/A | **COMPLETE** |

### Feature Flags Implementation ✅

```dart
// /lib/config/feature_flags.dart
enableEventBookings: true    ✅ MVP
enableSubscriptions: true    ✅ MVP
enableChat: true            ✅ MVP
enableFeed: true            ✅ MVP
enableConcierge: true       ✅ MVP (Premium only)

enableRestaurants: false    ❌ Hidden
enableClubs: false         ❌ Hidden
enablePodcasts: false      ❌ Hidden
enableReferrals: false     ❌ Hidden
```

### Visual Verification Checklist

When you run the app, you should see:

**Home Screen:**
- ✅ Search bar
- ✅ Featured events carousel
- ✅ Time filters (Today, Tomorrow, This Week)
- ✅ Filtered events section
- ✅ Live Shows section
- ❌ No Clubs section
- ❌ No Lounges section
- ❌ No Pubs section
- ❌ No Restaurants section
- ❌ No Arcade Centers
- ❌ No Beaches

**My Tickets:**
- ✅ Events tab only
- ❌ No Restaurants tab

**Profile:**
- ✅ Edit Profile
- ✅ Privacy Policy
- ✅ Legal & Policies
- ❌ No "Points & Referrals"

**Navigation:**
- Navigate to `/podcast` → Shows "Coming Soon" screen ✅
- Navigate to `/restaurant/:id` → Shows "Coming Soon" screen ✅
- Navigate to `/club-booking` → Shows "Coming Soon" screen ✅

---

## 📋 PHASE 1: Install Dependencies & Initial Setup (30 mins)

### Prerequisites
- Windows Terminal (PowerShell or CMD)
- Flutter installed on Windows
- iOS/Android device or simulator

### Step 1.1: Install Updated Dependencies

**Open Windows Terminal** (NOT WSL):

```bash
# Navigate to project
cd E:\path\to\a-play-user-app-main

# Install new packages (StoreKit fix + existing packages)
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in a-play-user-app-main...
Resolving dependencies...
+ in_app_purchase 3.2.0
+ in_app_purchase_storekit 0.4.8+1
Got dependencies!
```

### Step 1.2: Clean Build Cache

```bash
# Clean Flutter build artifacts
flutter clean

# For iOS specifically (if testing on iOS)
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
pod install --repo-update
cd ..
```

### Step 1.3: Verify Code Generation

```bash
# Regenerate Freezed models
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Expected:** Should complete without errors (~30-60 seconds)

### Step 1.4: Check for Errors

```bash
# Run analyzer
flutter analyze

# Expected: ~196 non-blocking issues (acceptable for MVP)
```

---

## 📋 PHASE 2: Configure External Services (1-2 hours)

### Step 2.1: Create OneSignal Account (30 mins)

**Actions:**

1. **Sign Up**
   - Go to: https://onesignal.com
   - Click "Get Started Free"
   - Sign up with email or GitHub

2. **Create App**
   - Click "New App/Website"
   - Name: **"A-Play"**
   - Select platform: **Flutter**

3. **Get App ID**
   - After creation, copy your **App ID**
   - Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - **Save this** - you'll need it for `.env`

4. **Configure iOS (APNs)**

   a. **Generate Apple Push Notification Key**
   - Go to: https://developer.apple.com/account
   - Navigate to: **Certificates, Identifiers & Profiles** → **Keys**
   - Click **+** to create new key
   - Name: **"A-Play APNs Key"**
   - Enable: **Apple Push Notifications service (APNs)**
   - Click **Continue** → **Register**
   - **Download** the `.p8` file (ONE TIME ONLY!)
   - Note your **Key ID** (10 characters)
   - Note your **Team ID** (in account settings)

   b. **Upload to OneSignal**
   - In OneSignal Dashboard → **Settings** → **Platforms**
   - Select **Apple iOS (APNs)**
   - Choose **".p8 Auth Key"**
   - Enter:
     - **Team ID**: Your Apple Developer Team ID
     - **Key ID**: The 10-character key ID
     - **Bundle ID**: `com.yourcompany.aplay`
     - **p8 File**: Upload the downloaded `.p8` file
   - Click **Save**

5. **Configure Android (FCM)**

   a. **Firebase Setup**
   - Go to: https://console.firebase.google.com
   - Select your existing **a-play** project
   - Click **Project Settings** (gear icon)
   - Navigate to **Cloud Messaging** tab
   - Under **Cloud Messaging API (V1)**, click **Manage Service Accounts**
   - Click **Create Service Account**
   - Download **JSON key**

   b. **Upload to OneSignal**
   - In OneSignal Dashboard → **Settings** → **Platforms**
   - Select **Google Android (FCM)**
   - Upload the Firebase **service account JSON** file
   - Click **Save**

**Completion Checklist:**
- [ ] OneSignal account created
- [ ] App created in OneSignal
- [ ] App ID copied and saved
- [ ] iOS APNs configured (.p8 uploaded)
- [ ] Android FCM configured (JSON uploaded)
- [ ] Both platforms show "Configured" in OneSignal dashboard

---

### Step 2.2: Create Resend Account (20 mins)

**Actions:**

1. **Sign Up**
   - Go to: https://resend.com
   - Sign up with GitHub or email
   - Verify your email

2. **Add Domain (For Production)**

   **Option A: Custom Domain** (Recommended for production)
   - Click **Domains** → **Add Domain**
   - Enter: `yourdomain.com` (your actual domain)
   - Copy the DNS records provided:

   ```
   Type: TXT
   Name: resend._domainkey
   Value: [provided by Resend]

   Type: TXT
   Name: @
   Value: v=spf1 include:_spf.resend.com ~all

   Type: MX
   Name: @
   Priority: 10
   Value: feedback-smtp.resend.com
   ```

   - Add these to your domain DNS (Namecheap, GoDaddy, Cloudflare, etc.)
   - Wait for verification (can take up to 48 hours)

   **Option B: Sandbox** (For testing only)
   - Use: `onboarding@resend.dev`
   - Can only send to YOUR verified email address
   - Good for development/testing

3. **Generate API Key**
   - Click **API Keys** → **Create API Key**
   - Name: **"A-Play Production"**
   - Permissions: **Full Access** (or Send emails)
   - Copy the API key (starts with `re_...`)
   - **SAVE IT SECURELY** - you can't view it again!

4. **Test Email** (Optional but recommended)
   - Click **Test** in Resend dashboard
   - Send a test email to your email
   - Verify it arrives

**Completion Checklist:**
- [ ] Resend account created
- [ ] Domain added (or using sandbox)
- [ ] API key generated and saved
- [ ] Test email sent successfully (optional)
- [ ] DNS records added (if using custom domain)

---

### Step 2.3: Update Environment Variables (10 mins)

**Create `.env` file** in project root:

```bash
# Navigate to project root
cd E:\path\to\a-play-user-app-main

# Create .env file (use notepad or VS Code)
notepad .env
```

**Add the following:**

```env
# ===========================================
# SUPABASE (Existing)
# ===========================================
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here

# ===========================================
# PAYSTACK (Existing)
# ===========================================
PAYSTACK_PUBLIC_KEY=pk_test_xxxxxxxxxxxxx

# ===========================================
# ONESIGNAL (NEW)
# ===========================================
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# ===========================================
# RESEND EMAIL SERVICE (NEW)
# ===========================================
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxx

# For production (custom domain):
RESEND_FROM_EMAIL=A-Play <noreply@yourdomain.com>

# For testing (sandbox):
# RESEND_FROM_EMAIL=A-Play <onboarding@resend.dev>
```

**Save the file** (Ctrl+S in Notepad)

**Verify .gitignore** contains `.env`:

```bash
# Check if .env is ignored
type .gitignore | findstr ".env"
```

If not found, add this line to `.gitignore`:
```
.env
```

**Completion Checklist:**
- [ ] `.env` file created in project root
- [ ] All environment variables added
- [ ] ONESIGNAL_APP_ID from Step 2.1
- [ ] RESEND_API_KEY from Step 2.2
- [ ] RESEND_FROM_EMAIL configured
- [ ] `.env` file NOT committed to git

---

## 📋 PHASE 3: Integrate Services into App (30 mins)

### Step 3.1: Add flutter_dotenv Package

**Update `pubspec.yaml`:**

```yaml
dependencies:
  # ... existing dependencies
  flutter_dotenv: ^5.1.0
```

Then run:
```bash
flutter pub get
```

**Update `pubspec.yaml` assets:**

```yaml
flutter:
  assets:
    - .env  # Add this line
    - assets/icons/
    - assets/images/
    # ... rest of assets
```

---

### Step 3.2: Update main.dart

**File:** `/lib/main.dart`

Find your existing `main()` function and update it:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NEW: Load environment variables
  await dotenv.load(fileName: ".env");

  // Existing: Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // NEW: Initialize OneSignal
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    await NotificationService().initialize(appId: oneSignalAppId);
    debugPrint('✅ OneSignal initialized');
  } else {
    debugPrint('⚠️ OneSignal App ID not found in .env');
  }

  // Existing: Run app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

### Step 3.3: Update Auth Provider (Sign In/Out)

**File:** `/lib/features/authentication/presentation/providers/auth_provider.dart`

**Add imports:**
```dart
import 'package:a_play/core/services/notification_service.dart';
import 'package:a_play/core/services/email_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
```

**Find your sign-in success handler** and add:

```dart
// After successful sign in
Future<void> _onSignInSuccess(String userId, String email) async {
  // Set OneSignal external user ID
  await NotificationService().setExternalUserId(userId);

  // Get user profile (if available)
  final profile = await _getUserProfile(userId);

  // Update OneSignal tags for segmentation
  await NotificationService().updateUserPreferences(
    userId: userId,
    subscriptionTier: profile?.subscriptionTier ?? 'free',
    location: profile?.city,
  );

  debugPrint('✅ OneSignal user configured: $userId');
}
```

**Find your sign-up success handler** and add:

```dart
// After successful sign up
Future<void> _onSignUpSuccess(String userId, String email, String name) async {
  // Existing code...

  // NEW: Send welcome email
  final emailService = EmailService();
  final sent = await emailService.sendWelcomeEmail(
    toEmail: email,
    userName: name,
  );

  if (sent) {
    debugPrint('✅ Welcome email sent to $email');
  } else {
    debugPrint('⚠️ Failed to send welcome email');
  }

  // Set OneSignal user
  await NotificationService().setExternalUserId(userId);
}
```

**Find your sign-out handler** and add:

```dart
Future<void> signOut() async {
  // NEW: Remove OneSignal external user ID
  await NotificationService().removeExternalUserId();

  // Existing: Supabase sign out
  await Supabase.instance.client.auth.signOut();

  debugPrint('✅ User signed out');
}
```

---

### Step 3.4: Update Password Reset Flow

**File:** `/lib/features/authentication/presentation/screens/password_reset_screen.dart`

**Add import:**
```dart
import 'package:a_play/core/services/email_service.dart';
```

**Find your password reset method** and update:

```dart
Future<void> _sendPasswordReset(String email) async {
  try {
    // Generate Supabase reset link
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://yourapp.com/reset-password',
    );

    // NEW: Send custom email via Resend
    final emailService = EmailService();
    await emailService.sendPasswordResetEmail(
      toEmail: email,
      resetLink: 'Generated from Supabase',
      userName: 'User', // Get from database if available
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to $email')),
    );
  } catch (e) {
    // Handle error
    debugPrint('Error sending password reset: $e');
  }
}
```

---

## 📋 PHASE 4: iOS Build Fix & Testing (1-2 hours)

### Step 4.1: Clean iOS Build (30 mins)

**Run these commands in Windows Terminal:**

```bash
# Navigate to project
cd E:\path\to\a-play-user-app-main

# Clean Flutter cache
flutter clean

# Navigate to iOS folder
cd ios

# Remove old pods
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks

# Reinstall with updated packages
pod install --repo-update

# Go back to root
cd ..
```

**Expected Output:**
```
Analyzing dependencies
Downloading dependencies
Installing in_app_purchase_storekit (0.4.8)
...
Pod installation complete! X pods installed.
```

---

### Step 4.2: Update iOS Info.plist

**File:** `/ios/Runner/Info.plist`

Add these entries (before `</dict></plist>`):

```xml
<!-- OneSignal Push Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Notification Permission Description -->
<key>NSUserNotificationsUsageDescription</key>
<string>We'll send you booking confirmations, event reminders, and important updates about your reservations.</string>
```

---

### Step 4.3: Build iOS (Test)

```bash
# Build for iOS
flutter build ios --release

# OR run on simulator
flutter run -d iPhone

# OR run on physical device
flutter run -d <device-id>
```

**Expected:**
- ✅ Build succeeds without StoreKit errors
- ✅ No deprecation warnings
- ✅ App installs on device/simulator

**If build fails:**
- Check `/PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md` → "Troubleshooting" section
- Verify Xcode version is 15.0+
- Check Bundle ID matches in Xcode project

---

### Step 4.4: Test Subscription Purchase (iOS)

1. **Enable Sandbox Testing**
   - Sign in to App Store Connect
   - Go to **Users and Access** → **Sandbox Testers**
   - Create a test account

2. **Test Flow**
   - Launch app on iOS device/simulator
   - Navigate to **Subscription Plans**
   - Select a tier (Bronze, Silver, Gold, Platinum)
   - Complete purchase with sandbox account
   - Verify receipt validation

3. **Verify**
   - [ ] Purchase dialog appears
   - [ ] Payment processes (sandbox)
   - [ ] Subscription status updates in app
   - [ ] No crashes or errors

---

## 📋 PHASE 5: Android Build & Testing (1 hour)

### Step 5.1: Update Android Manifest

**File:** `/android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<!-- OneSignal App ID -->
<meta-data
    android:name="onesignal_app_id"
    android:value="${ONESIGNAL_APP_ID}" />

<!-- Notification icon (optional) -->
<meta-data
    android:name="onesignal_small_icon"
    android:resource="@drawable/ic_stat_onesignal_default" />

<!-- Notification accent color (optional) -->
<meta-data
    android:name="onesignal_accent_color"
    android:resource="@android:color/holo_orange_dark" />
```

---

### Step 5.2: Build Android

```bash
# Build APK
flutter build apk --release

# OR build App Bundle for Play Store
flutter build appbundle --release

# OR run on device/emulator
flutter run -d <android-device-id>
```

**Expected:**
- ✅ Build succeeds
- ✅ APK generated in `build/app/outputs/flutter-apk/`
- ✅ App installs and runs

---

### Step 5.3: Test on Android Device

1. **Install APK**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Test Features**
   - [ ] Sign in/Sign up works
   - [ ] Event booking flow works
   - [ ] PayStack payment works (test mode)
   - [ ] Chat/Feed works
   - [ ] Subscription purchase works
   - [ ] Push notification permissions requested

---

## 📋 PHASE 6: Test Push Notifications (30 mins)

### Step 6.1: Send Test from OneSignal Dashboard

1. **Go to OneSignal Dashboard**
   - Navigate to: **Messages** → **Push**
   - Click **New Push**

2. **Compose Message**
   - **Title**: "Test Notification"
   - **Message**: "Your A-Play notifications are working!"
   - **Audience**: Select **Test Users** or **All Users**

3. **Send**
   - Click **Review** → **Send Message**

4. **Verify**
   - [ ] Notification appears on iOS device
   - [ ] Notification appears on Android device
   - [ ] Tapping opens the app
   - [ ] No errors in console

---

### Step 6.2: Test Booking Confirmation Notification

**When user completes a booking:**

```dart
// In your booking service after successful booking
Future<void> _sendBookingNotification(String userId, Booking booking) async {
  // This would be done server-side via OneSignal REST API
  // For now, test manually from OneSignal dashboard

  // Alternatively, use Supabase Edge Functions
  // See: PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md
}
```

**Manual Test:**
1. Create a booking in the app
2. Manually send notification from OneSignal to that user
3. Verify notification received
4. Tap notification → should open booking details

---

## 📋 PHASE 7: Test Email Service (30 mins)

### Step 7.1: Test Welcome Email

**Update sign-up flow** (already done in Step 3.3)

**Test:**
1. Create a new account in the app
2. Check your inbox for welcome email
3. Verify email renders correctly
4. Check Resend dashboard for delivery status

**Checklist:**
- [ ] Email received
- [ ] Subject line correct: "Welcome to A-Play! 🎉"
- [ ] Content displays properly (images, buttons)
- [ ] No spam folder
- [ ] Resend dashboard shows "delivered"

---

### Step 7.2: Test Password Reset Email

**Test:**
1. Go to password reset screen
2. Enter your email
3. Submit
4. Check inbox for reset email

**Checklist:**
- [ ] Email received
- [ ] Reset link works
- [ ] Email design looks professional
- [ ] Link expires after 1 hour (security)

---

### Step 7.3: Monitor Resend Dashboard

**Check:**
1. Go to Resend dashboard → **Logs**
2. View recent emails
3. Check delivery status
4. Review any errors/bounces

---

## 📋 PHASE 8: Final Testing & QA (2-3 hours)

### Step 8.1: Complete MVP Feature Testing

**Authentication:**
- [ ] Sign up with email works
- [ ] Sign in with email works
- [ ] Google OAuth works (Android)
- [ ] Apple Sign In works (iOS)
- [ ] Password reset works
- [ ] Welcome email received
- [ ] Sign out works

**Event Bookings:**
- [ ] Browse events
- [ ] View event details with map
- [ ] Select zone and seats
- [ ] Complete payment (test mode)
- [ ] Receive QR code ticket
- [ ] View in My Tickets
- [ ] Booking confirmation email received (if configured)

**Subscriptions:**
- [ ] View subscription plans
- [ ] Purchase subscription (sandbox)
- [ ] Subscription status updates
- [ ] Premium features unlock
- [ ] Restore purchases works (iOS)

**Chat:**
- [ ] Send/receive messages
- [ ] Create group chat
- [ ] Search users
- [ ] Friend requests work

**Social Feed:**
- [ ] Create post
- [ ] Like/unlike posts
- [ ] Comment on posts
- [ ] Share posts
- [ ] Follow/unfollow users

**Hidden Features:**
- [ ] Restaurants tab NOT visible in My Tickets
- [ ] Clubs/Lounges/Pubs NOT on Home screen
- [ ] Podcasts route shows "Coming Soon"
- [ ] Referrals NOT in Profile menu

---

### Step 8.2: Device Testing Matrix

Test on:
- [ ] iOS 15.0+ (Simulator)
- [ ] iOS 15.0+ (Physical device)
- [ ] Android 8.0+ (Emulator)
- [ ] Android 8.0+ (Physical device)
- [ ] iPad (if supporting tablets)

---

### Step 8.3: Performance Check

- [ ] App launches in < 3 seconds
- [ ] No memory leaks
- [ ] Smooth scrolling
- [ ] Images load efficiently
- [ ] No crashes during 30-min test session

---

## 📋 PHASE 9: Documentation & Deployment Prep (1 hour)

### Step 9.1: Update Documentation

**Create `.env.example`:**

```bash
# Copy .env to .env.example
copy .env .env.example

# Edit .env.example to remove actual values
notepad .env.example
```

Replace with placeholders:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
PAYSTACK_PUBLIC_KEY=pk_test_xxxxx
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
RESEND_API_KEY=re_xxxxxxxxxxxxx
RESEND_FROM_EMAIL=A-Play <noreply@yourdomain.com>
```

---

### Step 9.2: Create README Section

**Add to `README.md`:**

```markdown
## 🚀 Quick Start

1. Clone the repository
2. Copy `.env.example` to `.env` and fill in your credentials
3. Run `flutter pub get`
4. Run `flutter run`

## 📱 Features (MVP)

- ✅ Authentication (Email, Google, Apple)
- ✅ Event Bookings with QR Tickets
- ✅ Subscription Plans (Bronze, Silver, Gold, Platinum)
- ✅ Chat & Messaging
- ✅ Social Feed
- 🔔 Push Notifications (OneSignal)
- 📧 Transactional Emails (Resend)

## 🔧 Configuration

See `PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md` for detailed setup instructions.
```

---

### Step 9.3: Prepare for App Store Submission

**iOS:**
- [ ] Update version in `pubspec.yaml` (e.g., 2.0.5)
- [ ] Build release: `flutter build ios --release`
- [ ] Archive in Xcode
- [ ] Upload to TestFlight
- [ ] Add screenshots (6.5", 5.5", 12.9" iPad)
- [ ] Write app description
- [ ] Add privacy policy URL

**Android:**
- [ ] Update version in `pubspec.yaml`
- [ ] Build app bundle: `flutter build appbundle --release`
- [ ] Upload to Google Play Console
- [ ] Add screenshots (Phone, 7" tablet, 10" tablet)
- [ ] Complete store listing
- [ ] Add privacy policy

---

## 🎯 SUMMARY CHECKLIST

### Code Complete ✅
- [x] Non-MVP features hidden with feature flags
- [x] StoreKit packages updated
- [x] OneSignal service created
- [x] Resend email service created
- [x] Coming Soon widgets created
- [x] Documentation written

### Configuration Required (Your Action)
- [ ] `flutter pub get` completed
- [ ] OneSignal account created & configured
- [ ] Resend account created & configured
- [ ] `.env` file created with API keys
- [ ] `main.dart` updated with initialization
- [ ] Auth provider updated with services

### Testing Required
- [ ] iOS build succeeds
- [ ] Android build succeeds
- [ ] All 4 MVP features tested
- [ ] Push notifications work
- [ ] Emails send successfully
- [ ] Hidden features verified

### Deployment Prep
- [ ] App Store screenshots ready
- [ ] Play Store screenshots ready
- [ ] Privacy policy hosted
- [ ] Terms of service written
- [ ] App descriptions written

---

## 🔗 Quick Reference

| Task | Documentation | Time Est. |
|------|---------------|-----------|
| Install packages | This doc - Phase 1 | 30 mins |
| Configure OneSignal | This doc - Phase 2.1 | 30 mins |
| Configure Resend | This doc - Phase 2.2 | 20 mins |
| Update code | This doc - Phase 3 | 30 mins |
| iOS build | This doc - Phase 4 | 1-2 hours |
| Android build | This doc - Phase 5 | 1 hour |
| Test notifications | This doc - Phase 6 | 30 mins |
| Test emails | This doc - Phase 7 | 30 mins |
| Full QA testing | This doc - Phase 8 | 2-3 hours |
| **TOTAL TIME** | | **6-9 hours** |

---

## ❓ Need Help?

- **StoreKit issues**: See `PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md` → Section 1
- **OneSignal setup**: See `PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md` → Section 2
- **Resend setup**: See `PUSH_NOTIFICATIONS_AND_EMAIL_SETUP.md` → Section 3
- **General issues**: Check `MVP_TASK_BOARD.md`

---

**Last Updated:** March 31, 2026
**Next Review:** After Phase 3 completion
