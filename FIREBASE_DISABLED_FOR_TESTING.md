# Firebase Temporarily Disabled for Testing

## Issue

The app was crashing on launch with the following error:

```
Thread 1: "Configuration fails. It may be caused by an invalid GOOGLE_APP_ID in GoogleService-Info.plist or set in the customized options."
```

## Root Cause

The Firebase iOS SDK (`FIRApp.m`) validates the `GOOGLE_APP_ID` from `GoogleService-Info.plist` during initialization. The validation happens synchronously in native code before the Dart try-catch block can catch the error, causing the app to crash.

**Technical Details:**
- The error originates from `FIRApp.m` line 286-291 in the `addAppToAppDictionary` method
- The `configureCore` method returns `NO` when `GOOGLE_APP_ID` is invalid
- This throws an `NSException` that cannot be caught by Dart error handlers
- The app has no `GoogleService-Info.plist` file configured

## Solution Applied

Firebase and Crashlytics have been **temporarily disabled** to allow the app to run during testing without proper Firebase configuration.

### Changes Made to [lib/main.dart](lib/main.dart)

**1. Commented Out Firebase Imports:**
```dart
// Firebase temporarily disabled for testing - uncomment when GoogleService-Info.plist is configured
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:a_play/firebase_options.dart';
```

**2. Disabled Firebase Initialization:**
```dart
// Firebase temporarily disabled for testing
// TODO: Re-enable when GoogleService-Info.plist is properly configured
/*
// Initialize Firebase with error handling
try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ... Crashlytics setup ...
} catch (e) {
  // Error handling ...
}
*/

if (kDebugMode) {
  debugPrint('ℹ️ Firebase/Crashlytics disabled for testing');
}
```

**3. Disabled Crashlytics Error Reporting:**
```dart
}, (error, stackTrace) {
  // Firebase/Crashlytics temporarily disabled for testing
  /*
  // Crashlytics error recording code...
  */

  // Log error to console
  if (kDebugMode) {
    debugPrint('App initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');
  }
```

## Impact

### What Still Works ✅
- **Core App Functionality**: Authentication, navigation, booking, payments
- **Supabase Backend**: All database and auth operations
- **PayStack Payments**: Test and live payment processing
- **OAuth Sign-In**: Google and Apple authentication
- **IAP Subscriptions**: In-app purchase synchronization
- **Local Error Logging**: Console logs for debugging

### What's Disabled ⚠️
- **Firebase Crashlytics**: No automatic crash reporting to Firebase console
- **Firebase Analytics**: No analytics events tracked (if configured)
- **Remote Error Tracking**: Errors only logged to console, not sent to cloud

## When to Re-Enable Firebase

Firebase should be re-enabled when you have a valid `GoogleService-Info.plist` file properly configured.

### Prerequisites

1. **Firebase Project Setup**:
   - Create/access Firebase project at https://console.firebase.google.com/
   - Add iOS app to your Firebase project
   - Register with correct bundle identifier (matches Xcode project)
   - Register Android app (if applicable)

2. **Download Configuration Files**:
   - **iOS**: Download `GoogleService-Info.plist`
   - **Android**: Download `google-services.json`

3. **Add Files to Project**:
   - **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/` directory
   - **Android**: Place `google-services.json` in `android/app/` directory

4. **Verify Configuration**:
   - Ensure `GOOGLE_APP_ID` is present and valid
   - Ensure `BUNDLE_ID` matches your app's bundle identifier
   - For Android, ensure `package_name` matches `applicationId`

### Steps to Re-Enable

1. **Uncomment Firebase Imports** in [lib/main.dart](lib/main.dart):
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';
   import 'package:a_play/firebase_options.dart';
   ```

2. **Uncomment Firebase Initialization** (around line 32-56):
   ```dart
   // Initialize Firebase with error handling
   try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     if (!kIsWeb) {
       FlutterError.onError = (details) {
         FirebaseCrashlytics.instance.recordFlutterFatalError(details);
       };

       PlatformDispatcher.instance.onError = (error, stack) {
         FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
         return true;
       };
     }
   } catch (e) {
     // Firebase initialization failed - continue without Firebase
     if (kDebugMode) {
       debugPrint('⚠️ Firebase initialization failed: $e');
       debugPrint('⚠️ App will run without Firebase/Crashlytics');
     }
   }
   ```

3. **Uncomment Crashlytics Error Handler** (around line 91-104):
   ```dart
   // Try to record error in Crashlytics if available
   if (!kIsWeb) {
     try {
       FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
     } catch (e) {
       if (kDebugMode) {
         debugPrint('Could not record error to Crashlytics: $e');
       }
     }
   }
   ```

4. **Remove Debug Print Statement**:
   ```dart
   // Remove this line:
   if (kDebugMode) {
     debugPrint('ℹ️ Firebase/Crashlytics disabled for testing');
   }
   ```

5. **Regenerate Firebase Options** (if needed):
   ```bash
   # Install FlutterFire CLI if not already installed
   dart pub global activate flutterfire_cli

   # Configure Firebase for your project
   flutterfire configure
   ```

6. **Test Firebase Initialization**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

7. **Verify in Firebase Console**:
   - Check that app appears in Firebase console
   - Monitor Crashlytics for crash reports
   - Verify analytics events (if enabled)

## Alternative: Keep Firebase Disabled

If you don't need Firebase/Crashlytics features, you can keep it disabled permanently by:

1. Removing Firebase dependencies from `pubspec.yaml`:
   ```yaml
   # Remove or comment out:
   firebase_core: ^x.x.x
   firebase_crashlytics: ^x.x.x
   ```

2. Running `flutter pub get` to update dependencies

3. Removing the commented Firebase code entirely from `main.dart`

## Testing Status

- ✅ App launches successfully without Firebase
- ✅ OAuth authentication works (Google/Apple Sign-In)
- ✅ PayStack test payments functional
- ✅ Supabase backend operations working
- ✅ All features enabled for testing (restaurants, clubs, podcasts, referrals)

## Related Documentation

- **[OAUTH_BUTTONS_ENABLED.md](OAUTH_BUTTONS_ENABLED.md)** - OAuth implementation details
- **[TEST_MODE_CONFIGURATION.md](TEST_MODE_CONFIGURATION.md)** - Test mode setup
- **[OAUTH_SUBSCRIPTION_FIX_COMPLETE.md](OAUTH_SUBSCRIPTION_FIX_COMPLETE.md)** - OAuth + IAP sync implementation

## Support Resources

- **Firebase iOS Setup**: https://firebase.google.com/docs/ios/setup
- **Firebase Android Setup**: https://firebase.google.com/docs/android/setup
- **FlutterFire Documentation**: https://firebase.flutter.dev/docs/overview
- **Firebase Console**: https://console.firebase.google.com/

---

**Date**: May 25, 2026
**Status**: ⚠️ Firebase Temporarily Disabled
**Action Required**: Configure Firebase when ready to use Crashlytics and Analytics
