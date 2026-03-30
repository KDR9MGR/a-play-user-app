# 🚨 Error Handling Guide

**Status**: Production Ready ✅
**Created**: December 24, 2024
**Purpose**: User-friendly error messages instead of technical exceptions

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Error Handler Utility](#error-handler-utility)
3. [Error Categories](#error-categories)
4. [Usage Examples](#usage-examples)
5. [Best Practices](#best-practices)
6. [Common Error Messages](#common-error-messages)
7. [Implementation Guide](#implementation-guide)

---

## 🎯 Overview

The Error Handler system converts technical exceptions and error codes into user-friendly messages that help users understand and fix issues.

### Before (Technical)
```
❌ "Exception: Invalid login credentials at line 42"
❌ "PostgresException: unique constraint violation"
❌ "SocketException: Failed host lookup"
```

### After (User-Friendly)
```
✅ "Incorrect email or password. Please try again."
✅ "This email is already registered. Try signing in instead."
✅ "Network error. Please check your internet connection."
```

---

## 🛠️ Error Handler Utility

**File**: [lib/core/utils/error_handler.dart](lib/core/utils/error_handler.dart)

### Main Functions

#### 1. **Generic Error Handler**
```dart
import 'package:a_play/core/utils/error_handler.dart';

try {
  await someOperation();
} catch (e, stackTrace) {
  final userMessage = ErrorHandler.handle(e, context: 'operation_name');
  showErrorDialog(userMessage);

  // Technical details logged for debugging
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Operation'));
}
```

#### 2. **Specific Error Handlers**
```dart
// Authentication errors
ErrorHandler.handleAuthError(error)

// Database errors
ErrorHandler.handleDatabaseError(error)

// Payment errors
ErrorHandler.handlePaymentError(error)

// Points/gifting errors
ErrorHandler.handlePointsError(error)

// Booking errors
ErrorHandler.handleBookingError(error)

// Upload errors
ErrorHandler.handleUploadError(error)
```

#### 3. **Error Classification**
```dart
// Check error type
if (ErrorHandler.isClientError(error)) {
  // 4xx - User can fix this
}

if (ErrorHandler.isServerError(error)) {
  // 5xx - Server issue, user can't fix
}

if (ErrorHandler.isNetworkError(error)) {
  // Network/connection issue
}

if (ErrorHandler.requiresAuth(error)) {
  // Redirect to login
}
```

---

## 📊 Error Categories

### 1. Authentication Errors (Auth)

| Error Code | Technical Message | User-Friendly Message |
|------------|-------------------|----------------------|
| 400 | Invalid login credentials | Incorrect email or password. Please try again. |
| 400 | Email not confirmed | Please verify your email address before signing in. |
| 400 | User already registered | This email is already registered. Try signing in instead. |
| 401 | Unauthorized | Your session has expired. Please sign in again. |
| 403 | Forbidden | Access denied. You don't have permission for this action. |
| 404 | User not found | Account not found. Please sign up first. |
| 422 | Invalid email | Please enter a valid email address. |
| 429 | Too many requests | Too many attempts. Please wait a few minutes. |

**Usage**:
```dart
try {
  await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
} catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Sign In'));

  final message = ErrorHandler.handleAuthError(e);
  // Shows: "Incorrect email or password. Please try again."
  showError(message);
}
```

### 2. Database Errors (DB)

| Error Type | Technical Message | User-Friendly Message |
|------------|-------------------|----------------------|
| Network | SocketException | Network error. Please check your internet connection. |
| Timeout | Request timeout | Request timed out. Please try again. |
| Unique | Unique constraint violation | This record already exists. |
| Foreign Key | Foreign key constraint | Cannot complete action. Related data not found. |
| Not Null | Not null constraint | Required information is missing. |
| Permission | RLS policy violation | You don't have permission for this action. |
| 500 | Internal server error | Server error. Please try again later. |
| 503 | Service unavailable | Service is down for maintenance. |

**Usage**:
```dart
try {
  await supabase.from('events').insert(eventData);
} catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Create Event'));

  final message = ErrorHandler.handleDatabaseError(e);
  // Shows appropriate message based on error type
  showError(message);
}
```

### 3. Payment Errors

| Error Type | User-Friendly Message |
|------------|----------------------|
| Insufficient funds | Insufficient balance. Please add funds to continue. |
| Card declined | Payment declined. Please check your payment method. |
| Expired card | Your card has expired. Please update payment method. |
| Invalid card | Invalid card details. Please check your information. |
| Active subscription | You already have an active subscription. |
| Expired subscription | Your subscription has expired. Please renew. |

**Usage**:
```dart
try {
  await processPayment();
} catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Process Payment'));

  final message = ErrorHandler.handlePaymentError(e);
  showError(message);
}
```

### 4. Points/Gifting Errors

| Error Type | User-Friendly Message |
|------------|----------------------|
| Insufficient points | You don't have enough points for this action. |
| Already gifted | You've already gifted this post. |
| No subscription | Please subscribe to gift points. |
| Invalid amount | Invalid points amount. Please enter a valid number. |

**Usage**:
```dart
try {
  await giftService.giftPointsToPost(...);
} catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Gift Points'));

  final message = ErrorHandler.handlePointsError(e);
  // Shows: "You don't have enough points for this action."
  showError(message);
}
```

### 5. Booking Errors

| Error Type | User-Friendly Message |
|------------|----------------------|
| Fully booked | Sorry, this event is fully booked. |
| Already booked | You already have a booking for this event. |
| Past event | Cannot book past events. |
| Cancelled | This event has been cancelled. |
| Expired | This booking has expired. |

### 6. Upload Errors

| Error Type | User-Friendly Message |
|------------|----------------------|
| File too large | File is too large. Maximum size is 10MB. |
| Invalid format | Invalid file format. Please upload an image. |
| No permission | No permission to upload. Check app permissions. |

---

## 💡 Usage Examples

### Example 1: Sign In Form

```dart
class SignInForm extends StatefulWidget {
  // ... widget code
}

class _SignInFormState extends State<SignInForm> {
  Future<void> _signIn() async {
    try {
      setState(() => _isLoading = true);

      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Success - navigate to home
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e, stackTrace) {
      // Log technical details
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'User Sign In',
      ));

      // Show user-friendly message
      final message = ErrorHandler.handleAuthError(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Example 2: Gift Points

```dart
Future<void> _giftPoints() async {
  try {
    final response = await giftService.giftPointsToPost(
      feedId: widget.feedId,
      receiverUserId: widget.authorId,
      pointsAmount: selectedAmount,
      giftType: selectedType,
    );

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gift sent! ${response.remainingPoints} points remaining.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Error message already user-friendly from service
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Failed to gift points'),
          backgroundColor: Colors.red,
        ),
      );
    }

  } catch (e, stackTrace) {
    debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Gift UI'));

    final message = ErrorHandler.handle(e, context: 'gift');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Example 3: Create Event

```dart
Future<void> _createEvent() async {
  try {
    await supabase.from('events').insert({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'start_date': _startDate.toIso8601String(),
      'price': double.parse(_priceController.text),
      'is_active': true,
    });

    showSuccess('Event created successfully!');

  } catch (e, stackTrace) {
    debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Create Event'));

    final message = ErrorHandler.handleDatabaseError(e);

    // Check if it's a client error (user can fix) or server error
    if (ErrorHandler.isClientError(e)) {
      showError(message); // User can fix the input
    } else if (ErrorHandler.isServerError(e)) {
      showError('$message Please contact support if this persists.');
    } else if (ErrorHandler.isNetworkError(e)) {
      showError('$message Try again when connection is restored.');
    } else {
      showError(message);
    }
  }
}
```

### Example 4: Network-Aware Error Handling

```dart
Future<List<Event>> fetchEvents() async {
  try {
    final response = await supabase.from('events').select();
    return parseEvents(response);

  } catch (e, stackTrace) {
    debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Fetch Events'));

    // Handle network errors gracefully
    if (ErrorHandler.isNetworkError(e)) {
      // Return cached data if available
      final cached = await getCachedEvents();
      if (cached.isNotEmpty) {
        showWarning('Showing cached data. ${ErrorHandler.handle(e)}');
        return cached;
      }
    }

    // No cached data - show error and return empty
    showError(ErrorHandler.handle(e, context: 'fetch events'));
    return [];
  }
}
```

---

## ✅ Best Practices

### 1. Always Use Error Handler

```dart
// ❌ Bad: Showing technical error
catch (e) {
  showError('Exception: $e');
}

// ✅ Good: User-friendly message
catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Operation'));
  showError(ErrorHandler.handle(e, context: 'operation'));
}
```

### 2. Log Technical Details

```dart
// ❌ Bad: No logging
catch (e) {
  showError(ErrorHandler.handle(e));
}

// ✅ Good: Log for debugging
catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Create Booking'));
  showError(ErrorHandler.handle(e, context: 'booking'));
}
```

### 3. Provide Context

```dart
// ❌ Bad: Generic context
ErrorHandler.handle(e)

// ✅ Good: Specific context
ErrorHandler.handle(e, context: 'gift')  // Uses gift-specific messages
ErrorHandler.handle(e, context: 'payment')  // Uses payment-specific messages
ErrorHandler.handle(e, context: 'booking')  // Uses booking-specific messages
```

### 4. Handle Different Error Types

```dart
catch (e, stackTrace) {
  debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Action'));

  String message = ErrorHandler.handle(e, context: 'action');

  // Customize based on error type
  if (ErrorHandler.requiresAuth(e)) {
    // Redirect to login
    Navigator.pushReplacementNamed(context, '/login');
    message = 'Please sign in to continue.';
  } else if (ErrorHandler.isNetworkError(e)) {
    // Offer retry
    showErrorWithRetry(message, onRetry: _performAction);
    return;
  }

  showError(message);
}
```

### 5. Graceful Degradation

```dart
Future<List<Event>> getEvents() async {
  try {
    return await fetchFromServer();
  } catch (e, stackTrace) {
    debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Events'));

    // Try cache first
    final cached = await getFromCache();
    if (cached.isNotEmpty) {
      showWarning('Showing offline data');
      return cached;
    }

    // Show error only if no fallback
    showError(ErrorHandler.handle(e));
    return [];
  }
}
```

---

## 📝 Common Error Messages Reference

### Authentication

| Scenario | Message |
|----------|---------|
| Wrong password | Incorrect email or password. Please try again. |
| Unverified email | Please verify your email address before signing in. |
| Account exists | This email is already registered. Try signing in instead. |
| Session expired | Your session has expired. Please sign in again. |
| Too many attempts | Too many attempts. Please wait a few minutes and try again. |

### Network

| Scenario | Message |
|----------|---------|
| No internet | Network error. Please check your internet connection. |
| Timeout | Request timed out. Please try again. |
| Server down | Service temporarily unavailable. Please try again later. |

### Data Validation

| Scenario | Message |
|----------|---------|
| Invalid email | Please enter a valid email address. |
| Missing required field | Required information is missing. |
| Duplicate entry | This record already exists. |
| Invalid format | Invalid data provided. Please check your input. |

### Permissions

| Scenario | Message |
|----------|---------|
| Unauthorized | Please sign in to continue. |
| Forbidden | Access denied. You don't have permission for this action. |
| Not found | Resource not found. |

---

## 🔧 Implementation Checklist

### For New Features

- [ ] Import ErrorHandler utility
- [ ] Wrap async operations in try-catch
- [ ] Capture stackTrace in catch block
- [ ] Log using `ErrorHandler.formatForLogging()`
- [ ] Show user message using `ErrorHandler.handle()`
- [ ] Provide specific context parameter
- [ ] Test with different error scenarios
- [ ] Verify user messages are friendly

### Example Template

```dart
import 'package:a_play/core/utils/error_handler.dart';

Future<void> myOperation() async {
  try {
    // Your operation here
    await someAsyncOperation();

  } catch (e, stackTrace) {
    // Log technical details
    debugPrint(ErrorHandler.formatForLogging(
      e,
      stackTrace,
      context: 'My Operation',
    ));

    // Show user-friendly message
    final message = ErrorHandler.handle(e, context: 'operation_type');
    showErrorToUser(message);
  }
}
```

---

## 🧪 Testing Error Messages

### Test Scenarios

1. **Authentication Errors**
   - Wrong password → "Incorrect email or password"
   - Unverified email → "Please verify your email"
   - Network offline → "Network error. Check connection"

2. **Points/Gifting Errors**
   - Insufficient points → "You don't have enough points"
   - Already gifted → "You've already gifted this post"
   - No subscription → "Please subscribe to gift points"

3. **Database Errors**
   - Duplicate entry → "This record already exists"
   - Permission denied → "You don't have permission"
   - Server error → "Server error. Try again later"

### Testing Commands

```dart
// Test in debug mode
try {
  throw AuthException('Invalid login credentials');
} catch (e) {
  print(ErrorHandler.handleAuthError(e));
  // Should print: "Incorrect email or password. Please try again."
}

try {
  throw Exception('unique constraint violation');
} catch (e) {
  print(ErrorHandler.handleDatabaseError(e));
  // Should print: "This record already exists."
}
```

---

## 📚 Files Updated

| File | Changes |
|------|---------|
| [lib/core/utils/error_handler.dart](lib/core/utils/error_handler.dart) | ✅ Created - Central error handling utility |
| [lib/features/feed/service/gift_service.dart](lib/features/feed/service/gift_service.dart) | ✅ Updated - Uses ErrorHandler for all errors |

---

## 🎯 Summary

### Before Error Handler
- ❌ Technical exception messages shown to users
- ❌ No consistent error handling
- ❌ Difficult to debug issues
- ❌ Poor user experience

### After Error Handler
- ✅ User-friendly messages
- ✅ Consistent error handling across app
- ✅ Technical details logged for debugging
- ✅ Great user experience
- ✅ Easy to maintain and extend

---

**Result**: Users see helpful messages and developers get detailed logs! 🎉

**Next**: Apply ErrorHandler to all services in your app using the template above.
