# Critical Bugs Found & Fixes Required

**Date**: April 26, 2026
**Status**: Issues identified from console logs

---

## 🔴 Critical Issues Found

### 1. Resend API Key Not Configured
**Error**: `flutter: Resend API key not configured`

**Impact**: Welcome emails and password reset emails are NOT being sent

**Root Cause**: `email_service.dart` is using `String.fromEnvironment()` instead of reading from `.env` file

**Fix Required**:
```dart
// Current (WRONG)
final String _apiKey = const String.fromEnvironment('RESEND_API_KEY');

// Should be (CORRECT)
final String _apiKey = Env.resendApiKey;
```

**File**: `lib/core/services/email_service.dart:18`

---

### 2. Invalid UUID Error Causing Crash
**Error**:
```
PostgrestException(message: invalid input syntax for type uuid: "", code: 22P02, details: Bad Request, hint: null)
```

**Impact**: App crashes when trying to query with empty UUID

**Root Cause**: Code is passing empty string `""` instead of valid UUID to database query

**Likely Location**: Database queries in initialization or profile loading

**Fix Required**: Add UUID validation before database queries

---

### 3. Missing Database Function
**Error**:
```
Could not find the function public.get_post_gift_summary(p_feed_id) in the schema cache
```

**Impact**: Feed/social features throwing errors

**Root Cause**: Database function `get_post_gift_summary` doesn't exist in Supabase

**Fix Required**: Either:
1. Create the missing database function, OR
2. Remove/update the code calling this function

---

### 4. Onboarding Screen Has Unnecessary Fields
**Issue**: After signup, onboarding asks for:
- Profile photo
- Phone number
- Date of birth
- City preference
- Interests

**Impact**: Poor user experience - too many required fields upfront

**Recommendation**: Simplify onboarding to only essential fields, make others optional or skip

**File**: `lib/features/onboarding/screens/onboarding_screen.dart`

---

## 🔧 Immediate Fixes Needed

### Fix 1: Update Email Service to Use Environment Config

**File**: `lib/core/services/email_service.dart`

```dart
// Change line 18 from:
final String _apiKey = const String.fromEnvironment('RESEND_API_KEY');

// To:
final String _apiKey = Env.resendApiKey;
```

**Why**: The `.env` file has the key (`re_AboimpaW_6twVjP58XvhrgdBTKmBKfAFJ`) but the code isn't reading it

---

### Fix 2: Add UUID Validation

Need to find where empty UUID is being passed. Based on logs, it's likely in:
- Profile loading on app startup
- Subscription status check
- User authentication flow

**Pattern to add**:
```dart
// Before any database query with UUID
if (userId == null || userId.isEmpty) {
  debugPrint('⚠️ Invalid user ID, skipping query');
  return null; // or throw appropriate error
}

// Validate UUID format
if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
    .hasMatch(userId)) {
  debugPrint('⚠️ Invalid UUID format: $userId');
  return null;
}
```

---

### Fix 3: Handle Missing Database Function

**Option A**: Gracefully handle the error (Quick fix)
```dart
// In feed loading code
try {
  final giftSummary = await supabase.rpc('get_post_gift_summary', params: {'p_feed_id': feedId});
} catch (e) {
  debugPrint('Gift summary function not available: $e');
  // Continue without gift summary
  return null;
}
```

**Option B**: Create the database function (Proper fix)
Run this SQL in Supabase:
```sql
CREATE OR REPLACE FUNCTION public.get_post_gift_summary(p_feed_id UUID)
RETURNS TABLE (
  total_gifts INTEGER,
  total_value NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::INTEGER as total_gifts,
    COALESCE(SUM(amount), 0) as total_value
  FROM post_gifts
  WHERE feed_id = p_feed_id;
END;
$$ LANGUAGE plpgsql;
```

---

### Fix 4: Simplify Onboarding Flow

**Current Flow** (5 screens):
1. Profile Photo
2. Phone Number
3. Date of Birth
4. City Preference
5. Interests

**Recommended Flow** (1-2 screens):
1. Welcome screen with option to skip
2. Or go directly to home

**Implementation**:
```dart
// Option 1: Skip onboarding entirely, go straight to home
context.go('/home');

// Option 2: Single welcome screen with "Get Started" button
// Then navigate to home

// Option 3: Make all fields optional with "Skip" button
```

---

## 📋 Testing After Fixes

### Test Email Functionality
1. Sign up with new account
2. **Expected**: Receive welcome email
3. Try "Forgot Password"
4. **Expected**: Receive password reset email

### Test UUID Fix
1. Fresh app install
2. Sign in
3. **Expected**: No PostgrestException errors in console
4. App should load without crashes

### Test Feed/Social
1. Navigate to Feed tab
2. **Expected**: No errors about missing `get_post_gift_summary` function
3. Feed should load properly

### Test Onboarding
1. Create new account
2. **Expected**: Either skip onboarding or quick 1-screen flow
3. Should reach home screen without friction

---

## 🎯 Priority Order

### P0 - Must Fix Before Production
1. ✅ Email service configuration (prevents welcome/reset emails)
2. ✅ UUID validation (causes crashes)

### P1 - Should Fix Soon
3. ⚠️ Missing database function (affects feed functionality)
4. ⚠️ Onboarding simplification (poor UX)

---

## 📝 Additional Notes

### Firebase Warnings (Can be ignored for now)
```
12.8.0 - [FirebaseCore][I-COR000003] The default Firebase app has not yet been configured
```
These are warnings, not errors. Firebase is being initialized later in the flow.

### OneSignal Working ✅
```
VERBOSE: setAppId called with appId: 1635806b-c5f2-4615-8ebb-4424ba5510dd!
INFO: Device Registered with Apple
```
Push notifications are working correctly.

### IAP Service Working ✅
```
flutter: IAPService: Loaded 4 products
flutter: IAPService: - 7day: 7 Day Fun ($3.99)
flutter: IAPService: - 1month: A Month Fun ($12.99)
```
In-app purchases are loading correctly.

---

## 🚀 Next Steps

1. **Fix email service** - Change to use `Env.resendApiKey`
2. **Find and fix empty UUID** - Add validation in database queries
3. **Handle missing DB function** - Add try-catch or create function
4. **Simplify onboarding** - Skip or make fields optional

Would you like me to implement these fixes now?
