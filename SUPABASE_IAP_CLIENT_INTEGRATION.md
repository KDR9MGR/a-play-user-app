# Supabase IAP Client Integration Guide

This document explains how to integrate the Supabase IAP backend (Edge Functions + Database) with your Flutter app.

## Architecture Overview

```
┌─────────────────┐
│   Flutter App   │
│  (StoreKit IAP) │
└────────┬────────┘
         │
         │ 1. Purchase completed
         ▼
┌─────────────────────────────────┐
│ Call Supabase Edge Function:    │
│ verify-apple-sub                │
│ (with receipt data)             │
└────────┬────────────────────────┘
         │
         │ 2. Verify with Apple
         ▼
┌─────────────────────────────────┐
│ Apple verifyReceipt API         │
│ (returns subscription details)  │
└────────┬────────────────────────┘
         │
         │ 3. Store in database
         ▼
┌─────────────────────────────────┐
│ Supabase subscriptions table    │
│ (using service_role)            │
└────────┬────────────────────────┘
         │
         │ 4. Return status
         ▼
┌─────────────────────────────────┐
│ Flutter App updates UI          │
│ (show premium features)         │
└─────────────────────────────────┘
```

## Important Principles

1. **Server-side verification only**: Never trust client-side purchase data
2. **Apple never talks to database directly**: Always go through Edge Functions
3. **Use service_role in Edge Functions**: Bypass RLS to write subscription data
4. **Client uses anon key**: Never expose service_role_key to Flutter app
5. **Idempotent operations**: Safe to call verify-apple-sub multiple times

---

## Part 1: Post-Purchase Flow

### When to Call This
After a successful StoreKit purchase completes in your Flutter app.

### Pseudocode Flow

```dart
// ============================================================================
// PSEUDOCODE: After successful IAP purchase
// Location: lib/core/services/purchase_manager.dart or similar
// ============================================================================

Future<void> handleSuccessfulPurchase(PurchaseDetails purchase) async {

  // Step 1: Get the receipt data from StoreKit
  final receiptData = await getReceiptData(); // Base64 encoded

  // Step 2: Get current user ID from Supabase auth
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Step 3: Determine if sandbox environment
  final isSandbox = await isSandboxEnvironment(); // Check build config

  // Step 4: Call Supabase Edge Function to verify
  final response = await supabase.functions.invoke(
    'verify-apple-sub',
    body: {
      'receiptData': receiptData,
      'userId': userId,
      'sandbox': isSandbox,
    },
  );

  // Step 5: Handle response
  if (response.status == 200) {
    final data = response.data;

    if (data['success'] == true && data['isSubscribed'] == true) {
      // SUCCESS: Subscription verified and stored

      // Update local state
      await updateLocalSubscriptionState(
        isSubscribed: true,
        productId: data['productId'],
        expiry: DateTime.parse(data['expiry']),
        platform: data['platform'],
        autoRenew: data['autoRenewEnabled'],
      );

      // Refresh UI to show premium features
      ref.invalidate(activeSubscriptionProvider);
      ref.invalidate(profileFutureProvider);

      // Complete the StoreKit transaction
      await InAppPurchase.instance.completePurchase(purchase);

      // Show success message
      showSuccessDialog('Subscription activated!');

    } else {
      // FAILURE: Verification failed
      final errorCode = data['errorCode'];
      final appleStatus = data['appleStatus'];

      handleVerificationError(errorCode, appleStatus);
    }
  } else {
    // Network error or Edge Function error
    throw Exception('Failed to verify subscription: ${response.status}');
  }
}
```

### Flutter Implementation Example

