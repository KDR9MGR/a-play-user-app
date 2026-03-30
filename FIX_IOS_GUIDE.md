# Fix iOS Build Issues - Quick Guide

## 🔴 The Error You're Seeing

```
Command PhaseScriptExecution failed with a nonzero exit code
```

This error typically happens when:
1. Flutter Generated.xcconfig is missing
2. CocoaPods are not installed correctly
3. Build cache is corrupted

---

## 🚀 Quick Fix (Recommended)

### Option 1: Run Automated Fix Script
```bash
./fix_ios_build.sh
```

This script will:
1. ✅ Clean Flutter build
2. ✅ Get dependencies
3. ✅ Generate Freezed models
4. ✅ Clean iOS cache
5. ✅ Deintegrate pods
6. ✅ Reinstall pods
7. ✅ Verify .env file
8. ✅ Run analyzer

### Option 2: Manual Fix (Step-by-Step)

```bash
# 1. Clean Flutter
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Generate Freezed code
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. Clean iOS pods
cd ios
rm -rf Pods Podfile.lock .symlinks
pod deintegrate
pod install --repo-update
cd ..

# 5. Run the app
flutter run
```

---

## 📱 Running the App

### For Development (Debug Mode)
```bash
flutter run
```

### For iOS Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

### For Physical Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### For Release Build
```bash
flutter build ios --release
```

---

## 🔍 Common Issues & Solutions

### Issue 1: "Generated.xcconfig must exist"
**Solution:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### Issue 2: "CocoaPods not installed"
**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Then reinstall pods
cd ios
pod install
cd ..
```

### Issue 3: "No valid code signing certificates"
**Solution:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your Apple Developer Team
5. Enable "Automatically manage signing"

### Issue 4: "Build input file cannot be found"
**Solution:**
```bash
cd ios
rm -rf build
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Issue 5: "Freezed errors"
**Solution:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Issue 6: ".env file not found"
**Solution:**
The .env file exists at project root with:
```
SUPABASE_URL=https://yvnfhsipyfxdmulajbgl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
PAYSTACK_PUBLIC_KEY=pk_live_...
PAYSTACK_SECRET_KEY=sk_live_...
```

---

## 🎯 Recommended Steps (In Order)

1. **Run the fix script**:
   ```bash
   ./fix_ios_build.sh
   ```

2. **Generate Freezed models** (if not done):
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **If still failing**, open in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   Then: Product → Clean Build Folder → Product → Run

---

## ⚙️ Xcode Configuration

If you need to open in Xcode:

```bash
open ios/Runner.xcworkspace
```

**Important Xcode Settings:**

1. **Signing**:
   - Target: Runner
   - Tab: Signing & Capabilities
   - Team: Select your team
   - Bundle Identifier: com.aplay.a_play

2. **Build Settings**:
   - iOS Deployment Target: 15.0
   - Architecture: arm64

3. **General**:
   - Display Name: A Play
   - Version: 0.1.0
   - Build: 1

---

## 🧪 Testing Checklist

After fixing, test these:

- [ ] App launches successfully
- [ ] No build errors in console
- [ ] Images display correctly (square aspect ratio)
- [ ] Feed loads and refreshes
- [ ] Like/comment/share works
- [ ] Follow/unfollow works
- [ ] No crashes

---

## 📊 Environment Verification

Check your environment:

```bash
# Flutter version
flutter --version

# Flutter doctor
flutter doctor -v

# CocoaPods version
pod --version

# Xcode version
xcodebuild -version
```

**Required Versions:**
- Flutter: 3.1.3+
- CocoaPods: 1.11.0+
- Xcode: 14.0+
- iOS Deployment: 15.0+

---

## 🆘 If Nothing Works

Try this nuclear option:

```bash
# WARNING: This removes everything and starts fresh

# 1. Remove all Flutter artifacts
flutter clean
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# 2. Remove all iOS artifacts
cd ios
rm -rf Pods
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm Podfile.lock
cd ..

# 3. Reinstall everything
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
cd ios
pod deintegrate
pod cache clean --all
pod install --repo-update
cd ..

# 4. Try running
flutter run
```

---

## 📝 Build Logs

If you still have issues, check the logs:

```bash
# Verbose build output
flutter run -v

# Build for iOS with logs
flutter build ios --release -v
```

---

## ✅ Success Indicators

You'll know it's fixed when you see:

```
Launching lib/main.dart on iPhone in debug mode...
Running Xcode build...
Xcode build done.                                           XX.Xs
Syncing files to device iPhone...
```

---

## 🔗 Useful Commands

```bash
# Clean everything
flutter clean && cd ios && pod deintegrate && pod install && cd ..

# Quick rebuild
flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs

# Run on iOS
flutter run

# List all devices
flutter devices

# Build for release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

---

## 📞 Additional Help

- **Flutter iOS Docs**: https://docs.flutter.dev/deployment/ios
- **CocoaPods**: https://cocoapods.org
- **Flutter Doctor**: `flutter doctor -v`

---

**Quick Start**: Run `./fix_ios_build.sh` and then `flutter run`
