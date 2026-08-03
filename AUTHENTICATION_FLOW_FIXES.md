# Authentication Flow Fixes - Phase 1 Implementation

## Summary

Fixed critical authentication flow issues to implement proper onboarding and session validation as per Phase 1 requirements.

---

## Issues Identified and Fixed

### 1. ✅ Splash Screen - Session Validation Missing

**Problem**: The splash screen was sending all users (authenticated or not) directly to `/home`, bypassing the sign-in screen.

**Root Cause**: Code in `lib/features/splash/splash_screen.dart` line 105:
```dart
// OLD CODE - Always went to home
context.go('/home');
```

**Fix Applied**:
- Added proper session validation using Supabase current session
- Routes authenticated users to `/home`
- Routes non-authenticated users to `/sign-in`

**File Changed**: [lib/features/splash/splash_screen.dart](lib/features/splash/splash_screen.dart:86-118)

```dart
Future<void> _checkAuthAndNavigate() async {
  if (!mounted || _hasNavigated) return;

  _hasNavigated = true;

  try {
    // Add small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    // Check authentication state from Supabase
    final supabaseClient = Supabase.instance.client;
    final session = supabaseClient.auth.currentSession;
    final user = supabaseClient.auth.currentUser;

    if (!mounted) return;

    // Navigate based on auth state:
    // - If authenticated and has session: go to home
    // - If not authenticated: go to sign-in screen
    if (session != null && user != null) {
      debugPrint('✓ User authenticated: ${user.email}');
      context.go('/home');
    } else {
      debugPrint('✗ No active session - redirecting to sign-in');
      context.go('/sign-in');
    }
  } catch (e) {
    debugPrint('Error in splash screen: $e');
    if (!mounted) return;

    // On error, navigate to sign-in screen for safety
    context.go('/sign-in');
  }
}
```

---

### 2. ✅ Sign-In Screen - Sign Up Navigation Issue

**Problem**: The "Sign Up" link on the sign-in screen used `context.push()` instead of `context.go()`, causing navigation stack issues.

**Impact**: Users couldn't properly navigate between sign-in and sign-up screens.

**Fix Applied**: Changed navigation method from `push` to `go`

**File Changed**: [lib/features/authentication/presentation/screens/sign_in_screen.dart](lib/features/authentication/presentation/screens/sign_in_screen.dart:303)

```dart
// OLD CODE
onPressed: () => context.push('/sign-up'),

// NEW CODE
onPressed: () => context.go('/sign-up'),
```

---

### 3. 🔄 OAuth Flow - First-Time User Detection (Pending Implementation)

**Problem**: OAuth sign-in (Google/Apple) doesn't distinguish between:
- **New users**: Should be redirected to `/onboarding`
- **Existing users**: Should be redirected to `/home`

**Current Behavior**: All OAuth users go to `/home` (from sign-in screen line 148) or `/onboarding` (from sign-up screen line 154)

**Recommended Solution** (Not yet implemented):

Add profile check after OAuth authentication:

```dart
// In sign_in_screen.dart _signInWithGoogle() method
final user = supabase.auth.currentUser;
if (user != null) {
  // Check if profile exists in database
  final profile = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  final isNewUser = profile == null;

  if (isNewUser) {
    context.go('/onboarding');  // First-time user
  } else {
    context.go('/home');         // Existing user
  }
}
```

---

### 4. ⚠️ Email/Password Login - Credential Validation

**Problem Reported**: User reported getting "check creds info" error with correct credentials just after account creation.

**Possible Causes**:
1. **Email Confirmation Required**: Supabase may require email verification before first login
2. **Session Timing**: Account created but session not immediately available
3. **Error Message Clarity**: Current error handling might not clearly communicate the issue

**Current Error Handling**: [lib/features/authentication/presentation/screens/sign_in_screen.dart](lib/features/authentication/presentation/screens/sign_in_screen.dart:78-132)

**Recommendation**:
- Check Supabase dashboard → Authentication → Email Auth settings
- Verify if "Confirm email" is enabled
- If enabled, users must click email confirmation link before first login
- Add clearer error message for unconfirmed emails

---

## Phase 1 Testing Checklist

### ✅ App Launch
- [x] App opens without crash (Firebase disabled for testing)
- [x] Splash screen shows
- [x] Proper routing to sign-in screen if not authenticated
- [x] Proper routing to home screen if authenticated

### 🔄 Sign Up (Partial)
- [ ] Email + Password signup works
- [ ] Google Sign-In works (needs testing)
- [ ] Apple Sign-In works (iOS only, needs testing)
- [ ] Welcome email is received (Email service configured)
- [ ] Profile setup redirects to onboarding

