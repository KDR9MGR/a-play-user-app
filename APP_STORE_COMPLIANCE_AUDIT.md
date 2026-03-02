# App Store Compliance Audit Report
**App Name**: A-Play
**Package**: com.aplay.a_play
**Date**: October 16, 2025

---

## 🚨 CRITICAL ISSUES - Must Fix Before Submission

### 1. ⛔ DEBUG SIGNING IN RELEASE BUILD (WILL CAUSE REJECTION)
**Severity**: CRITICAL - **Google Play WILL REJECT**
**Location**: `android/app/build.gradle.kts:38`

**Problem**:
```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")  // ⛔ USING DEBUG KEYS
}
```

**Why This Fails**:
- Google Play detects debug signatures and **immediately rejects** the app
- Debug keystores have publicly known passwords (android/android debug key)
- Anyone can sign apps with the debug key - major security risk
- Violates Google Play's security requirements

**Fix Required**:
1. You already created `/Users/arbazkudekar/release-keystore.jks`
2. Update `android/key.properties` with your actual passwords
3. Update `android/app/build.gradle.kts` to use release signing (see fix below)

**IMPORTANT**: Never commit `key.properties` or your `.jks` file to Git!

---

### 2. ⚠️ HARDCODED API KEYS IN SOURCE CODE
**Severity**: HIGH - Security Risk & Possible Rejection
**Location**: `android/app/src/main/AndroidManifest.xml:50`

**Problem**:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCgWaCUMUltw9fP0uD9e0RBEyVMdAW1nlA"/>  <!-- ⚠️ EXPOSED -->
```

**Risk**:
- API key is visible in your repository
- Can be extracted from APK by reverse engineering
- Potential for API quota theft and abuse
- Google may flag this as insecure

**Recommended Fix**:
- Restrict API key in Google Cloud Console to your app's SHA-1 fingerprint
- Add application restrictions (Android apps only)
- Add API restrictions (Maps SDK for Android only)
- Consider using Android API key obfuscation

---

### 3. ⚠️ MISSING PRIVACY POLICY URL
**Severity**: HIGH - **Required by Both Stores**
**Location**: Not found in app

**Problem**:
- Both Google Play and App Store **require** a privacy policy URL
- Your app collects:
  - Location data (background location!)
  - Personal information (email, name via Google/Apple Sign-In)
  - Payment information (PayStack)
  - User-generated content (chat, posts)
  - Analytics data (Firebase, OneSignal)

**Required**:
1. Create a privacy policy covering ALL data collection
2. Host it on a publicly accessible URL
3. Add link in:
   - Google Play Console metadata
   - App Store Connect metadata
   - Within your app (e.g., in settings/profile page)

---

### 4. ⚠️ BACKGROUND LOCATION WITHOUT JUSTIFICATION
**Severity**: HIGH - Google Play Policy Violation
**Location**: `android/app/src/main/AndroidManifest.xml:5`

**Problem**:
```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**Google Play Requirements**:
- Apps requesting background location must submit a **declaration form**
- Must clearly explain why background location is needed
- Must show prominent in-app disclosure before requesting
- App may be rejected if justification is weak

**Questions to Answer**:
1. Does your app actually need background location?
2. If yes, what core feature requires it? (e.g., "notify users when events start nearby")
3. Can you use foreground location instead?

**If keeping background location**:
- Add prominent disclosure dialog explaining why
- Only request after user understands the need
- Provide example in your Play Store listing

---

### 5. ⚠️ PAYSTACK PAYMENT - IN-APP PURCHASE POLICY
**Severity**: MEDIUM-HIGH - Apple Policy Violation Risk
**Location**: `lib/services/unified_payment_service.dart`

**Problem**:
Your app uses PayStack for payments, but Apple requires certain transactions to use Apple's In-App Purchase (IAP) system.

**Apple IAP Requirements**:
✅ **Must use Apple IAP for**:
- Digital content (subscriptions, premium features)
- In-app currency/virtual goods
- Unlocking app features