```dart
// ============================================================================
// REAL FLUTTER CODE EXAMPLE
// File: lib/core/services/purchase_manager.dart
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/services.dart';

class PurchaseManager {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Called when InAppPurchase stream emits a successful purchase
  Future<void> handlePurchaseUpdate(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased) {
      try {
        // Verify and store in backend
        await _verifyPurchaseWithBackend(purchase);

        // Complete the transaction
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } catch (e) {
        print('Error verifying purchase: $e');
        // Handle error - show message to user
      }
    }
  }

  Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase) async {
    // 1. Get receipt data (iOS specific)
    final receiptData = await _getReceiptData();

    // 2. Get current user
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // 3. Determine sandbox mode
    final isSandbox = await _isSandboxMode();

    // 4. Call Edge Function
    final response = await _supabase.functions.invoke(
      'verify-apple-sub',
      body: {
        'receiptData': receiptData,
        'userId': user.id,
        'sandbox': isSandbox,
      },
    );

    // 5. Process response
    if (response.status != 200) {
      throw Exception('Edge Function error: ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true || data['isSubscribed'] != true) {
      final errorCode = data['errorCode'] ?? 'unknown_error';
      final appleStatus = data['appleStatus'];
      throw Exception('Verification failed: $errorCode (Apple: $appleStatus)');
    }

    // Success! Data is now in Supabase database
    print('Subscription verified: ${data['productId']}, expires: ${data['expiry']}');
  }

  /// Get base64 encoded receipt from iOS
  Future<String> _getReceiptData() async {
    try {
      // Use platform channel or in_app_purchase method to get receipt
      // This is iOS-specific implementation
      const platform = MethodChannel('app.aplay/iap');
      final String receipt = await platform.invokeMethod('getReceipt');
      return receipt;
    } catch (e) {
      throw Exception('Failed to get receipt data: $e');
    }
  }

  /// Check if running in sandbox environment
  Future<bool> _isSandboxMode() async {
    // Check build configuration or use a debug flag
    // In production: return false
    // In development/TestFlight: return true
    return const bool.fromEnvironment('SANDBOX_MODE', defaultValue: false);
  }
}
```

---

## Part 2: App Startup / Status Check Flow

### When to Call This
- On app launch
- When user navigates to subscription/premium screens
- After a successful purchase (to refresh UI)
- Periodically to check for subscription changes (renewals, cancellations)

### Pseudocode Flow

```dart
// ============================================================================
// PSEUDOCODE: Check subscription status on app startup
// Location: main.dart or subscription_provider.dart
// ============================================================================

Future<SubscriptionStatus> checkSubscriptionStatus() async {

  // Step 1: Get current user ID
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    // User not logged in - no subscription
    return SubscriptionStatus(isSubscribed: false);
  }

  // Step 2: Call Edge Function to get status
  final response = await supabase.functions.invoke(
    'get-subscription-status',
    body: {
      'userId': userId,
    },
  );

  // Alternative: Use GET request with query params
  // final response = await http.get(
  //   Uri.parse('$SUPABASE_URL/functions/v1/get-subscription-status?userId=$userId'),
  //   headers: {'Authorization': 'Bearer $ANON_KEY'},
  // );

  // Step 3: Parse response
  if (response.status == 200) {
    final data = response.data;

    if (data['isSubscribed'] == true) {
      return SubscriptionStatus(
        isSubscribed: true,
        productId: data['productId'],
        expiry: DateTime.parse(data['expiry']),
        platform: data['platform'],
        status: data['status'],
        autoRenewEnabled: data['autoRenewEnabled'] ?? true,
        sandbox: data['sandbox'] ?? false,
      );
    } else {
      return SubscriptionStatus(isSubscribed: false);
    }
  } else {
    throw Exception('Failed to get subscription status: ${response.status}');
  }
}
```

### Flutter Provider Implementation Example

```dart
// ============================================================================
// REAL FLUTTER CODE EXAMPLE
// File: lib/features/subscription/provider/subscription_provider.dart
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/subscription_model.dart';

/// Provider that fetches active subscription from Supabase backend
final activeSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null; // Not authenticated
  }

  try {
    // Call get-subscription-status Edge Function
    final response = await supabase.functions.invoke(
      'get-subscription-status',
      body: {'userId': user.id},
    );

    if (response.status != 200) {
      throw Exception('Status check failed: ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;

    if (data['isSubscribed'] != true) {
      return null; // No active subscription
    }

    // Parse subscription data
    return Subscription(
      id: 'remote', // We don't need the UUID on client side
      userId: user.id,
      productId: data['productId'] as String,
      status: data['status'] as String,
      platform: data['platform'] as String,
      startDate: DateTime.now(), // We don't have this from the response
      endDate: DateTime.parse(data['expiry'] as String),
      autoRenewEnabled: data['autoRenewEnabled'] as bool? ?? true,
      isSandbox: data['sandbox'] as bool? ?? false,
    );

  } catch (e) {
    print('Error fetching subscription status: $e');
    return null;
  }
});

/// Provider to check if user has premium access
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final subscription = ref.watch(activeSubscriptionProvider);

  return subscription.when(
    data: (sub) => sub?.isActive ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
```

