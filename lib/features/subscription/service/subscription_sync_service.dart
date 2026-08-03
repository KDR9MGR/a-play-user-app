import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'subscription_service.dart';

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

      // S2: this previously granted an active subscription purely from a
      // client-supplied productId, with ZERO Apple contact - anyone could
      // trigger a "restore" and get premium for free. It now fetches the
      // real App Store receipt and has it verified (and written) server-side
      // by verify-apple-receipt, exactly like a fresh purchase.
      final receiptData = await SKReceiptManager.retrieveReceiptData();
      if (receiptData.isEmpty) {
        throw Exception('No App Store receipt available to verify');
      }

      await SubscriptionService().verifyAndActivateAppleSubscription(
        productId: productId,
        receiptData: receiptData,
      );

      debugPrint('SubscriptionSync: ✓ Subscription synced successfully');
      debugPrint('SubscriptionSync: ℹ️  Profile will be updated by database trigger');
    } catch (e) {
      debugPrint('SubscriptionSync: ✗ Sync failed: $e');
      rethrow;
    }
  }

}