❌ **Can use external payments for**:
- Physical goods/services
- Real-world event tickets
- Restaurant reservations
- One-time physical services

**Your App's Situation**:
- ✅ Event tickets (physical) - **OK to use PayStack**
- ✅ Restaurant bookings (physical) - **OK to use PayStack**
- ⚠️ **Subscription plans** (Bronze/Silver/Gold/Platinum) - **MUST use Apple IAP on iOS**
- ⚠️ **Premium features** - **MUST use Apple IAP on iOS**

**Required Action**:
1. For iOS: Implement StoreKit (Apple IAP) for subscriptions
2. For Android: Keep PayStack OR add Google Play Billing
3. Split payment flows based on platform and purchase type

---

## ⚠️ HIGH PRIORITY ISSUES

### 6. Missing Data Safety Declarations
**Severity**: HIGH
**Required By**: Google Play Store

**Problem**: Google Play requires detailed data safety form covering:
- What data you collect
- Why you collect it
- How it's shared
- Security practices

**Your App Collects**:
- ✓ Location (precise + background)
- ✓ Personal info (name, email, profile photo)
- ✓ Financial info (payment details via PayStack)
- ✓ User content (chat messages, feed posts, reviews)
- ✓ Device info (Firebase Analytics, OneSignal)
- ✓ Usage data (analytics)

**Action**: Complete Data Safety form in Google Play Console before submission

---

### 7. Insufficient Permission Usage Descriptions (iOS)
**Severity**: MEDIUM
**Location**: `ios/Runner/Info.plist`

**Current Descriptions**:
- Location: ✓ Good
- Microphone: ✓ Good
- Speech Recognition: ✓ Good

**Missing**:
- **NSPhotoLibraryUsageDescription** - Your app uses `image_picker` package
- **NSCameraUsageDescription** - Required for image_picker camera access
- **NSPhotoLibraryAddUsageDescription** - For saving photos (iOS 14+)

**Fix**: Add to Info.plist:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to let you upload profile pictures and share event photos.</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to let you take photos for your profile and share event moments.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos from events to your library.</string>
```

---

### 8. Secret Keys Exposure Risk
**Severity**: MEDIUM-HIGH
**Location**: `lib/core/config/paystack_config.dart` (assumed)

**Problem**: Your code references both public AND secret PayStack keys in the client app.

**From**: `lib/services/unified_payment_service.dart:10`
```dart
final String _secretKey = PaystackConfig.secretKey;  // ⚠️ DANGER
```

**CRITICAL SECURITY ISSUE**:
- **SECRET keys should NEVER be in client apps**
- Anyone can decompile your APK/IPA and extract the secret key
- With your secret key, attackers can:
  - Process fraudulent refunds
  - Access customer payment data
  - Manipulate transactions

**Required Fix**:
1. **Remove** `PaystackConfig.secretKey` from client app entirely
2. Move all server-side operations to a backend API (Supabase Edge Functions)
3. Only use public key in client app
4. Handle payment verification server-side

---

## 📋 MEDIUM PRIORITY ISSUES

### 9. Proguard Rules Not Configured
**Severity**: MEDIUM
**Problem**: Code shrinking/obfuscation not properly configured for release

**Current**: `android/app/proguard-rules.pro` exists but not used in release build

**Impact**:
- Larger APK size
- Easier to reverse engineer
- Potential crashes with certain libraries

---

### 10. Missing App Description/Screenshots
**Severity**: MEDIUM
**Required**: Both stores require at minimum:
- App description
- Screenshots (phone + tablet)
- Feature graphic (Google Play)
- App icon (512x512 for Play, 1024x1024 for App Store)
- Privacy policy link

---

### 11. No Crash Reporting Configured
**Severity**: LOW-MEDIUM
**Observation**: You have Firebase but no Crashlytics

**Recommendation**: Add Firebase Crashlytics to catch production crashes

---

## ✅ COMPLIANCE CHECKLIST

### Google Play Store Requirements
- [ ] ⛔ **Release signing configured** (CRITICAL)
- [ ] ⚠️ **Privacy policy URL provided**
- [ ] ⚠️ **Data safety form completed**
- [ ] ⚠️ **Background location justification**
- [ ] **App content rating completed**
- [ ] **Target API 34+ (Android 14)**
- [ ] **64-bit native libraries**
- [ ] **Screenshots uploaded**
- [ ] **Feature graphic uploaded**

### Apple App Store Requirements
- [ ] ⛔ **Release build with valid certificate**
- [ ] ⚠️ **Privacy policy URL provided**
- [ ] ⚠️ **Apple IAP for subscriptions** (if selling digital content)
- [ ] **App Privacy details filled**
- [ ] **All permission descriptions added**
- [ ] **Screenshots uploaded**
- [ ] **App icon 1024x1024**
- [ ] **Export compliance documentation**

---

## 🔧 IMMEDIATE FIXES REQUIRED

### Fix #1: Configure Release Signing (Android)

1. **Update your key.properties** with real passwords:
```properties
storePassword=YOUR_ACTUAL_PASSWORD
keyPassword=YOUR_ACTUAL_PASSWORD
keyAlias=release-key
storeFile=/Users/arbazkudekar/release-keystore.jks
```

2. **Add to `.gitignore`**:
```
android/key.properties
*.jks
*.keystore
```

3. **Update build.gradle.kts** - Replace line 38 onwards with:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### Fix #2: Remove PayStack Secret Key from Client

**NEVER** use secret keys in client apps. Create a Supabase Edge Function:

```typescript
// supabase/functions/initialize-payment/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { email, amount, reference, metadata } = await req.json()

  const response = await fetch('https://api.paystack.co/transaction/initialize', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('PAYSTACK_SECRET_KEY')}`,  // Secure!
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, amount, reference, metadata })
  })

  return new Response(JSON.stringify(await response.json()))
})
```

