# Fix "PhaseScriptExecution failed with a nonzero exit code"

**Error:** `Command PhaseScriptExecution failed with a nonzero exit code`

This error occurs during iOS build phase scripts, often related to CocoaPods or build scripts.

---

## Solution Steps (Run in Order)

### Step 1: Increase File Limit First
```bash
# This must be done first to prevent "Too many open files" error
ulimit -n 10240
```

### Step 2: Clean All Build Artifacts
```bash
# Clean Flutter build
flutter clean

# Navigate to iOS directory
cd ios

# Remove Pods completely
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Go back to project root
cd ..
```

### Step 3: Reinstall CocoaPods Dependencies
```bash
cd ios

# Deintegrate pods
pod deintegrate

# Install fresh
pod install

# If pod install fails, try:
pod repo update
pod install --repo-update

cd ..
```

### Step 4: Rebuild Flutter
```bash
flutter pub get
flutter build ios --debug
```

---

## If Still Failing - Check Specific Error

The error message is generic. You need to see the actual error. Run:

```bash
cd ios
xcodebuild clean build -workspace Runner.xcworkspace -scheme Runner -configuration Debug | grep error
cd ..
```

Or open in Xcode to see detailed error:
```bash
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Product → Clean Build Folder (Shift+Cmd+K)
2. Product → Build (Cmd+B)
3. Check the error in the issue navigator (Cmd+5)

---

## Common Specific Causes and Fixes

### A. Firebase/Google Services Script Error

If error mentions `GoogleService-Info.plist`:

```bash
# Ensure file exists
ls -la ios/Runner/GoogleService-Info.plist

# If missing, copy from your Firebase console
# Download GoogleService-Info.plist and place it in ios/Runner/
```

### B. Code Signing Error

If error mentions provisioning or signing:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Ensure "Automatically manage signing" is checked
5. Select your Team

### C. Rive Package Build Error

If error mentions Rive or harfbuzz:

```bash
# The "too many open files" was likely causing this
# After increasing ulimit, try:
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
```

### D. Swift Version Mismatch

If error mentions Swift:

Add to `ios/Podfile` (after `platform :ios, '12.0'`):
```ruby
# Fix Swift version
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```

Then:
```bash
cd ios
pod install
cd ..
```

---

## Complete Clean Rebuild (Nuclear Option)

If nothing works:

```bash
# Increase file limit
ulimit -n 10240

# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/CocoaPods
rm -rf ~/.pub-cache

# Reinstall everything
flutter pub cache repair
flutter pub get

cd ios
pod cache clean --all
pod deintegrate
pod setup
pod install
cd ..

# Rebuild
flutter build ios --debug
```

---

## Quick Fix for Your Current Situation

Based on the "too many open files" error you just had, try this:

```bash
# 1. Set file limit
ulimit -n 10240

# 2. Clean and rebuild pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 3. Clean Flutter
flutter clean
flutter pub get

# 4. Try running
flutter run
```

---

## Verify File Limit

Make sure the file limit stuck:
```bash
ulimit -n
# Should show 10240 or higher
```

If it shows a lower number, you need to run `ulimit -n 10240` again in your current terminal session.

---

## Run from VS Code/Cursor

If running from VS Code/Cursor:

1. **Close VS Code/Cursor completely**
2. **Open Terminal**
3. **Set file limit:**
   ```bash
   ulimit -n 10240
   ```
4. **Launch VS Code from terminal:**
   ```bash
   cd /Users/abdulrazak/Documents/a-play-user-app
   code .
   ```
   Or for Cursor:
   ```bash
   cursor .
   ```

This ensures the IDE inherits the increased file limit.

---

## Recommended Next Steps

1. **Set file limit:** `ulimit -n 10240`
2. **Clean build:** `flutter clean && cd ios && rm -rf Pods Podfile.lock && pod install && cd ..`
3. **Get dependencies:** `flutter pub get`
4. **Run:** `flutter run`

If you still get errors, run the build in Xcode to see the specific error message:
```bash
open ios/Runner.xcworkspace
```
