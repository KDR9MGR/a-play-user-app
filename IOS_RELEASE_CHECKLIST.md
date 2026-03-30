# iOS Release Build Checklist - v0.1.0

## ✅ Version Updated

- **Version**: 0.1.0+1
- **Location**: `pubspec.yaml` (line 19)
- **Format**: `0.1.0` (version) + `1` (build number)

---

## 📋 Pre-Build Checklist

### 1. Code Quality
- [ ] Run `flutter analyze` - ensure no errors
- [ ] Run `flutter test` - ensure all tests pass
- [ ] Generate Freezed models: `flutter packages pub run build_runner build --delete-conflicting-outputs`

### 2. iOS Specific Checks
- [ ] Verify Info.plist has all required permissions
- [ ] Check bundle identifier: `com.aplay.a_play`
- [ ] Verify signing certificates in Xcode
- [ ] Check deployment target (iOS 12.0+)

### 3. App Store Compliance
- [ ] Privacy Policy URL: https://www.aplayworld.com/privacy-policy
- [ ] Terms of Service URL: https://www.aplayworld.com/terms
- [ ] EULA Link: https://www.aplayworld.com/eula
- [ ] Support URL: https://www.aplayworld.com/support

### 4. In-App Purchases
- [ ] Verify IAP is configured (NOT using PayStack on iOS)
- [ ] Test subscription tiers (Bronze, Silver, Gold, Platinum)
- [ ] Ensure App Store receipt validation is working

---

## 🔨 Build Commands

### Option 1: Build IPA (Recommended)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build iOS release IPA
flutter build ipa --release

# Output location: build/ios/ipa/*.ipa
```

### Option 2: Build iOS Archive (for Xcode upload)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build iOS release
flutter build ios --release

# Then open in Xcode:
open ios/Runner.xcworkspace

# In Xcode: Product > Archive > Distribute App
```

---

## 📱 Build Configuration

### Current Info.plist Settings

**App Display Name**: A Play

**Bundle Identifier**: com.aplay.a_play (set in Xcode)

**Version**: 0.1.0 (from pubspec.yaml)

**Build Number**: 1 (from pubspec.yaml)

**Permissions Required**:
- ✅ Location (When In Use) - For nearby events
- ✅ Location (Always) - For event notifications
- ✅ Microphone - For voice messages
- ✅ Speech Recognition - For voice-to-text

**URL Schemes**:
- ✅ Supabase OAuth: `io.supabase.aplay`
- ✅ Google Sign-In: `com.googleusercontent.apps.1093191311629-fhr1ijlmcone2lr81i8rajqhiu0rhgbn`

**Export Compliance**: `ITSAppUsesNonExemptEncryption = false`

---

## 🎯 Xcode Configuration Steps

### 1. Open Project in Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Signing & Capabilities
- Select "Runner" target
- Go to "Signing & Capabilities" tab
- **Team**: Select your Apple Developer Team
- **Bundle Identifier**: `com.aplay.a_play`
- **Signing Certificate**: Apple Distribution
- **Provisioning Profile**: App Store profile

### 3. General Settings
- **Display Name**: A Play
- **Bundle Identifier**: com.aplay.a_play
- **Version**: 0.1.0
- **Build**: 1
- **Deployment Target**: iOS 12.0 or higher

### 4. Required Capabilities
- [ ] In-App Purchase
- [ ] Push Notifications (if using)
- [ ] Sign in with Apple (if using)
- [ ] Associated Domains (for deep linking)

---

## 🚀 Upload to App Store Connect

### Method 1: Using Xcode (Recommended)
1. Archive the app: `Product > Archive`
2. When archive completes, click "Distribute App"
3. Select "App Store Connect"
4. Select "Upload"
5. Choose signing options (automatic recommended)
6. Review and upload

### Method 2: Using Transporter App
1. Build IPA: `flutter build ipa --release`
2. Locate IPA: `build/ios/ipa/a_play.ipa`
3. Open Transporter app
4. Drag and drop IPA file
5. Click "Deliver"

### Method 3: Using Command Line (altool)
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/a_play.ipa \
  --username "your-apple-id@email.com" \
  --password "your-app-specific-password"
```

---

## 📝 App Store Connect Metadata

### App Information
- **App Name**: A Play
- **Subtitle**: Ghana's Premier Event Discovery Platform
- **Primary Category**: Entertainment
- **Secondary Category**: Lifestyle

### Version Information (0.1.0)
- **What's New in This Version**:
```
Welcome to A Play v0.1.0!

NEW FEATURES:
• Instagram-style feed with square images
• Follow your favorite event bloggers
• Share posts with friends
• Random feed refresh for fresh content
• Post duration options (24hrs, 1 week, 1 month)
• Enhanced event discovery
• Improved user interface

