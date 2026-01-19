# How to Run App on iOS Simulator

## Current Status
✅ File limit increased to 10240
✅ Flutter cleaned
✅ iOS artifacts removed
✅ CocoaPods deintegrated
✅ Flutter dependencies fetched
🔄 CocoaPods installing (in progress)

---

## Option 1: Wait for Pod Install to Complete

The `pod install` command is currently running in the background. This typically takes 2-5 minutes.

Once it completes, you'll see output like:
```
Pod installation complete! There are X dependencies from the Podfile and Y total pods installed.
```

Then run:
```bash
flutter run
```

---

## Option 2: Run Manually (If Background Process Stalls)

If the pod install seems stuck, open a **NEW TERMINAL WINDOW** and run:

```bash
# 1. Set file limit
ulimit -n 10240

# 2. Navigate to project
cd /Users/abdulrazak/Documents/a-play-user-app

# 3. Navigate to ios directory
cd ios

# 4. Install pods (if not already complete)
pod install

# 5. Go back to project root
cd ..

# 6. List available simulators
flutter devices

# 7. Run on simulator
flutter run
```

---

## Option 3: Open in Xcode (For Better Error Messages)

If `flutter run` fails, open in Xcode to see detailed error:

```bash
# Navigate to project
cd /Users/abdulrazak/Documents/a-play-user-app

# Open workspace in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select a simulator from the top bar (e.g., iPhone 15 Pro)
2. Click the Play button (▶️) or press Cmd+R
3. If errors occur, check the Issue Navigator (Cmd+5)

---

## Common Issues and Fixes

### Issue: "Too many open files"
**Fix:**
```bash
ulimit -n 10240
```

### Issue: Pod install fails
**Fix:**
```bash
cd ios
pod cache clean --all
pod deintegrate
pod install
cd ..
```

### Issue: Xcode build fails with signing error
**Fix:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Check "Automatically manage signing"
5. Select your Team

### Issue: Simulator not found
**Fix:**
```bash
# List available simulators
xcrun simctl list devices available

# Open simulator manually
open -a Simulator

# Then run flutter
flutter run
```

---

## Quick Commands Reference

```bash
# Check file limit
ulimit -n

# List Flutter devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release

# Run with verbose output
flutter run -v

# Clean and rebuild
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run
```

---

## Expected Success Output

When everything works, you should see:

```
Launching lib/main.dart on iPhone 15 Pro in debug mode...
Running pod install...
Running Xcode build...
Xcode build done.                                            XX.Xs
Installing and launching...
Syncing files to device iPhone 15 Pro...
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on iPhone 15 Pro is available at: http://127.0.0.1:XXXXX/XXXXXXX=/
The Flutter DevTools debugger and profiler on iPhone 15 Pro is available at:
http://127.0.0.1:9100?uri=http://127.0.0.1:XXXXX/XXXXXXX=/
```

---

## Testing the iPad Air Fixes

Once the app runs, test these scenarios:

### 1. Feed Tab
- ✅ Tap Feed tab
- ✅ Verify no LateInitializationError
- ✅ Try liking a post while feed loads

### 2. Bookings Tab (Guest Mode)
- ✅ Tap "Continue as Guest" on sign-in
- ✅ Go to Bookings tab
- ✅ Should see "Sign in Required" with lock icon
- ✅ Tap "Sign In" button

### 3. Explore Tab
- ✅ Navigate to Explore tab
- ✅ Events should load
- ✅ Try different categories
- ✅ No technical errors visible

---

## Next Step

**Wait for pod install to complete**, then run:

```bash
flutter run
```

If you need to check pod install status, look for the output in your terminal or run:
```bash
ps aux | grep "pod install"
```

If the process completed, you should see the Podfile.lock and Pods directory in the ios folder.
