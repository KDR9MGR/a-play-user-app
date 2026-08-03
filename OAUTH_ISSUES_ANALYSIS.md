# OAuth Authentication Issues - Analysis & Fixes

**Date:** May 30, 2026
**Status:** ⚠️ **CRITICAL ISSUES FOUND**

---

## Issues Identified

### 1. **Session Persistence After Account Deletion** 🔴 **CRITICAL**

**What Happened:**
- User signed in with Google OAuth
- Account was deleted from Supabase Auth table
- User signed in again with same Google account
- App resumed session and went straight to home screen

**Root Cause:**

#### Issue A: Supabase Auth vs. Profiles Table Mismatch
When you delete a user from `auth.users` table in Supabase Dashboard:
1. ✅ Auth session is deleted
2. ✅ Auth user is deleted
3. ❌ **Profile remains in `profiles` table** (orphaned record)
4. ❌ **Subscription remains in `user_subscriptions` table** (orphaned record)

When user signs in again with OAuth:
1. Supabase Auth creates **NEW** auth.users record (different UUID)
2. Database trigger `handle_new_user()` tries to create profile
3. Profile insert fails if email already exists (orphaned from old account)
4. **App sees auth session and allows access** despite missing/invalid profile

#### Issue B: No Profile Validation in OAuth Flow
Current OAuth flow in [auth_provider.dart:140-212](lib/features/authentication/presentation/providers/auth_provider.dart#L140-L212):
```dart
// signInWithGoogle() - Lines 140-212
final authResponse = await _client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
);

// ❌ NO PROFILE CHECK HERE
// Just sets state and continues
state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
```

**Missing:**
- No check if profile exists in database
- No check if profile is valid
- No welcome email for new OAuth users
- No onboarding redirect for new users

---

### 2. **OAuth Flow Doesn't Check Database** 🔴 **CRITICAL**

**Current Flow:**
```
Google Sign-In
  ↓
Supabase Auth (creates auth.users record)
  ↓
Database Trigger (tries to create profile)
  ↓
❌ NO VALIDATION IN APP CODE
  ↓
User goes to /home (even if profile creation failed)
```

**Expected Flow:**
```
Google Sign-In
  ↓
Supabase Auth (creates auth.users record)
  ↓
Database Trigger (tries to create profile)
  ↓
✅ APP CHECKS: Does profile exist?
  ├─ YES → Check if new user (created < 10 sec ago)
  │         ├─ NEW → Send welcome email + Go to /onboarding
  │         └─ EXISTING → Go to /home
  └─ NO → Handle error (profile creation failed)
            ↓
            Create profile manually
            ↓
            Send welcome email
            ↓
            Go to /onboarding
```

---

### 3. **Welcome Email Not Sent for OAuth Users** 🟡 **IMPORTANT**

**Current Behavior:**
- Email/password sign-up: ✅ Sends welcome email ([auth_provider.dart:376-389](lib/features/authentication/presentation/providers/auth_provider.dart#L376-L389))
- Google OAuth: ❌ NO welcome email
- Apple OAuth: ❌ NO welcome email

**Why:**
Welcome email only sent in `signUpWithEmail()` method, not in OAuth methods.

---

### 4. **Password Reset Email for OAuth Users** 🟢 **INFO**

**Question:** Should OAuth users receive password reset emails?

**Answer:** **NO** - OAuth users don't have passwords in Supabase Auth.

**OAuth User Authentication:**
- Google/Apple users authenticate via OAuth provider
- No password stored in Supabase
- Password reset not applicable

**However:**
- User CAN set a password later in their profile settings
- Once password is set, they can use password reset

---

## Root Cause Summary

### Database Trigger Issue:
The `handle_new_user()` trigger in [02_functions_triggers.sql:64-96](supabase/migrations/02_functions_triggers.sql#L64-L96) can fail if:
1. Email already exists in profiles (orphaned from deleted account)
2. Constraint violations
3. RLS policies block insert

**When it fails:**
- Auth user is created ✅
- Profile is NOT created ❌
- App doesn't detect the failure ❌
- User proceeds to home screen with incomplete setup ❌

### Router Only Checks Auth, Not Profile:
[router.dart:38-42](lib/config/router.dart#L38-L42):
```dart
RouterNotifier(this._ref) : isAuth = Supabase.instance.client.auth.currentUser != null {
  _ref.listen<AsyncValue<UserModel?>>(authStateProvider, (_, next) {
    isAuth = next.value != null;  // ❌ Only checks auth, not profile existence
    notifyListeners();
  });
}
```

---

## Recommended Fixes

### Fix 1: Add Profile Validation to OAuth Methods ⭐ **HIGH PRIORITY**

Modify both `signInWithGoogle()` and `signInWithApple()` in [auth_provider.dart](lib/features/authentication/presentation/providers/auth_provider.dart):

```dart
Future<void> signInWithGoogle() async {
  try {
    // ... existing Google sign-in code ...

    final user = authResponse.user;
    if (user == null) {
      throw const AuthException('Failed to sign in with Google - no user returned');
    }

    // ✅ NEW: Check if profile exists and is valid
    final profile = await _client
        .from('profiles')
        .select('id, email, full_name, created_at')
        .eq('id', user.id)
        .maybeSingle();

    bool isNewUser = false;

    if (profile == null) {
      // Profile doesn't exist - create it manually
      debugPrint('🔵 [AUTH-PROVIDER] ⚠ No profile found, creating manually');

      try {
        await _client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] ??
                       user.userMetadata?['name'] ??
                       user.email?.split('@')[0],
          'created_at': DateTime.now().toIso8601String(),
        });

        isNewUser = true;
        debugPrint('🔵 [AUTH-PROVIDER] ✓ Profile created manually');
      } catch (e) {
        debugPrint('🔵 [AUTH-PROVIDER] ✗ Failed to create profile: $e');
        throw AuthException('Failed to create user profile: ${e.toString()}');
      }
    } else {
      // Profile exists - check if it's a new user
      final createdAt = DateTime.parse(profile['created_at'] as String);
      isNewUser = createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 30)));
      debugPrint('🔵 [AUTH-PROVIDER] Profile found, isNewUser: $isNewUser');
    }

    // ✅ NEW: Send welcome email for new OAuth users
    if (isNewUser) {
      try {
        final userName = user.userMetadata?['full_name'] ??
                        user.userMetadata?['name'] ??
                        user.email?.split('@')[0] ??
                        'there';

        await EmailService().sendWelcomeEmail(
          toEmail: user.email!,
          userName: userName,
        );
        debugPrint('🔵 [AUTH-PROVIDER] ✓ Welcome email sent');
      } catch (e) {
        debugPrint('🔵 [AUTH-PROVIDER] ⚠ Failed to send welcome email (non-critical): $e');
        // Don't block authentication if email fails
      }
    }

    // Link to OneSignal...
    // ... rest of existing code
  }
}
```

**Apply same fix to `signInWithApple()` method.**

---

### Fix 2: Update Sign-In Screen OAuth Handlers ⭐ **HIGH PRIORITY**

Modify [sign_in_screen.dart:154-216](lib/features/authentication/presentation/screens/sign_in_screen.dart#L154-L216):

```dart
Future<void> _signInWithGoogle() async {
  setState(() => _isGoogleLoading = true);

  try {
    debugPrint('🔵 [GOOGLE] Starting Google sign-in');
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    debugPrint('🔵 [GOOGLE] Sign-in completed, checking user status');

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      // ✅ UPDATED: Check profile existence and validity
      final profile = await supabase
          .from('profiles')
          .select('id, created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        // Profile doesn't exist - this shouldn't happen after auth_provider fix
        // But handle it just in case
        debugPrint('🔵 [GOOGLE] ✗ No profile found after sign-in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account setup incomplete. Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      debugPrint('🔵 [GOOGLE] Profile found: ${profile['id']}');

      // Check if new user (created within last 30 seconds)
      final isNewUser = profile['created_at'] != null &&
          DateTime.parse(profile['created_at'] as String)
              .isAfter(DateTime.now().subtract(const Duration(seconds: 30)));

      debugPrint('🔵 [GOOGLE] Is new user: $isNewUser');

      if (isNewUser) {
        debugPrint('🔵 [GOOGLE] Navigating to /onboarding');
        context.go('/onboarding');
      } else {
        debugPrint('🔵 [GOOGLE] Navigating to /home');
        context.go('/home');
      }
    }
  } catch (e) {
    debugPrint('🔵 [GOOGLE] ✗ Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isGoogleLoading = false);
  }
}
```

**Apply same fix to:**
- `_signInWithApple()` in sign_in_screen.dart
- `_signUpWithGoogle()` in sign_up_screen.dart
- `_signUpWithApple()` in sign_up_screen.dart

---

### Fix 3: Clean Up Orphaned Profiles Script 🔧 **MAINTENANCE**

Create cleanup script for orphaned profiles:

```sql
-- Find orphaned profiles (profiles without auth.users)
SELECT p.id, p.email, p.created_at
FROM profiles p
LEFT JOIN auth.users u ON p.id = u.id
WHERE u.id IS NULL;

-- Delete orphaned profiles (RUN WITH CAUTION)
DELETE FROM profiles
WHERE id NOT IN (SELECT id FROM auth.users);

-- Delete orphaned subscriptions
DELETE FROM user_subscriptions
WHERE user_id NOT IN (SELECT id FROM auth.users);
```

---

### Fix 4: Improve Database Trigger 🔧 **OPTIONAL**

Update `handle_new_user()` trigger to handle email conflicts:

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if email already exists (orphaned profile)
  IF EXISTS (SELECT 1 FROM profiles WHERE email = NEW.email AND id != NEW.id) THEN
    -- Delete orphaned profile
    DELETE FROM profiles WHERE email = NEW.email AND id != NEW.id;
  END IF;

  -- Insert new profile
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NEW.email)
  )
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email,
      full_name = COALESCE(EXCLUDED.full_name, profiles.full_name);

  -- Create free subscription
  INSERT INTO user_subscriptions (
    user_id,
    plan_id,
    tier,
    billing_cycle,
    start_date,
    end_date,
    referral_code
  )
  VALUES (
    NEW.id,
    'free-tier',
    'Free',
    'lifetime',
    NOW(),
    NOW() + INTERVAL '100 years',
    'REF' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8))
  )
  ON CONFLICT (user_id, plan_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Testing Checklist

### OAuth Flow Testing:
- [ ] Delete test account from Supabase Auth
- [ ] Sign in with Google OAuth
- [ ] Verify profile created in database
- [ ] Verify welcome email received
- [ ] Verify redirect to onboarding (new user)
- [ ] Sign out and sign in again
- [ ] Verify redirect to home (existing user)
- [ ] Verify NO welcome email on second sign-in

### Apple OAuth:
- [ ] Same tests as Google OAuth above

### Error Handling:
- [ ] Test with invalid OAuth credentials
- [ ] Test with network error during profile check
- [ ] Test with orphaned profile (email conflict)

---

## Summary of Issues

| Issue | Severity | Impact | Fix Priority |
|-------|----------|--------|--------------|
| Session persistence after deletion | 🔴 Critical | Security risk, data inconsistency | HIGH |
| No profile validation in OAuth | 🔴 Critical | Broken user experience | HIGH |
| No welcome email for OAuth | 🟡 Important | Poor onboarding experience | MEDIUM |
| Password reset for OAuth | 🟢 Info | N/A (OAuth users don't have passwords) | N/A |

---

## Recommended Action Plan

### Immediate (Today):
1. ✅ **Apply Fix 1:** Add profile validation to OAuth methods (30 min)
2. ✅ **Apply Fix 2:** Update OAuth handlers in sign-in/sign-up screens (30 min)
3. ✅ **Test:** End-to-end OAuth flow with account deletion scenario (30 min)

### Short-term (This Week):
4. **Apply Fix 3:** Run cleanup script to remove orphaned profiles (15 min)
5. **Apply Fix 4:** Update database trigger for better error handling (30 min)

**Total Time:** ~2.5 hours

---

**Last Updated:** May 30, 2026
**Status:** Analysis complete, fixes ready to implement