Then call from Flutter:
```dart
final response = await Supabase.instance.client.functions.invoke(
  'initialize-payment',
  body: { 'email': email, 'amount': amount, ... }
);
```

### Fix #3: Add Missing iOS Permissions

Add to `ios/Runner/Info.plist` before closing `</dict>`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to let you upload and share event photos.</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to let you take photos for your profile and events.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save event photos to your library.</string>
```

---

## 📝 DOCUMENTATION REQUIRED

### Privacy Policy Must Cover:
1. **Data Collection**:
   - Location (including background)
   - Personal information (name, email, profile)
   - Payment information
   - User content (messages, posts)
   - Device/usage data

2. **Data Usage**:
   - Personalization
   - Event recommendations
   - Payment processing
   - Analytics
   - Push notifications

3. **Third-Party Services**:
   - Supabase (data storage)
   - PayStack (payments)
   - Firebase (analytics)
   - OneSignal (notifications)
   - Google Maps (location)

4. **User Rights**:
   - Data access
   - Data deletion
   - Account termination

---

## 🎯 PRIORITY ACTION PLAN

### Before First Submission:
1. ⛔ **Fix release signing** (Critical - will reject immediately)
2. ⚠️ **Remove PayStack secret key** (Security risk)
3. ⚠️ **Create and link privacy policy**
4. ⚠️ **Add missing iOS permissions**
5. ⚠️ **Decide on Apple IAP vs PayStack** for subscriptions
6. **Complete store listings** (descriptions, screenshots)
7. **Fill data safety forms**

### Recommended Timeline:
- **Week 1**: Fix critical issues (signing, security)
- **Week 2**: Privacy policy, permissions, store assets
- **Week 3**: Payment compliance (Apple IAP if needed)
- **Week 4**: Testing, final review, submit

---

## 📞 NEXT STEPS

1. **Address all CRITICAL issues immediately**
2. **Review payment compliance** - decide IAP strategy
3. **Create privacy policy** - use generator if needed
4. **Prepare store assets** - screenshots, descriptions
5. **Test release build** - ensure it works with release signing
6. **Submit for review** - expect 1-7 days review time

---

**Generated**: October 16, 2025
**Review Status**: Needs immediate attention for critical issues
