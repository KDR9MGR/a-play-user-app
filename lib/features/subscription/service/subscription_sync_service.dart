import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to sync subscription state between StoreKit and Database
class SubscriptionSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user has an active subscription in the database
  Future<bool> hasActiveSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('SubscriptionSync: No user logged in');
        return false;
      }

      debugPrint('SubscriptionSync: Checking active subscription for user: $userId');

      // Check profiles table for quick lookup
      final profileResponse = await _supabase
          .from('profiles')
          .select('is_subscribed, subscription_expires_at')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse == null) {
        debugPrint('SubscriptionSync: No profile found');
        return false;
      }

      final isSubscribed = profileResponse['is_subscribed'] as bool? ?? false;
      final expiresAtStr = profileResponse['subscription_expires_at'] as String?;

      if (!isSubscribed) {
        debugPrint('SubscriptionSync: User not subscribed');
        return false;
      }

      // Check if subscription has expired
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        final isExpired = expiresAt.isBefore(DateTime.now());

        if (isExpired) {
          debugPrint('SubscriptionSync: Subscription expired on: $expiresAt');
          return false;
        }

        debugPrint('SubscriptionSync: ✓ Active subscription found, expires: $expiresAt');
        return true;
      }

      debugPrint('SubscriptionSync: ✓ Active subscription found (no expiry set)');
      return true;
    } catch (e) {
      debugPrint('SubscriptionSync: Error checking subscription: $e');
      return false;
    }
  }

  /// Get active subscription details
  Future<Map<String, dynamic>?> getActiveSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('SubscriptionSync: getActiveSubscription - No user logged in');
        return null;
      }

      debugPrint('SubscriptionSync: getActiveSubscription for userId: $userId');

      // Get from profiles for quick access
      final profileResponse = await _supabase
          .from('profiles')
          .select('is_subscribed, subscription_tier, subscription_expires_at, current_tier')
          .eq('id', userId)
          .maybeSingle();

      debugPrint('SubscriptionSync: profileResponse = $profileResponse');

      if (profileResponse == null) {
        debugPrint('SubscriptionSync: No profile found');
        return null;
      }

      final isSubscribed = profileResponse['is_subscribed'] as bool? ?? false;
      if (!isSubscribed) {
        debugPrint('SubscriptionSync: Profile shows is_subscribed = false');
        return null;
      }

      // Also get full subscription record
      final subResponse = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .maybeSingle();

      debugPrint('SubscriptionSync: subResponse = $subResponse');

      // Combine data, ensuring plan_id is available
      final result = {
        'subscription_tier': profileResponse['subscription_tier'] ?? 'Premium',
        'subscription_expires_at': profileResponse['subscription_expires_at'],
        'current_tier': profileResponse['current_tier'],
        'is_subscribed': isSubscribed,
        // Add plan_id from subscription record
        if (subResponse != null) 'plan_id': subResponse['plan_id'],
        if (subResponse != null) 'subscription_id': subResponse['id'],
        if (subResponse != null) 'plan_type': subResponse['plan_type'],
        if (subResponse != null) 'start_date': subResponse['start_date'],
        if (subResponse != null) 'end_date': subResponse['end_date'],
      };

      debugPrint('SubscriptionSync: Returning subscription data: $result');
      return result;
    } catch (e) {
      debugPrint('SubscriptionSync: Error getting active subscription: $e');
      return null;
    }
  }

  /// Sync subscription from StoreKit receipt to database
  /// This is used when we detect a subscription in StoreKit but not in database
  Future<void> syncFromStoreKit(String productId) async {
    debugPrint('SubscriptionSync: Syncing subscription from StoreKit: $productId');

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Map product ID to plan details
      final planId = _mapProductToPlanId(productId);
      final planType = _mapProductToPlanType(productId);
      final tier = _getTier(productId);
      final duration = _getDuration(productId);
      final amount = _getAmount(productId);

      final now = DateTime.now();
      final endDate = now.add(duration);

      // Check if ANY active subscription already exists for this user
      final existingActive = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (existingActive != null) {
        debugPrint('SubscriptionSync: User already has active subscription: ${existingActive['plan_id']}');

        // If it's the same plan, just update the dates
        if (existingActive['plan_id'] == planId) {
          debugPrint('SubscriptionSync: Updating existing subscription end_date');
          await _supabase.from('user_subscriptions').update({
            'end_date': endDate.toIso8601String(),
            'updated_at': now.toIso8601String(),
          }).eq('id', existingActive['id']);

          await _supabase.from('profiles').update({
            'subscription_expires_at': endDate.toIso8601String(),
            'updated_at': now.toIso8601String(),
          }).eq('id', userId);

          debugPrint('SubscriptionSync: ✓ Subscription dates updated');
          return;
        }

        // Different plan - mark old as cancelled and create new
        debugPrint('SubscriptionSync: Cancelling old plan and activating new one');
        await _supabase.from('user_subscriptions').update({
          'status': 'cancelled',
          'updated_at': now.toIso8601String(),
        }).eq('id', existingActive['id']);
      }

      // Create subscription record (profile will be updated by trigger)
      final subscriptionData = {
        'user_id': userId,
        'plan_id': planId,
        'plan_type': planType,
        'tier': tier,
        'status': 'active',
        'subscription_type': 'premium',
        'billing_cycle': 'lifetime',
        'amount': amount,
        'currency': 'USD',
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'payment_method': 'apple_iap',
        'tier_points_earned': _getTierPoints(productId),
        'created_at': now.toIso8601String(),
      };

      await _supabase.from('user_subscriptions').insert(subscriptionData);

      debugPrint('SubscriptionSync: ✓ Subscription synced successfully');
      debugPrint('SubscriptionSync: ℹ️  Profile will be updated by database trigger');
    } catch (e) {
      debugPrint('SubscriptionSync: ✗ Sync failed: $e');
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

  double _getAmount(String productId) {
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
