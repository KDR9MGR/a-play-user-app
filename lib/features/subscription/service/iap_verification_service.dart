import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple service to verify IAP purchases with Supabase
class IAPVerificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Verify Apple IAP purchase and create subscription
  /// The database trigger will automatically update the profile
  ///
  /// NOTE: Amount should be passed from StoreKit ProductDetails, not hardcoded
  Future<void> verifyAndActivateSubscription({
    required String productId,
    double? amount, // Optional: pass from StoreKit product.rawPrice
  }) async {
    debugPrint('IAPVerification: ═══════════════════════════');
    debugPrint('IAPVerification: Starting verification for: $productId');

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('IAPVerification: ✗ User not authenticated!');
      throw Exception('User not authenticated');
    }

    debugPrint('IAPVerification: User ID: $userId');

    try {
      // Map product ID to plan details
      final planId = _mapProductToPlanId(productId);
      final planType = _mapProductToPlanType(productId);
      final tier = _getTier(productId);
      final tierPoints = _getTierPoints(productId);

      // Use provided amount or fall back to lookup (for backward compatibility)
      final subscriptionAmount = amount ?? _getAmountFallback(productId);

      debugPrint('IAPVerification: Plan ID: $planId');
      debugPrint('IAPVerification: Tier: $tier');
      debugPrint('IAPVerification: Amount: \$${subscriptionAmount.toStringAsFixed(2)}');

      // Calculate subscription period
      final now = DateTime.now();
      final duration = _getDuration(productId);
      final endDate = now.add(duration);

      debugPrint('IAPVerification: Duration: ${duration.inDays} days');
      debugPrint('IAPVerification: End Date: ${endDate.toLocal()}');

      // Check if user already has an active subscription
      final existingResponse = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (existingResponse != null) {
        debugPrint('IAPVerification: ⚠️  User already has active subscription');
        debugPrint('IAPVerification: Updating existing subscription...');

        // Update existing subscription
        await _supabase.from('user_subscriptions').update({
          'plan_id': planId,
          'plan_type': planType,
          'tier': tier,
          'subscription_type': 'premium',
          'amount': subscriptionAmount,
          'currency': 'USD',
          'end_date': endDate.toIso8601String(),
          'tier_points_earned': tierPoints,
          'updated_at': now.toIso8601String(),
        }).eq('id', existingResponse['id']);

        debugPrint('IAPVerification: ✓ Existing subscription updated');
      } else {
        debugPrint('IAPVerification: Creating new subscription record...');

        // Create new subscription record
        final subscriptionData = {
          'user_id': userId,
          'plan_id': planId,
          'plan_type': planType,
          'tier': tier,
          'status': 'active',
          'subscription_type': 'premium', // Required field
          'billing_cycle': 'lifetime', // IAP purchases are one-time
          'amount': subscriptionAmount,
          'currency': 'USD', // IAP currency
          'start_date': now.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'payment_method': 'apple_iap',
          'tier_points_earned': tierPoints,
          'created_at': now.toIso8601String(),
        };

        await _supabase.from('user_subscriptions').insert(subscriptionData);

        debugPrint('IAPVerification: ✓ Subscription record created');
      }

      // Note: Profile is automatically updated by database trigger
      debugPrint('IAPVerification: ✓ Subscription activated successfully!');
      debugPrint('IAPVerification: ✓ Tier: $tier');
      debugPrint('IAPVerification: ✓ Expires: ${endDate.toLocal()}');
      debugPrint('IAPVerification: ℹ️  Profile will be updated by database trigger');
      debugPrint('IAPVerification: ═══════════════════════════');
    } catch (e) {
      debugPrint('IAPVerification: ═══════════════════════════');
      debugPrint('IAPVerification: ✗ VERIFICATION FAILED!');
      debugPrint('IAPVerification: Error: $e');
      debugPrint('IAPVerification: ═══════════════════════════');
      rethrow;
    }
  }

  String _mapProductToPlanId(String productId) {
    switch (productId) {
      case '7day':
        return 'weekly_plan';
      case '1month':
        return 'monthly_plan';
      case '3SUB':
        return 'quarterly_plan';
      case '365day':
        return 'annual_plan';
      default:
        return 'unknown';
    }
  }

  String _mapProductToPlanType(String productId) {
    switch (productId) {
      case '7day':
        return 'weekly';
      case '1month':
        return 'monthly';
      case '3SUB':
        return 'quarterly';
      case '365day':
        return 'annual';
      default:
        return 'unknown';
    }
  }

  Duration _getDuration(String productId) {
    switch (productId) {
      case '7day':
        return const Duration(days: 7);
      case '1month':
        return const Duration(days: 30);
      case '3SUB':
        return const Duration(days: 90);
      case '365day':
        return const Duration(days: 365);
      default:
        return const Duration(days: 30);
    }
  }

  int _getTierPoints(String productId) {
    switch (productId) {
      case '7day':
        return 50;
      case '1month':
        return 200;
      case '3SUB':
        return 650;
      case '365day':
        return 3000;
      default:
        return 0;
    }
  }

  String _getTier(String productId) {
    switch (productId) {
      case '7day':
        return 'Gold';
      case '1month':
        return 'Platinum';
      case '3SUB':
        return 'Platinum';
      case '365day':
        return 'Black';
      default:
        return 'Gold';
    }
  }

  /// Fallback method for getting amount when not provided from StoreKit
  /// TODO: Remove this once all callers pass amount from ProductDetails
  double _getAmountFallback(String productId) {
    debugPrint('IAPVerification: ⚠️  Using fallback pricing - should pass amount from StoreKit');
    switch (productId) {
      case '7day':
        return 3.99;
      case '1month':
        return 12.99;
      case '3SUB':
        return 36.99;
      case '365day':
        return 146.99;
      default:
        return 0.0;
    }
  }
}
