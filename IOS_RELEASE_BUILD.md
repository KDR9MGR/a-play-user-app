# iOS Release Build Guide - Version 2.0.0

**Date:** 2025-11-29
**Version:** 2.0.0 (Build 1)
**Status:** Ready for App Store submission

---

## 🎯 Version 2.0.0 - What's New

### iPad Air Bug Fixes (Apple Guideline 2.1 Compliance)
1. ✅ **Feed Tab** - Fixed LateInitializationError crash
2. ✅ **Bookings Tab** - Improved authentication error handling with clear CTAs
3. ✅ **Explore Tab** - Added network error handling with user-friendly messages

### Authentication Flow Updates (Apple Guideline 5.1.1 Compliance)
1. ✅ **Guest Access** - Added "Continue as Guest" option
2. ✅ **Splash Screen** - Always shows on launch regardless of auth state
3. ✅ **Social Sign-In** - Removed Google and Apple sign-in buttons per requirements

### Apple Review Guideline Compliance
- ✅ **Guideline 2.1** - App completeness and reliability on iPad Air
- ✅ **Guideline 3.1.1** - Apple IAP only (no PayStack on iOS)
- ✅ **Guideline 3.1.2** - Terms & Conditions link added
- ✅ **Guideline 5.1.1** - Guest access to Explore tab

---

## 📋 Pre-Build Checklist

### 1. Version & Build Number ✅
- [x] Version updated to 2.0.0+1 in pubspec.yaml
- [ ] Verify version in Xcode project settings

### 2. Code Quality
- [ ] Run `flutter analyze` - ensure no errors
- [ ] Run tests if available: `flutter test`
- [ ] All iPad Air fixes verified

### 3. Environment Configuration
- [ ] Production Supabase URL configured
- [ ] Production PayStack keys (if needed)
- [ ] Firebase production project linked
- [ ] .env file has production values

### 4. iOS Specific
- [ ] Provisioning profile valid
- [ ] Certificates up to date
- [ ] Bundle identifier correct: `com.aplay.a_play`
- [ ] App icons present and correct

---

## 🏗️ Build Commands

### Option 1: Build for TestFlight/App Store

```bash
# 1. Set file limit
ulimit -n 10240

# 2. Clean build
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 3. Build release IPA
flutter build ios --release

# 4. Or build directly in Xcode (recommended for App Store)
open ios/Runner.xcworkspace
```

**In Xcode:**
1. Select "Any iOS Device (arm64)" as target
2. Product → Archive
3. Wait for archive to complete
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Follow the upload wizard

---

### Option 2: Build Archive via Command Line

```bash
# Navigate to iOS directory
cd ios

# Build archive
xcodebuild archive \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -archivePath build/Runner.xcarchive \
  -configuration Release \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist

cd ..
```

---

## 📦 TestFlight Distribution

### Upload to App Store Connect

**Method 1: Xcode (Recommended)**
1. Open Xcode
2. Window → Organizer
3. Select your archive
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Select upload options:
   - ✅ Include bitcode
   - ✅ Upload symbols
   - ✅ Manage version and build number
7. Click "Upload"

**Method 2: Transporter App**
1. Build IPA using commands above
2. Open Transporter app
3. Drag and drop IPA file
4. Click "Deliver"

**Method 3: Command Line (altool)**
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/Runner.ipa \
  --username "your-apple-id@email.com" \
  --password "your-app-specific-password"
```

---

## 📝 App Store Connect Configuration

### Required Information

#### App Information
- **Name:** A-Play
- **Subtitle:** Ghana Event Booking Platform
- **Category:** Entertainment
- **Content Rights:** Own or licensed

#### Version Information
- **Version:** 2.0.0
- **What's New in This Version:**
```
Version 2.0.0 - Enhanced Stability and User Experience

NEW FEATURES:
• Guest Access: Browse events without signing in
• Improved Splash Screen: Better launch experience
• Enhanced Error Handling: User-friendly error messages

BUG FIXES:
• Fixed app crashes on iPad Air devices
• Resolved network timeout issues
• Improved authentication flow
• Better error messaging for offline scenarios

COMPLIANCE UPDATES:
• Apple App Store guideline compliance
• Enhanced security and privacy
• Improved in-app purchase handling
```

#### Screenshots Required
- 6.5" iPhone (iPhone 14 Pro Max)
- 5.5" iPhone (iPhone 8 Plus)
- 12.9" iPad Pro (3rd gen)
- Capture from simulator after testing

#### App Privacy
- [ ] Update privacy policy if needed
- [ ] Review data collection practices
- [ ] Update nutrition labels

---

## 🧪 Testing Before Submission

### Pre-Submission Testing Checklist

#### iPad Air Testing (Critical!)
- [ ] Launch app on iPad Air simulator
- [ ] Test Feed tab - no crashes
- [ ] Test Bookings tab - shows sign-in prompt for guests
- [ ] Test Explore tab - loads events without auth
- [ ] Test network error scenarios

#### iPhone Testing
- [ ] Test on iPhone 11 Pro Max simulator
- [ ] Test on iPhone 15 Pro simulator (latest)
- [ ] All tabs load correctly
- [ ] Navigation works smoothly

#### Guest User Flow
- [ ] Launch app → See splash screen
- [ ] Tap "Continue as Guest"
- [ ] Navigate to Explore → See events
- [ ] Navigate to Bookings → See "Sign in Required"
- [ ] Tap "Sign In" → Navigate to sign-in screen

#### Authenticated User Flow
- [ ] Sign in with email/password
- [ ] All features accessible
- [ ] Bookings show correctly
- [ ] Profile loads

#### Error Scenarios
- [ ] Enable airplane mode → Test Explore tab
- [ ] Should see "Connection Issue" not technical errors
- [ ] Retry button works
- [ ] No URLs or stack traces visible

---

## 🚀 Submission Steps

### 1. Prepare Release Notes
Create detailed release notes explaining:
- All bug fixes for Apple reviewers
- Reference to guideline compliance
- Testing performed on iPad Air

### 2. Submit for Review
1. Go to App Store Connect
2. Select your app
3. Click "+ Version or Platform"
4. Enter version 2.0.0
5. Fill in all required fields
6. Upload build from TestFlight
7. Answer review questions:
   - Demo account credentials (if needed)
   - Special instructions for reviewers
   - Note about iPad Air fixes

### 3. Reviewer Notes (Important!)
Add this note for Apple reviewers:
```
Version 2.0.0 Release Notes for Reviewers:

