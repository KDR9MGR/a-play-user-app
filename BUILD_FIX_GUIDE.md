# iOS Build Error Fix Guide

## Error: "Command PhaseScriptExecution failed with a nonzero exit code"

This is a common iOS build error. Follow these steps to resolve it:

---

## Solution 1: Clean & Rebuild (Most Common Fix)

Run these commands in **Windows Terminal** (in order):

```bash
# Navigate to project
cd E:\path\to\a-play-user-app-main

# 1. Clean Flutter build
flutter clean

# 2. Clean iOS build cache
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# 3. Reinstall pods
pod deintegrate
pod repo update
pod install --repo-update

# 4. Go back to project root
cd ..

# 5. Get dependencies
flutter pub get

# 6. Try building again
flutter build ios --release
```

---

## Solution 2: Check for Missing Dependencies

The error might be due to missing dependencies. Make sure you ran:

```bash
flutter pub get
```

If you see any errors, try:

```bash
flutter pub get --verbose
```

---

## Solution 3: Check Code Syntax Errors

Run Flutter analyzer to check for any code errors:

```bash
flutter analyze
```

If you see any **errors** (not warnings), those need to be fixed first.

---

## Solution 4: Xcode-Specific Fixes

If using Xcode directly:

1. **Open Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Clean Build Folder**
   - In Xcode menu: Product → Clean Build Folder (Cmd + Shift + K)

3. **Check Build Settings**
   - Select Runner → Build Settings
   - Search for "ENABLE_BITCODE"
   - Set to "No"

4. **Check Signing**
   - Select Runner → Signing & Capabilities
   - Ensure "Automatically manage signing" is checked
   - Select your Team

5. **Try Building from Xcode**
   - Product → Build (Cmd + B)
   - Check the error log in the Report Navigator

---

## Solution 5: Check for Code Issues

Based on the changes we made, check these files for syntax errors:

1. **Check cancel_booking_screen.dart**
   ```bash
   flutter analyze lib/features/booking/screens/cancel_booking_screen.dart
   ```

2. **Check booking_service.dart**
   ```bash
   flutter analyze lib/features/booking/service/booking_service.dart
   ```

3. **Check my_tickets_screen.dart**
   ```bash
   flutter analyze lib/features/booking/screens/my_tickets_screen.dart
   ```

---

## Solution 6: iOS Deployment Target

If the error mentions deployment target:

1. Open `ios/Podfile`
2. Find this line:
   ```ruby
   # platform :ios, '12.0'
   ```
3. Change to:
   ```ruby
   platform :ios, '13.0'
   ```
4. Save and run:
   ```bash
   cd ios
   pod install
   cd ..
   flutter clean
   flutter build ios
   ```

---

## Solution 7: Check Info.plist

Make sure the Info.plist changes for OneSignal are correct:

**File: ios/Runner/Info.plist**

Should have these keys (before `</dict>`):

```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>

<key>OSNotificationDisplayType</key>
<string>notification</string>
```

**Important:** Make sure there are NO syntax errors (missing `<`, `>`, etc.)

---

## Quick Diagnostic

Run this to see what's failing:

```bash
flutter doctor -v
```

Look for any issues with:
- [x] Flutter (should be installed)
- [x] Xcode (should be installed)
- [x] CocoaPods (should be installed)
- [x] iOS toolchain

---

## Still Having Issues?

### Get Detailed Error Log

1. **Run with verbose logging:**
   ```bash
   flutter build ios --verbose
   ```

2. **Copy the full error message** and share it

3. **Or build from Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   Then: Product → Build

   Check the full error in Xcode's Report Navigator (View → Navigators → Show Report Navigator)

---

## Common Error Messages & Fixes

### "Code Signing Error"
- Fix: Check Xcode → Runner → Signing & Capabilities
- Enable "Automatically manage signing"

### "Module not found"
- Fix: Run `cd ios && pod install && cd ..`

### "Build input file cannot be found"
- Fix: Run full clean sequence (Solution 1)

### "Multiple commands produce"
- Fix: Check for duplicate files in Xcode project

---

## After Fixing

Once the build succeeds, test the app:

```bash
# Run on simulator
flutter run

# Or run on physical device
flutter run -d <device-id>
```

---

## Need More Help?

If none of these work, please share:
1. Full error message from `flutter build ios --verbose`
2. Output of `flutter doctor -v`
3. Xcode version: `xcodebuild -version`
