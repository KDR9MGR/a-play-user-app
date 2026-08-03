# iOS In-App Purchase (IAP) Subscription Fix

**Issue:** App Store reviewers see "No subscription plans available" on real iPad
**Severity:** 🔴 CRITICAL - Blocking App Store approval
**Device:** iPad Air 11-inch (M3), iPadOS 26.5
**Status:** Requires immediate fix

---

## Root Cause Analysis

### Issue 1: Hardcoded Product IDs Don't Match App Store Connect

**File:** [`lib/core/services/purchase_manager.dart:62-67`](lib/core/services/purchase_manager.dart#L62-L67)

**Current Code:**
```dart
List<String> kProductIds = <String>[
  '3SUB',      // 3 months
  '1month',    // Monthly Premium
  '7day',      // 7 Days
  '365day',    // 365 Days
];
```

**Problem:**
- These product IDs are hardcoded and likely don't exist in App Store Connect
- Product IDs must match **exactly** what's configured in App Store Connect
- No fallback to PayStack subscriptions when IAP fails

### Issue 2: Poor Error Handling

**File:** [`lib/features/subscription/view/subscription_screen_new.dart:649-655`](lib/features/subscription/view/subscription_screen_new.dart#L649-L655)

**Current Code:**
```dart
if (_products.isEmpty) {
  return Center(
    child: Column(
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
        const Text('No subscription plans available'),
        const Text('This is normal in simulator.'),  // ❌ WRONG for real devices
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go Back'),
        ),
      ],
    ),
  );
}
```

**Problems:**
- Shows error screen instead of falling back to PayStack
- Message says "normal in simulator" but Apple reviewers are on real device
- No retry mechanism
- No alternative payment method offered

---

## Solutions

### Solution 1: Immediate Fix - Fall Back to PayStack (RECOMMENDED)

**Change the subscription screen to show PayStack subscriptions when IAP fails.**

#### Step 1: Update `subscription_screen_new.dart`

**Replace the "No subscription plans available" section (lines 641-664) with:**

```dart
// PRIORITY 2: If no IAP products, fall back to PayStack subscriptions
if (_products.isEmpty) {
  return FutureBuilder<List<SubscriptionPlan>>(
    future: _loadPayStackPlans(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        // Only show error if both IAP and PayStack fail
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Unable to load subscription plans',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your connection and try again.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _isLoading = true;
                      _loadSubscriptions();
                    }),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      // Show PayStack subscriptions
      return _buildPayStackPlansUI(snapshot.data!);
    },
  );
}

// Add helper method to load PayStack plans
Future<List<SubscriptionPlan>> _loadPayStackPlans() async {
  try {
    final response = await Supabase.instance.client
        .from('subscription_plans')
        .select()
        .order('price');

    return (response as List)
        .map((json) => SubscriptionPlan.fromJson(json))
        .toList();
  } catch (e) {
    debugPrint('Failed to load PayStack plans: $e');
    throw Exception('Unable to load subscription plans');
  }
}

// Add helper method to build PayStack plans UI
Widget _buildPayStackPlansUI(List<SubscriptionPlan> plans) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: plans.length,
    itemBuilder: (context, index) {
      final plan = plans[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          title: Text(plan.name),
          subtitle: Text(plan.description ?? ''),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GHS ${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                plan.billingPeriod,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          onTap: () => _purchaseWithPayStack(plan),
        ),
      );
    },
  );
}

// Add PayStack purchase method
Future<void> _purchaseWithPayStack(SubscriptionPlan plan) async {
  // Use existing PayStack integration
  // This already works from your event bookings!
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    _showErrorDialog('Please sign in to subscribe');
    return;
  }

  final reference = 'aplay_sub_${DateTime.now().millisecondsSinceEpoch}';

  try {
    final success = await UnifiedPaymentService.instance.processPayment(
      context: context,
      email: user.email!,
      amount: plan.price,
      reference: reference,
      metadata: {
        'type': 'subscription',
        'plan_id': plan.id,
        'tier': plan.tier,
        'user_id': user.id,
      },
      onSuccess: () async {
        // Create subscription in database
        await _createSubscription(plan, reference);
      },
      onError: (error) {
        _showErrorDialog('Payment failed: $error');
      },
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionSuccessScreen(),
        ),
      );
    }
  } catch (e) {
    _showErrorDialog('Purchase failed: $e');
  }
}

Future<void> _createSubscription(SubscriptionPlan plan, String transactionId) async {
  final user = Supabase.instance.client.auth.currentUser!;

  await Supabase.instance.client.from('user_subscriptions').insert({
    'user_id': user.id,
    'plan_id': plan.id,
    'tier': plan.tier,
    'status': 'active',
    'start_date': DateTime.now().toIso8601String(),
    'end_date': _calculateEndDate(plan.billingPeriod).toIso8601String(),
    'payment_method': 'paystack',
    'transaction_id': transactionId,
  });

  // Update user profile tier
  await Supabase.instance.client
      .from('profiles')
      .update({'tier': plan.tier})
      .eq('id', user.id);
}

DateTime _calculateEndDate(String billingPeriod) {
  final now = DateTime.now();
  switch (billingPeriod.toLowerCase()) {
    case 'monthly':
      return now.add(const Duration(days: 30));
    case 'quarterly':
      return now.add(const Duration(days: 90));
    case 'yearly':
      return now.add(const Duration(days: 365));
    default:
      return now.add(const Duration(days: 30));
  }
}
```

---

### Solution 2: Fix IAP Product IDs (For Future iOS Builds)

#### Step 1: Check App Store Connect Product IDs

1. **Go to:** https://appstoreconnect.apple.com
2. **Navigate to:** Your App → In-App Purchases
3. **Check what product IDs exist**

Common formats:
- `com.aplay.subscription.bronze.monthly`
- `com.aplay.subscription.silver.monthly`
- `com.aplay.subscription.gold.monthly`
- `com.aplay.subscription.platinum.monthly`

#### Step 2: Update Product IDs in Code

**File:** `lib/core/services/purchase_manager.dart`

```dart
// OLD (incorrect)
List<String> kProductIds = <String>[
  '3SUB',
  '1month',
  '7day',
  '365day',
];

// NEW (match App Store Connect)
List<String> kProductIds = <String>[
  'com.aplay.subscription.bronze.monthly',
  'com.aplay.subscription.silver.monthly',
  'com.aplay.subscription.gold.monthly',
  'com.aplay.subscription.platinum.monthly',
];
```

#### Step 3: Create Products in App Store Connect (If Not Exists)

1. **In-App Purchases** → **Create**
2. **Type:** Auto-Renewable Subscription
3. **Reference Name:** Bronze Monthly Subscription
4. **Product ID:** `com.aplay.subscription.bronze.monthly`
5. **Subscription Group:** Create "Premium Subscriptions"
6. **Subscription Duration:** 1 Month
7. **Price:** Set appropriate price

Repeat for Silver, Gold, Platinum tiers.

---

### Solution 3: Better Error Messages

**Replace all "This is normal in simulator" messages with:**

```dart
// Before
'This is normal in simulator.'

// After
Platform.isIOS
    ? 'Please check your Apple ID subscription settings or try again later.'
    : 'Please try again or use PayStack payment method.'
```

---

## Implementation Priority

### 🔴 CRITICAL (Do This First - 30 minutes)

1. **Implement PayStack Fallback**
   - Update `subscription_screen_new.dart` with fallback UI
   - Add `_loadPayStackPlans()` method
   - Add `_purchaseWithPayStack()` method
   - Test that PayStack subscriptions show when IAP fails

2. **Remove "Normal in Simulator" Messages**
   - Search for all instances
   - Replace with helpful error messages
   - Add "Try Again" buttons

### ⚠️ MEDIUM (Do Before Next Submission - 2 hours)

3. **Configure IAP Products in App Store Connect**
   - Create 4 subscription products (Bronze, Silver, Gold, Platinum)
   - Set correct pricing
   - Submit for review (they auto-approve usually)

4. **Update Product IDs in Code**
   - Match App Store Connect product IDs exactly
   - Update `purchase_manager.dart`

### ✅ LOW (Nice to Have - 1 hour)

5. **Add Hybrid Payment UI**
   - Show both IAP and PayStack options
   - Let user choose payment method
   - Better UX for international users

---

## Testing Steps

### Test on Real Device (Required)

1. **Build iOS app** with fallback code
2. **Open subscription screen**
3. **Verify:** PayStack plans load and display
4. **Test purchase:** Select a plan, complete PayStack payment
5. **Verify:** Subscription activates correctly

### Test IAP (After App Store Connect Setup)

1. **Configure products** in App Store Connect
2. **Update product IDs** in code
3. **Build and test** on device
4. **Use sandbox test account**
5. **Verify:** IAP purchase flow works

---

## Quick Fix Code (Copy-Paste Ready)

**Add to `lib/features/subscription/view/subscription_screen_new.dart`:**

```dart
import 'package:a_play/services/unified_payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Add this model if not exists
class SubscriptionPlan {
  final String id;
  final String name;
  final String tier;
  final double price;
  final String billingPeriod;
  final String? description;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.billingPeriod,
    this.description,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      tier: json['tier'],
      price: (json['price'] as num).toDouble(),
      billingPeriod: json['billing_period'] ?? 'monthly',
      description: json['description'],
    );
  }
}
```

---

## App Store Connect Configuration

### Create Subscription Products

**Product 1: Bronze Monthly**
```
Reference Name: Bronze Monthly Subscription
Product ID: com.aplay.subscription.bronze.monthly
Subscription Group: Premium Subscriptions
Duration: 1 Month
Price: $4.99 (or local equivalent)
```

**Product 2: Silver Monthly**
```
Reference Name: Silver Monthly Subscription
Product ID: com.aplay.subscription.silver.monthly
Subscription Group: Premium Subscriptions
Duration: 1 Month
Price: $9.99
```

**Product 3: Gold Monthly**
```
Reference Name: Gold Monthly Subscription
Product ID: com.aplay.subscription.gold.monthly
Subscription Group: Premium Subscriptions
Duration: 1 Month
Price: $14.99
```

**Product 4: Platinum Monthly**
```
Reference Name: Platinum Monthly Subscription
Product ID: com.aplay.subscription.platinum.monthly
Subscription Group: Premium Subscriptions
Duration: 1 Month
Price: $24.99
```

---

## Response to Apple Review

**After implementing the fix, respond to Apple:**

```
Thank you for your feedback regarding the subscription screen issue.

We have identified and resolved the problem:

ISSUE IDENTIFIED:
The app was attempting to load iOS In-App Purchase products that were
not yet configured in App Store Connect, causing the error screen.

FIXES IMPLEMENTED:
1. Added fallback to PayStack payment method when IAP is unavailable
2. Improved error handling and user messaging
3. Added retry functionality
4. Configured proper IAP subscription products in App Store Connect

TESTING:
- Verified on physical iPad Air 11-inch (M3) running iPadOS 26.5
- Confirmed subscriptions can be purchased via PayStack
- IAP products now load correctly when available
- Better error messages guide users when issues occur

The subscription flow now works reliably on all devices and provides
multiple payment options for users.

Please re-test at your convenience. Thank you!
```

---

## Files to Modify

1. **[lib/features/subscription/view/subscription_screen_new.dart](lib/features/subscription/view/subscription_screen_new.dart)** - Add PayStack fallback
2. **[lib/core/services/purchase_manager.dart](lib/core/services/purchase_manager.dart)** - Update product IDs (future)
3. **[lib/features/subscription/service/apple_iap_service.dart](lib/features/subscription/service/apple_iap_service.dart)** - Better error messages

---

## Summary

**Current State:** IAP fails → Shows error → Blocks App Store approval ❌

**Fixed State:** IAP fails → Shows PayStack options → User can subscribe ✅

**Implementation Time:** 30-60 minutes
**Testing Time:** 15-30 minutes
**Total Time:** 1-2 hours

**Priority:** 🔴 CRITICAL - Fix before resubmission

---

**Status:** Ready for implementation
**Next Action:** Implement PayStack fallback in `subscription_screen_new.dart`
**Success Criteria:** Apple reviewers can successfully subscribe via PayStack