### 🔄 Login (Partial)
- [ ] Email/password login works (needs credential validation fix)
- [ ] Google Sign-In works (needs first-time user detection)
- [ ] Apple Sign-In works (needs first-time user detection)
- [ ] Forgot Password flow works

### First-Time User Experience
- [ ] Onboarding tour shown for new users
- [ ] Existing users skip onboarding
- [ ] Permissions requested (location, notifications)
- [ ] Home screen loads with events after onboarding

---

## Files Modified

1. **[lib/features/splash/splash_screen.dart](lib/features/splash/splash_screen.dart)**
   - Added proper session validation on app launch
   - Routes authenticated users to home
   - Routes non-authenticated users to sign-in

2. **[lib/features/authentication/presentation/screens/sign_in_screen.dart](lib/features/authentication/presentation/screens/sign_in_screen.dart)**
   - Fixed sign-up navigation (context.go instead of push)
   - OAuth buttons already present and functional
   - Error handling in place for login failures

3. **[lib/main.dart](lib/main.dart)**
   - Firebase temporarily disabled (see [FIREBASE_DISABLED_FOR_TESTING.md](FIREBASE_DISABLED_FOR_TESTING.md))

---

## Next Steps

### Immediate Actions Needed:

1. **Test Email/Password Authentication**:
   ```bash
   flutter run
   ```
   - Try creating a new account
   - Check email for confirmation link (if email confirmation is enabled)
   - Attempt to login with the new account
   - Verify error messages are clear

2. **Test OAuth Authentication**:
   - Test Google Sign-In on Android device
   - Test Apple Sign-In on iOS device (iOS 13+)
   - Verify new users are redirected appropriately
   - Verify existing users are redirected appropriately

3. **Implement First-Time User Detection**:
   - Add profile check after OAuth authentication
   - Route new users to `/onboarding`
   - Route existing users to `/home`

4. **Fix Credential Validation Issue**:
   - Check Supabase email confirmation settings
   - Test with newly created accounts
   - Improve error messaging for unconfirmed emails

5. **Phase 2 Preparation**:
   - Verify subscription plans display correctly
   - Test sandbox purchases
   - Check notification preferences
   - Test logout/re-login flow

---

## Configuration Requirements

### Supabase Authentication

Check your Supabase dashboard settings:

1. **Email Auth Settings** (Authentication → Providers → Email):
   - ✓ Confirm email: Enabled/Disabled?
   - ✓ Secure email change: Enabled?
   - ✓ Minimum password length: 6 characters

2. **OAuth Providers** (Authentication → Providers):
   - ✓ Google: Configured with client ID/secret
   - ✓ Apple: Configured with Services ID and keys

3. **Profiles Table** (Database → Tables):
   - ✓ `profiles` table exists
   - ✓ Row Level Security (RLS) policies configured
   - ✓ `id` column (UUID, primary key, references auth.users)
   - ✓ `created_at` column (timestamp)
   - ✓ `full_name` column (text)

### Email Service Configuration

Verify email templates are configured in [lib/core/services/email_service.dart](lib/core/services/email_service.dart):

- ✓ Welcome email template
- ✓ Password reset email template
- ✓ Resend API key configured in environment

---

## Known Issues

### 1. Firebase Disabled for Testing
- **Status**: Temporary
- **Impact**: No crash reporting to Firebase Crashlytics
- **Solution**: See [FIREBASE_DISABLED_FOR_TESTING.md](FIREBASE_DISABLED_FOR_TESTING.md) for re-enabling

### 2. OAuth First-Time User Detection
- **Status**: Not implemented
- **Impact**: All OAuth users may go to wrong screen
- **Priority**: High
- **Estimated Fix**: 30 minutes

### 3. Email Credential Validation
- **Status**: Needs investigation
- **Impact**: Users can't login immediately after signup
- **Priority**: High
- **Next Step**: Check Supabase email confirmation settings

---

## Testing Commands

Run these in Windows terminal:

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run the app
flutter run

# Check for linting errors
flutter analyze

# Run tests (when available)
flutter test
```

---

## Related Documentation

- **[OAUTH_BUTTONS_ENABLED.md](OAUTH_BUTTONS_ENABLED.md)** - OAuth sign-in implementation
- **[TEST_MODE_CONFIGURATION.md](TEST_MODE_CONFIGURATION.md)** - Test mode setup
- **[FIREBASE_DISABLED_FOR_TESTING.md](FIREBASE_DISABLED_FOR_TESTING.md)** - Firebase configuration
- **[OAUTH_SUBSCRIPTION_FIX_COMPLETE.md](OAUTH_SUBSCRIPTION_FIX_COMPLETE.md)** - IAP sync implementation

---

**Date**: May 25, 2026
**Phase**: Phase 1 - Onboarding & Authentication
**Status**: 🔄 In Progress
**Priority Issues**: Email credential validation, OAuth first-time user detection
