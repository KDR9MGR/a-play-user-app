# Push Notifications & Email Setup Guide

**Date:** March 31, 2026
**App Version:** 2.0.4+3
**Services:** OneSignal (Push Notifications) + Resend (Transactional Emails)

---

## 📋 Table of Contents

1. [StoreKit Fix (iOS)](#storekit-fix-ios)
2. [OneSignal Push Notifications Setup](#onesignal-push-notifications-setup)
3. [Resend Email Service Setup](#resend-email-service-setup)
4. [Integration with App](#integration-with-app)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 StoreKit Fix (iOS)

### Issue
iOS build fails with StoreKit API deprecation errors on iOS 18.

### Solution

#### 1. Update Dependencies ✅ **COMPLETED**

The `pubspec.yaml` has been updated with:

```yaml
dependencies:
  # In-App Purchase (Updated for iOS 18 StoreKit compatibility)
  in_app_purchase: ^3.2.0
  in_app_purchase_storekit: ^0.4.8+1
```

#### 2. Install Updated Packages

**In Windows Terminal** (not WSL):

```bash
cd E:\path\to\a-play-user-app-main
flutter pub get
```

#### 3. Clean iOS Build

```bash
# Clean Flutter build cache
flutter clean

# Navigate to iOS directory and clean pods
cd ios
rm -rf Pods Podfile.lock .symlinks
pod install --repo-update

# Return to root
cd ..
```

#### 4. Rebuild iOS App

```bash
flutter build ios --release
# OR for debug
flutter run -d <ios-device-id>
```

#### 5. Verify StoreKit Integration

Test on **iOS 15+** simulator or device:
- Subscription purchase flow
- Restore purchases
- Receipt validation

### Expected Result
- ✅ Build succeeds without StoreKit deprecation warnings
- ✅ Subscription purchases work on iOS 18
- ✅ No `SKProduct` deprecation errors

---

## 🔔 OneSignal Push Notifications Setup

### Overview
OneSignal handles all push notifications:
- Booking confirmations
- Event reminders (24h before)
- New chat messages
- Subscription renewals
- Payment confirmations

### 1. Create OneSignal Account

1. Go to [https://onesignal.com](https://onesignal.com)
2. Sign up for a free account
3. Create a new app: **"A-Play"**
4. Select platform: **Flutter**

### 2. Get Your App ID

After creating the app, you'll receive:
- **App ID** (e.g., `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
- Copy this - you'll need it for configuration

### 3. Configure iOS (Apple Push Notification Service)

#### a. Generate APNs Auth Key

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to: **Certificates, Identifiers & Profiles** → **Keys**
3. Click **"+"** to create a new key
4. Name it: **"A-Play APNs Key"**
5. Check **Apple Push Notifications service (APNs)**
6. Click **Continue** → **Register**
7. **Download** the `.p8` key file (you can only do this once!)
8. Note your:
   - **Key ID** (10 characters)
   - **Team ID** (found in your Apple Developer account)

#### b. Upload to OneSignal

1. In OneSignal dashboard → **Settings** → **Platforms**
2. Select **Apple iOS**
3. Choose **".p8 Auth Key"** (recommended)
4. Upload:
   - **Team ID**: Your Apple Team ID
   - **Key ID**: From the key you created
   - **p8 file**: Upload the downloaded `.p8` file
5. **Bundle ID**: `com.yourcompany.aplay` (match your iOS app)
6. Click **Save**

### 4. Configure Android (Firebase Cloud Messaging)

#### a. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **a-play** project (or create one)
3. Click **Project Settings** (gear icon)
4. Navigate to **Cloud Messaging** tab
5. Under **Cloud Messaging API (V1)**, click **"Manage Service Accounts"**
6. Click **"Create Service Account"**
7. Generate a **JSON key** and download it

#### b. Upload to OneSignal

1. In OneSignal dashboard → **Settings** → **Platforms**
2. Select **Google Android (FCM)**
3. Upload the Firebase **service account JSON** file
4. Click **Save**

### 5. Update Environment Variables

Create/update `.env` file in project root:

```env
# Existing variables
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PAYSTACK_PUBLIC_KEY=your_paystack_key

# NEW: OneSignal
ONESIGNAL_APP_ID=your-onesignal-app-id-here

# NEW: Resend (see next section)
RESEND_API_KEY=your-resend-api-key-here
RESEND_FROM_EMAIL=A-Play <noreply@yourdomain.com>
```

### 6. Update `main.dart`

Add OneSignal initialization in `/lib/main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:a_play/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase (existing)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // NEW: Initialize OneSignal
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    await NotificationService().initialize(appId: oneSignalAppId);
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 7. Update Auth Flow

In `/lib/features/authentication/presentation/providers/auth_provider.dart`:

```dart
import 'package:a_play/core/services/notification_service.dart';

// In sign-in success handler:
Future<void> _onSignInSuccess(String userId) async {
  // Set OneSignal external user ID
  await NotificationService().setExternalUserId(userId);

  // Update user preferences for targeting
  final user = await _getUserProfile(userId);
  await NotificationService().updateUserPreferences(
    userId: userId,
    subscriptionTier: user.subscriptionTier,
    location: user.city,
  );
}

// In sign-out handler:
Future<void> signOut() async {
  // Remove OneSignal external user ID
  await NotificationService().removeExternalUserId();

  // Continue with normal sign out
  await Supabase.instance.client.auth.signOut();
}
```

### 8. iOS Configuration Files

#### Update `ios/Runner/Info.plist`

Add before `</dict></plist>`:

```xml
<!-- OneSignal Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<!-- Notification permissions -->
<key>NSUserNotificationsUsageDescription</key>
<string>We'll send you booking confirmations, event reminders, and important updates.</string>
```

### 9. Android Configuration Files

#### Update `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <application>
        <!-- Existing configuration -->

        <!-- OneSignal notification metadata -->
        <meta-data
            android:name="onesignal_app_id"
            android:value="YOUR_ONESIGNAL_APP_ID" />

        <!-- Notification icon (optional) -->
        <meta-data
            android:name="onesignal_small_icon"
            android:resource="@drawable/ic_stat_onesignal_default" />

        <!-- Notification color (optional) -->
        <meta-data
            android:name="onesignal_accent_color"
            android:resource="@android:color/holo_orange_dark" />
    </application>
</manifest>
```

### 10. Test Notifications

#### Send Test Notification from OneSignal

1. Go to OneSignal Dashboard → **Messages** → **Push**
2. Click **New Push**
3. Compose message:
   - **Title**: "Test Notification"
   - **Message**: "Your A-Play notifications are working!"
4. **Audience**: Select **Test Devices** or specific user
5. Click **Send Message**

#### From Code (Production Use)

```dart
// Example: Send booking confirmation notification
Future<void> sendBookingConfirmation(String userId, String eventName) async {
  // This would be done server-side via OneSignal REST API
  // See: https://documentation.onesignal.com/reference/create-notification

  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic YOUR_REST_API_KEY',
    },
    body: jsonEncode({
      'app_id': 'YOUR_ONESIGNAL_APP_ID',
      'include_external_user_ids': [userId],
      'headings': {'en': 'Booking Confirmed! 🎉'},
      'contents': {'en': 'Your booking for $eventName is confirmed.'},
      'data': {
        'type': 'booking',
        'id': 'booking_id_here',
      },
    }),
  );
}
```

---

## 📧 Resend Email Service Setup

### Overview
Resend handles transactional emails:
- Welcome emails for new users
- Email verification
- Password reset
- Booking confirmations (backup)

### 1. Create Resend Account

1. Go to [https://resend.com](https://resend.com)
2. Sign up with GitHub or email
3. Verify your account

### 2. Add and Verify Domain

#### For Production:

1. Go to **Domains** in Resend dashboard
2. Click **Add Domain**
3. Enter your domain: `yourdomain.com`
4. Add the DNS records Resend provides:

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

5. Wait for DNS propagation (up to 48 hours)
6. Verify domain in Resend dashboard

#### For Testing (Temporary):

Use Resend's sandbox: `onboarding@resend.dev`
- Can only send to **your email address**
- Good for development/testing

### 3. Get API Key

1. Go to **API Keys** in Resend dashboard
2. Click **Create API Key**
3. Name it: **"A-Play Production"**
4. **Permissions**: Full Access (or just Send access)
5. Copy the API key (starts with `re_...`)
6. **Save it securely** - you can't view it again!

### 4. Update Environment Variables

Add to `.env`:

```env
# Resend Email Service
RESEND_API_KEY=re_your_api_key_here
RESEND_FROM_EMAIL=A-Play <noreply@yourdomain.com>
```

**Important:** If using sandbox, use:
```env
RESEND_FROM_EMAIL=A-Play <onboarding@resend.dev>
```

### 5. Add flutter_dotenv Package

If not already added, update `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Then:
```bash
flutter pub get
```

### 6. Load .env in main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // ... rest of initialization
}
```

### 7. Integrate Email Service

#### Welcome Email (After Sign Up)

In `/lib/features/authentication/presentation/providers/auth_provider.dart`:

```dart
import 'package:a_play/core/services/email_service.dart';

Future<void> _onSignUpSuccess(String userId, String email, String name) async {
  // Existing code...

  // Send welcome email
  final emailService = EmailService();
  await emailService.sendWelcomeEmail(
    toEmail: email,
    userName: name,
  );
}
```

#### Email Verification

```dart
Future<void> sendVerificationEmail(String email, String userId) async {
  // Generate verification link with Supabase
  final verificationLink = 'https://yourapp.com/verify-email?token=...';

  // Send email
  final emailService = EmailService();
  await emailService.sendVerificationEmail(
    toEmail: email,
    verificationLink: verificationLink,
    userName: userName,
  );
}
```

#### Password Reset

```dart
Future<void> sendPasswordReset(String email) async {
  // Generate reset link with Supabase
  final resetLink = await Supabase.instance.client.auth.resetPasswordForEmail(
    email,
    redirectTo: 'https://yourapp.com/reset-password',
  );

  // Send custom email via Resend
  final emailService = EmailService();
  await emailService.sendPasswordResetEmail(
    toEmail: email,
    resetLink: resetLink,
    userName: userName,
  );
}
```

#### Booking Confirmation

```dart
Future<void> sendBookingConfirmation(Booking booking) async {
  final emailService = EmailService();
  await emailService.sendBookingConfirmationEmail(
    toEmail: booking.userEmail,
    userName: booking.userName,
    eventName: booking.eventName,
    bookingId: booking.id,
    eventDate: booking.eventDate,
    venue: booking.venue,
    ticketCount: booking.ticketCount,
  );
}
```

---

## 🔗 Integration with App

### 1. Update .gitignore

Ensure `.env` is not committed:

```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

### 2. Create .env.example

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# PayStack
PAYSTACK_PUBLIC_KEY=pk_test_xxxxx

# OneSignal
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Resend
RESEND_API_KEY=re_xxxxxxxxxxxxx
RESEND_FROM_EMAIL=A-Play <noreply@yourdomain.com>
```

### 3. Dart Defines for Build

In Windows terminal, build with:

```bash
flutter build apk --dart-define=ONESIGNAL_APP_ID=your-app-id
flutter build ios --dart-define=ONESIGNAL_APP_ID=your-app-id
```

Or use `--dart-define-from-file`:

Create `dart_defines.json`:
```json
{
  "ONESIGNAL_APP_ID": "your-app-id",
  "RESEND_API_KEY": "your-api-key",
  "RESEND_FROM_EMAIL": "A-Play <noreply@yourdomain.com>"
}
```

Build with:
```bash
flutter build apk --dart-define-from-file=dart_defines.json
```

---

## 🧪 Testing

### Test OneSignal

#### 1. Test on Simulator/Device

```bash
# iOS
flutter run -d <ios-device>

# Android
flutter run -d <android-device>
```

#### 2. Send Test Push from OneSignal Dashboard

1. Go to **Messages** → **New Push**
2. Select **Test Users** or specific device
3. Send notification
4. Verify it appears on device

#### 3. Test Notification Click Handling

Tap on the notification and verify:
- App opens to correct screen
- Data is passed correctly

### Test Resend Emails

#### 1. Sandbox Testing

```dart
// Use your email for testing
final emailService = EmailService();
final success = await emailService.sendWelcomeEmail(
  toEmail: 'your@email.com',  // Your verified email
  userName: 'Test User',
);

debugPrint('Email sent: $success');
```

#### 2. Check Resend Dashboard

1. Go to **Logs** in Resend dashboard
2. View sent emails
3. Check delivery status

#### 3. Test All Email Types

- [ ] Welcome email
- [ ] Email verification
- [ ] Password reset
- [ ] Booking confirmation

---

## 🐛 Troubleshooting

### OneSignal Issues

#### Problem: Notifications not received

**Solutions:**
1. Check notification permissions in device settings
2. Verify OneSignal App ID is correct
3. Check device is registered:
   ```dart
   final playerId = NotificationService().playerId;
   debugPrint('OneSignal Player ID: $playerId');
   ```
4. Test with OneSignal dashboard first

#### Problem: iOS notifications not working

**Solutions:**
1. Verify APNs certificate is uploaded correctly
2. Check Bundle ID matches exactly
3. Test on physical device (simulators have limitations)
4. Enable push notifications in Xcode:
   - Target → Signing & Capabilities → **+ Capability** → Push Notifications

#### Problem: Android notifications not working

**Solutions:**
1. Verify FCM configuration is correct
2. Check google-services.json is in `android/app/`
3. Verify package name matches

### Resend Email Issues

#### Problem: Emails not sending

**Solutions:**
1. Check API key is valid
2. Verify domain is verified (for production)
3. Check Resend dashboard logs
4. For sandbox, ensure sending to your verified email only

#### Problem: Emails in spam

**Solutions:**
1. Verify SPF, DKIM, DMARC records
2. Use verified domain (not sandbox)
3. Add reply-to address
4. Warm up domain gradually

### StoreKit Issues

#### Problem: Build still fails after update

**Solutions:**
1. Clean Flutter cache: `flutter clean`
2. Clean Xcode derived data
3. Delete `ios/Pods` and `Podfile.lock`
4. Run `pod install --repo-update`
5. Rebuild: `flutter build ios`

#### Problem: Subscriptions not working

**Solutions:**
1. Test in sandbox mode first
2. Verify products are created in App Store Connect
3. Check bundle ID matches
4. Wait 24-48h after creating products

---

## 📝 Checklist

### Pre-Launch

#### StoreKit
- [ ] Dependencies updated in pubspec.yaml
- [ ] `flutter pub get` completed
- [ ] iOS build succeeds without warnings
- [ ] Subscription purchase tested on iOS 15+

#### OneSignal
- [ ] OneSignal account created
- [ ] App created in OneSignal
- [ ] iOS APNs configured (p8 key uploaded)
- [ ] Android FCM configured (JSON uploaded)
- [ ] ONESIGNAL_APP_ID added to .env
- [ ] NotificationService initialized in main.dart
- [ ] Auth flow updated (setExternalUserId)
- [ ] Test notification received

#### Resend
- [ ] Resend account created
- [ ] Domain added and verified (or using sandbox)
- [ ] API key generated
- [ ] RESEND_API_KEY and RESEND_FROM_EMAIL in .env
- [ ] EmailService integrated in auth flow
- [ ] Welcome email tested
- [ ] Password reset email tested

### Production Deployment

- [ ] .env file configured with production keys
- [ ] Build with dart-defines
- [ ] Test on physical iOS device
- [ ] Test on physical Android device
- [ ] Notification permissions granted
- [ ] All email templates reviewed
- [ ] Domain DNS propagated (if using custom domain)

---

## 🔗 Resources

- **OneSignal Docs**: https://documentation.onesignal.com/docs/flutter-sdk-setup
- **Resend Docs**: https://resend.com/docs/send-with-flutter
- **Apple APNs**: https://developer.apple.com/documentation/usernotifications
- **Firebase FCM**: https://firebase.google.com/docs/cloud-messaging
- **StoreKit 2**: https://developer.apple.com/documentation/storekit/in-app_purchase

---

**Questions?** Contact support or check the documentation links above.

**Last Updated:** March 31, 2026
**Next Review:** Before App Store submission