### UI Usage Example

```dart
// ============================================================================
// Using subscription status in UI
// File: lib/features/home/screens/home_screen.dart
// ============================================================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      body: subscriptionAsync.when(
        data: (subscription) {
          if (subscription != null && subscription.isActive) {
            // Show premium content
            return PremiumHomeContent(subscription: subscription);
          } else {
            // Show free tier content with upgrade prompts
            return FreeTierHomeContent();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

---

## Part 3: Integration Points in Your Existing Code

### Where to Add Backend Calls

#### 1. In `lib/core/services/purchase_manager.dart`

```dart
// Current code has handlePurchaseUpdate method
// ADD: Backend verification after StoreKit success

@override
void handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
  for (final purchase in purchaseDetailsList) {
    if (purchase.status == PurchaseStatus.purchased) {

      // ADD THIS: Verify with backend
      _verifyPurchaseWithBackend(purchase).then((_) {
        print('✅ Subscription verified and stored in Supabase');

        // Refresh subscription state
        // (Assuming you have a ref to WidgetRef or ProviderContainer)
        _ref.invalidate(activeSubscriptionProvider);

      }).catchError((error) {
        print('❌ Backend verification failed: $error');
        // Show error to user
      });

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }
}

// ADD THIS METHOD:
Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase) async {
  // Get receipt data
  final receiptData = await _getReceiptData();

  // Get user
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  // Call Edge Function
  final response = await Supabase.instance.client.functions.invoke(
    'verify-apple-sub',
    body: {
      'receiptData': receiptData,
      'userId': user.id,
      'sandbox': const bool.fromEnvironment('SANDBOX_MODE', defaultValue: false),
    },
  );

  if (response.status != 200) {
    throw Exception('Verification failed: ${response.status}');
  }

  final data = response.data as Map<String, dynamic>;
  if (data['success'] != true) {
    throw Exception('Invalid receipt: ${data['errorCode']}');
  }
}
```

#### 2. In `lib/features/subscription/service/apple_iap_service.dart`

```dart
// Current code has purchase method
// MODIFY: Add backend verification step