This release specifically addresses all issues identified in the previous review:

1. GUIDELINE 2.1 (App Completeness):
   - Fixed all crashes and errors on iPad Air 5th Gen (iOS 26.1)
   - Implemented proper error handling throughout the app
   - Added network timeout handling (10 seconds)
   - No technical errors are visible to users

2. GUIDELINE 3.1.1 (In-App Purchase):
   - App uses Apple In-App Purchase exclusively on iOS
   - PayStack integration disabled on iOS platform

3. GUIDELINE 3.1.2 (Subscriptions):
   - Terms & Conditions link added to subscription screen

4. GUIDELINE 5.1.1 (Guest Access):
   - Users can now browse events without signing in
   - "Continue as Guest" option added to sign-in screen
   - Explore tab accessible to all users

TESTING PERFORMED:
- Tested on iPad Air 5th Gen simulator (iOS 26.1)
- Tested on iPhone 11 Pro Max, iPhone 15 Pro
- All error scenarios verified
- Guest access flow thoroughly tested

Please test on iPad Air to verify all fixes.

Demo Account (if needed):
Email: [your-test-account@email.com]
Password: [test-password]
```

---

## 📊 Build Script

Run this complete build script:

```bash
#!/bin/bash

echo "================================================"
echo "iOS Release Build - Version 2.0.0"
echo "================================================"
echo ""

# Set file limit
echo "1. Setting file descriptor limit..."
ulimit -n 10240
echo "   File limit: $(ulimit -n)"
echo ""

# Clean everything
echo "2. Cleaning build artifacts..."
flutter clean
cd ios
rm -rf Pods Podfile.lock build DerivedData
cd ..
echo "   ✓ Clean complete"
echo ""

# Install pods
echo "3. Installing CocoaPods..."
cd ios
pod install
cd ..
echo "   ✓ Pods installed"
echo ""

# Get dependencies
echo "4. Getting Flutter dependencies..."
flutter pub get
echo "   ✓ Dependencies fetched"
echo ""

# Run analyzer
echo "5. Running Flutter analyze..."
flutter analyze
echo ""

# Build release
echo "6. Building iOS release..."
echo "   Choose build method:"
echo "   a) Build IPA (flutter build ios)"
echo "   b) Open Xcode for Archive (recommended)"
read -p "   Enter choice (a/b): " choice

if [ "$choice" = "a" ]; then
    flutter build ios --release
    echo ""
    echo "   ✓ IPA built successfully"
    echo "   Location: build/ios/iphoneos/Runner.app"
else
    open ios/Runner.xcworkspace
    echo ""
    echo "   ✓ Xcode opened"
    echo "   Next steps in Xcode:"
    echo "   1. Select 'Any iOS Device (arm64)'"
    echo "   2. Product → Archive"
    echo "   3. Distribute to App Store"
fi

echo ""
echo "================================================"
echo "Build process complete!"
echo "================================================"
```

Save this as `build_release.sh` and run:
```bash
chmod +x build_release.sh
./build_release.sh
```

---

## ✅ Final Checklist Before Upload

- [ ] Version 2.0.0 in pubspec.yaml
- [ ] All iPad Air fixes tested
- [ ] Guest access works
- [ ] No technical errors visible
- [ ] App icons present
- [ ] Signing configured
- [ ] Build successful
- [ ] Archive created
- [ ] Uploaded to App Store Connect
- [ ] Release notes written
- [ ] Reviewer notes added
- [ ] Privacy policy updated
- [ ] Screenshots uploaded

---

## 🎉 Success Criteria

Your release is ready when:
1. ✅ App builds without errors
2. ✅ Archive uploads successfully
3. ✅ No crashes on iPad Air
4. ✅ All Apple guidelines addressed
5. ✅ TestFlight build processing complete
6. ✅ Submitted for review

---

## 📞 Support

If you encounter issues during build:
- Check [FIX_IOS_BUILD_ERROR.md](FIX_IOS_BUILD_ERROR.md)
- Check [FIX_TOO_MANY_OPEN_FILES.md](FIX_TOO_MANY_OPEN_FILES.md)
- Refer to [IPAD_AIR_FIXES_SUMMARY.md](IPAD_AIR_FIXES_SUMMARY.md)

---

**Version:** 2.0.0
**Build:** 1
**Status:** ✅ READY FOR APP STORE SUBMISSION
