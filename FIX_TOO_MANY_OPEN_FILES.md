# Fix "Too many open files in system" Error

**Error:** `cannot open file: Too many open files in system`

This is a macOS system limit issue that occurs during Flutter builds when the number of open file descriptors exceeds the default limit.

---

## Quick Fix (Temporary - Current Session Only)

Run these commands in your terminal:

```bash
# Check current limits
ulimit -n

# Increase the limit for current session
ulimit -n 10240

# Now run your Flutter command
flutter clean
flutter pub get
flutter run
```

---

## Permanent Fix (Recommended)

### Option 1: Create Launch Daemon Configuration

1. **Create the plist file:**

```bash
sudo nano /Library/LaunchDaemons/limit.maxfiles.plist
```

2. **Paste this configuration:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>65536</string>
      <string>200000</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>
```

3. **Save and exit** (Ctrl+X, then Y, then Enter)

4. **Set proper permissions:**

```bash
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chmod 644 /Library/LaunchDaemons/limit.maxfiles.plist
```

5. **Load the configuration:**

```bash
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
```

6. **Restart your Mac** for changes to take effect

---

### Option 2: Use Shell Profile Configuration

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
# Add these lines
ulimit -n 10240
ulimit -u 2048
```

Then reload your shell:

```bash
source ~/.zshrc  # or source ~/.bash_profile
```

---

## After Fixing the Limit

Once you've increased the file limit, run these commands:

```bash
# Clean Flutter cache and build artifacts
flutter clean

# Close any running simulators/emulators
# (Use Xcode -> Quit, Android Studio -> Close all)

# Restart your IDE (VS Code, Android Studio, etc.)

# Get dependencies again
flutter pub get

# Run the app
flutter run
```

---

## Alternative: Close Unnecessary Applications

Sometimes this error occurs because you have many applications open. Try:

1. **Close unused applications:**
   - Quit Xcode if you have multiple instances
   - Quit Android Studio
   - Close unused terminal windows
   - Restart your IDE (VS Code/Cursor)

2. **Check for file descriptor leaks:**

```bash
# See which processes are using many file descriptors
lsof | awk '{print $1}' | sort | uniq -c | sort -rn | head

# Kill any hung Dart/Flutter processes
pkill -9 dart
pkill -9 flutter
```

3. **Clean Flutter cache:**

```bash
flutter clean
rm -rf ~/Library/Caches/flutter
flutter doctor
```

---

## Verify the Fix

After applying the fix, verify the new limit:

```bash
ulimit -n
# Should show 10240 or higher
```

Then try building again:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Why This Happens

Flutter builds on macOS open many files simultaneously:
- Source files (.dart)
- Generated files
- Build artifacts
- Pub cache files
- Native iOS/Android files
- Rive animation files (in your case)

The default macOS limit (256-1024) is often too low for large Flutter projects.

---

## Recommended Solution for Your Project

Since you're getting this error with the Rive package, I recommend:

1. **Increase file limit** (using Option 1 above)
2. **Clean and rebuild:**

```bash
ulimit -n 10240
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
cd ios && pod deintegrate && pod install && cd ..
flutter pub get
flutter run
```

This will ensure the Rive package can build properly with all its native dependencies.
