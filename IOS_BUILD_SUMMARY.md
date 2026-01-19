# iOS Build Summary - v0.1.0

## ✅ What Was Done

### 1. Version Updated
- **Changed version** from `1.0.3+3` to `0.1.0+1` in `pubspec.yaml`
- This sets:
  - **App Version**: 0.1.0 (displayed to users)
  - **Build Number**: 1 (internal tracking)

### 2. Files Created
1. **`IOS_RELEASE_CHECKLIST.md`** - Complete iOS release checklist
2. **`build_ios_release.sh`** - Automated build script
3. **`IOS_BUILD_SUMMARY.md`** - This file

---

## 🚀 Quick Start - Build iOS Release

### Method 1: Using Build Script (Recommended)
```bash
./build_ios_release.sh
```

This script will:
1. Clean previous builds
2. Get dependencies
3. Generate Freezed code
4. Run analyzer
5. Build release IPA

### Method 2: Manual Build
```bash
# Clean and prepare
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Build IPA
flutter build ipa --release
```

### Method 3: Build via Xcode
```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Then: Product > Archive > Distribute App
```

---

## 📍 Build Output

After successful build, find your IPA at:
```
build/ios/ipa/a_play.ipa
```

---

## 📋 Pre-Build Requirements

### Before You Build:
1. ✅ Run database migration (FEED_DATABASE_MIGRATION.sql)
2. ✅ Generate Freezed code
3. ✅ Ensure no analyzer errors

### Run These Commands First:
```bash
# Generate Freezed models
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for errors
flutter analyze
```

---

## 🍎 Xcode Configuration Needed

You'll need to configure these in Xcode before building:

### 1. Signing & Capabilities
```
open ios/Runner.xcworkspace
```

Then in Xcode:
- Select **Runner** target
- Go to **Signing & Capabilities**
- Select your **Team**
- Set **Bundle Identifier**: `com.aplay.a_play`
- Enable **Automatically manage signing**

### 2. Required Capabilities
- In-App Purchase
- Push Notifications (if using)
- Sign in with Apple (if using)

### 3. Provisioning
- Ensure you have an **App Store** provisioning profile
- Download from Apple Developer Portal if needed

---

## 📤 Upload to App Store

### Option 1: Transporter App (Easiest)
1. Download Transporter from Mac App Store
2. Open Transporter
3. Drag `build/ios/ipa/a_play.ipa` into it
4. Click "Deliver"

### Option 2: Xcode Archive
1. `open ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload

### Option 3: Command Line
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/a_play.ipa \
  --username "your-apple-id@email.com" \
  --password "your-app-specific-password"
```

---

## 🎯 App Store Connect Setup

### 1. App Information
- **Name**: A Play
- **Bundle ID**: com.aplay.a_play
- **SKU**: APLAY001
- **Primary Language**: English

### 2. Pricing & Availability
- **Price**: Free
- **In-App Purchases**: Yes (Bronze, Silver, Gold, Platinum)
- **Availability**: All territories

### 3. Version 0.1.0 Info
**What's New**:
```
Welcome to A Play v0.1.0!

NEW FEATURES:
• Instagram-style feed with square images
• Follow your favorite event bloggers
• Share posts with friends
• Random feed refresh for fresh content
• Post duration options (24hrs, 1 week, 1 month)

IMPROVEMENTS:
• Faster app performance
• Better image loading
• Bug fixes and stability improvements
```

### 4. Required URLs
- **Privacy Policy**: https://www.aplayworld.com/privacy-policy
- **Terms of Service**: https://www.aplayworld.com/terms
- **Support**: https://www.aplayworld.com/support

---

## 🔍 Testing Before Submission

### Must Test:
- [ ] App launches correctly
- [ ] User can sign up/login
- [ ] Events display properly
- [ ] Feed shows square images
- [ ] Like/comment/share works
- [ ] Follow/unfollow works
- [ ] In-app purchases work (sandbox)
- [ ] Location permissions work
- [ ] No crashes on launch
- [ ] Smooth scrolling

### Test Devices:
- iPhone with iOS 12.0+ (minimum)
- iPhone with latest iOS
- iPad (if supporting)

---

## ⚠️ Important Notes

### 1. PayStack vs Apple IAP
- **Android**: Uses PayStack ✅
- **iOS**: Must use Apple In-App Purchase ✅
- **CRITICAL**: Do not mention PayStack in iOS app

### 2. Version Numbering
- **0.1.0**: First beta/initial release
- **0.1.x**: Bug fixes
- **0.2.0**: New features
- **1.0.0**: Stable public release

### 3. Build Numbers
- Must increment for each upload
- Current: 1
- Next upload: 2, then 3, etc.

### 4. Database Migration
**MUST RUN BEFORE TESTING**:
1. Open Supabase SQL Editor
2. Run `FEED_DATABASE_MIGRATION.sql`
3. Verify tables created successfully

---

## 🐛 Troubleshooting

### Build Fails - "No valid code signing certificates"
```bash
# Solution: Configure signing in Xcode
open ios/Runner.xcworkspace
# Select Runner → Signing & Capabilities → Select Team
```

### Build Fails - "Pod install error"
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter build ipa --release
```

### Build Fails - "Freezed errors"
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Archive Not Showing in Xcode
- Select "Any iOS Device" as build target
- Don't use Simulator
- Check scheme is "Release"

---

## 📊 Build Stats

**App Size**: ~50-70 MB (estimated)

**Supported Devices**:
- iPhone (iOS 12.0+)
- iPad (iOS 12.0+)

**Supported Architectures**:
- arm64 (all modern devices)

**Minimum iOS Version**: 12.0

---

## ✅ Final Checklist

Before submitting to App Store:

- [ ] Version is 0.1.0+1
- [ ] Database migration completed
- [ ] Freezed code generated
- [ ] No analyzer errors
- [ ] App tested on device
- [ ] In-app purchases tested
- [ ] Screenshots prepared
- [ ] App icon set (1024x1024)
- [ ] App Store metadata ready
- [ ] Privacy policy URL set
- [ ] Terms of service URL set

---

## 🎉 Success!

Once build is successful:

1. **Test the IPA** on a physical device first
2. **Upload to App Store Connect**
3. **Complete app metadata**
4. **Submit for review**
5. **Wait for approval** (1-7 days typically)

---

## 📞 Need Help?

- **Flutter iOS Docs**: https://docs.flutter.dev/deployment/ios
- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com

---

**Build Ready**: ✅ Yes

**Next Steps**: Run `./build_ios_release.sh` or review `IOS_RELEASE_CHECKLIST.md`
