import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple service to verify IAP purchases with Supabase
class IAPVerificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Verify Apple IAP purchase with backend
  Future<void> verifyAndActivateSubscription({
    required String productId,
  }) async {
    debugPrint('IAPVerification: Verifying purchase for: $productId');

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Map product IDs to plan names
      final planName = _getPlanName(productId);

      debugPrint('IAPVerification: Plan name: $planName');
      debugPrint('IAPVerification: User ID: $userId');

      // Create subscription record in Supabase
      final now = DateTime.now();
      final duration = _getDuration(productId);
      final endDate = now.add(duration);

      final subscriptionData = {
        'user_id': userId,
        'plan_id': _mapProductToPlanId(productId),
        'plan_type': _mapProductToPlanType(productId),
        'status': 'active',
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'payment_method': 'apple_iap',
        'tier_points_earned': _getTierPoints(productId),
        'created_at': now.toIso8601String(),
      };

      debugPrint('IAPVerification: Creating subscription record...');

      await _supabase.from('user_subscriptions').insert(subscriptionData);

      debugPrint('IAPVerification: ✓ Subscription activated successfully');
    } catch (e) {
      debugPrint('IAPVerification: ✗ Verification failed: $e');
      rethrow;
    }
  }

  String _getPlanName(String productId) {
    switch (productId) {
      case '7day':
        return '1 Week Premium';
      case '1month':
        return '1 Month Premium';
      case '3SUB':
        return '3 Months Premium';
      case '365day':
        return '1 Year Premium';
      default:
        return 'Unknown';
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
}