IMPROVEMENTS:
• Faster app performance
• Better image loading
• Smoother navigation
• Bug fixes and stability improvements
```

### App Description
```
Discover and book the best events in Ghana with A Play!

FEATURES:
✓ Event Discovery - Find concerts, parties, club nights, and more
✓ Social Feed - Stay updated with event posts and announcements
✓ Follow Bloggers - Get updates from your favorite event organizers
✓ Table Booking - Reserve VIP tables at top venues
✓ Restaurant Reservations - Book tables at the best restaurants
✓ Concierge Services - Premium services for VIP members
✓ Chat - Connect with friends and plan events together

MEMBERSHIPS:
Choose from Bronze, Silver, Gold, or Platinum memberships for exclusive benefits and discounts.

PRIVACY & SECURITY:
Your data is protected with industry-standard encryption. We never share your information without permission.

Download A Play now and experience Ghana's nightlife like never before!
```

### Keywords
```
events, Ghana, nightlife, concerts, parties, clubs, entertainment, booking, tickets, VIP, restaurants
```

### Support URL
https://www.aplayworld.com/support

### Marketing URL
https://www.aplayworld.com

### Privacy Policy URL
https://www.aplayworld.com/privacy-policy

---

## 🔍 Pre-Submission Testing

### Device Testing
- [ ] Test on iPhone 12 or newer (recommended)
- [ ] Test on iOS 12.0 (minimum supported version)
- [ ] Test on latest iOS version
- [ ] Test on iPad (if supporting iPad)

### Feature Testing
- [ ] User authentication (email, Google)
- [ ] Event browsing and search
- [ ] Event booking flow
- [ ] In-app purchases (subscription tiers)
- [ ] Social feed (like, comment, share, follow)
- [ ] Location services
- [ ] Push notifications
- [ ] Deep linking
- [ ] Offline handling

### Performance Testing
- [ ] App launch time < 3 seconds
- [ ] Smooth scrolling (60 fps)
- [ ] Image loading performance
- [ ] Memory usage < 200MB
- [ ] Battery usage reasonable

---

## ⚠️ Common Issues & Solutions

### Issue 1: Code Signing Error
**Solution**:
1. Open Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your team
5. Enable "Automatically manage signing"

### Issue 2: Missing Provisioning Profile
**Solution**:
1. Go to Apple Developer Portal
2. Create App Store provisioning profile
3. Download and install
4. Refresh profiles in Xcode

### Issue 3: Build Failed - Missing Pods
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter build ios --release
```

### Issue 4: Archive Not Showing
**Solution**:
- Ensure you selected "Any iOS Device" as build target
- Don't use simulator for archiving
- Check scheme is set to "Release"

---

## 📊 Build Information

### Current Configuration
- **Flutter Version**: 3.1.3+
- **iOS Deployment Target**: 12.0+
- **Architecture**: arm64 (Apple Silicon + Intel)
- **Build Mode**: Release
- **Obfuscation**: Disabled (enable for production)

### To Enable Code Obfuscation (Recommended)
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

---

## ✅ Final Checklist Before Upload

- [ ] Version number updated to 0.1.0
- [ ] Build number is 1
- [ ] All tests passing
- [ ] No analyzer warnings
- [ ] Freezed code generated
- [ ] Info.plist permissions correct
- [ ] Signing configured
- [ ] IAP tested
- [ ] App Store metadata ready
- [ ] Screenshots prepared (6.5", 5.5")
- [ ] App icon set (1024x1024)
- [ ] Launch screen configured

---

## 📸 Required Screenshots

For App Store submission, you need:

**iPhone 6.7" (Pro Max)**:
- 1290 x 2796 pixels
- Minimum 3 screenshots
- Maximum 10 screenshots

**iPhone 5.5" (Plus)**:
- 1242 x 2208 pixels
- Minimum 3 screenshots

**Recommended Screenshots**:
1. Home screen with featured events
2. Event details page
3. Feed with Instagram-style posts
4. Booking confirmation
5. User profile/settings

---

## 🎉 Post-Upload Steps

After successful upload to App Store Connect:

1. **Wait for Processing** (5-30 minutes)
2. **Complete App Information**:
   - Add screenshots
   - Set pricing (Free with IAP)
   - Select age rating
   - Set release options
3. **Submit for Review**
4. **Monitor Review Status**
5. **Respond to Any Rejections** within 14 days

---

## 📞 Support & Resources

- **Flutter iOS Deployment**: https://docs.flutter.dev/deployment/ios
- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer Portal**: https://developer.apple.com
- **Xcode**: https://developer.apple.com/xcode/

---

## 🔄 Version History

| Version | Build | Date | Changes |
|---------|-------|------|---------|
| 0.1.0 | 1 | 2025-11-27 | Initial release with Instagram-style feed |

---

**Build Status**: ✅ Ready for Release

**Next Version**: 0.1.1 (for bug fixes) or 0.2.0 (for new features)