Future<PurchaseResult> purchaseSubscription(String planType) async {
  try {
    final productId = _productIds[planType];
    if (productId == null) {
      return PurchaseResult.error('Invalid plan type');
    }

    // Initiate purchase
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

    if (success) {
      // WAIT for purchase stream to complete
      // Backend verification happens in purchase_manager.dart

      // Optionally: Wait for backend verification before returning
      await _waitForBackendVerification();

      return PurchaseResult.success();
    } else {
      return PurchaseResult.cancelled();
    }
  } catch (e) {
    return PurchaseResult.error(e.toString());
  }
}
```

#### 3. In `lib/main.dart` or App Initialization

```dart
// On app startup, check subscription status

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  // CREATE PROVIDER CONTAINER
  final container = ProviderContainer();

  // PRELOAD SUBSCRIPTION STATUS
  // This will call get-subscription-status if user is logged in
  container.read(activeSubscriptionProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
```

#### 4. Update `lib/features/subscription/utils/subscription_utils.dart`

```dart
// Current hasPremiumAccess checks activeSubscriptionProvider
// This already works! The provider now fetches from Supabase backend

static bool hasPremiumAccess(WidgetRef ref) {
  // Check subscription from backend
  if (hasActiveSubscription(ref)) {
    return true;
  }

  // Fallback: Check profile is_premium flag
  final profileAsync = ref.watch(profileFutureProvider);
  return profileAsync.when(
    data: (profile) => profile.isPremium,
    loading: () => false,
    error: (_, __) => false,
  );
}

// ADD: Method to manually refresh subscription from backend
static Future<void> refreshSubscriptionFromBackend(WidgetRef ref) async {
  ref.invalidate(activeSubscriptionProvider);

  // Wait for refresh to complete
  await ref.read(activeSubscriptionProvider.future);
}
```

---

## Part 4: Error Handling

### Common Errors and How to Handle Them

```dart
Future<void> handleVerificationError(String? errorCode, int? appleStatus) async {

  switch (errorCode) {
    case 'invalid_receipt':
      // Receipt is malformed or tampered
      showError('Invalid purchase receipt. Please try again or contact support.');
      break;

    case 'receipt_expired':
      // Subscription has expired
      showError('Your subscription has expired. Please renew to continue.');
      break;

    case 'receipt_canceled':
      // User refunded or canceled
      showError('This subscription was canceled or refunded.');
      break;

    case 'network_error':
      // Failed to reach Apple servers
      showError('Network error. Please check your connection and try again.');
      break;

    case 'missing_user_id':
      // User not authenticated
      showError('You must be signed in to complete this purchase.');
      break;

    default:
      // Unknown error
      showError('Verification failed. Please contact support with code: $errorCode');
  }

  // Log Apple status for debugging
  if (appleStatus != null && appleStatus != 0) {
    print('⚠️ Apple status code: $appleStatus');
    // See Apple docs for status codes:
    // https://developer.apple.com/documentation/appstorereceipts/status
  }
}
```

### Retry Logic

```dart
Future<void> verifyPurchaseWithRetry(PurchaseDetails purchase, {int maxRetries = 3}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await _verifyPurchaseWithBackend(purchase);
      return; // Success
    } catch (e) {
      if (attempt == maxRetries) {
        rethrow; // Max retries reached
      }

      // Wait before retry (exponential backoff)
      await Future.delayed(Duration(seconds: attempt * 2));
      print('Retry attempt $attempt/$maxRetries...');
    }
  }
}
```

---

## Part 5: Testing

### Testing with Apple Sandbox

1. **Use TestFlight build or Debug build** with sandbox enabled
2. **Create Sandbox Apple ID** in App Store Connect
3. **Set sandbox flag**:
   ```dart
   const isSandbox = true; // Or use build configuration
   ```
4. **Make purchase** in the app
5. **Verify in Supabase**:
   - Check `subscriptions` table for new row
   - `sandbox` column should be `true`
   - Check `subscription_events` for purchase event

### Testing Subscription Status

```dart
// In your app, add a debug button to manually check status
ElevatedButton(
  onPressed: () async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client.functions.invoke(
      'get-subscription-status',
      body: {'userId': user!.id},
    );
    print('Subscription status: ${response.data}');
  },
  child: Text('Check Status'),
)
```

### Debugging Checklist

- [ ] Edge Functions deployed to Supabase
- [ ] Environment variables set in Supabase dashboard
- [ ] APPLE_SHARED_SECRET matches App Store Connect
- [ ] User is authenticated before purchase
- [ ] Receipt data is valid base64
- [ ] Sandbox flag matches build environment
- [ ] RLS policies allow service_role writes
- [ ] Check Supabase logs for Edge Function errors

---

## Part 6: Production Checklist

Before going live:

- [ ] Set `sandbox: false` for production builds
- [ ] Use production Apple verifyReceipt endpoint
- [ ] Update APPLE_SHARED_SECRET to production value
- [ ] Test with real Apple ID (not sandbox)
- [ ] Implement receipt refresh on app launch (check expiry)
- [ ] Handle subscription renewals automatically
- [ ] Implement grace period handling
- [ ] Add subscription cancellation UI
- [ ] Test refund scenarios
- [ ] Monitor Supabase Edge Function logs
- [ ] Set up alerts for verification failures

---

## Summary

**After purchase**: Call `verify-apple-sub` with receipt → Stores in database → Returns status

**On app startup**: Call `get-subscription-status` → Returns current state → Update UI

**Security**: Client uses anon key, Edge Functions use service_role key, RLS prevents direct writes

**Error handling**: Check `success`, `errorCode`, and `appleStatus` fields in responses

**Testing**: Use sandbox mode with TestFlight, verify data in Supabase tables

This architecture ensures:
- ✅ Server-side verification only
- ✅ No direct client-to-database writes
- ✅ Apple receipts are validated before trusting
- ✅ Subscription state is centralized in Supabase
- ✅ Easy to query status from any device
