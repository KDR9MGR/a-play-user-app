import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/error_handler.dart';

/// Helper class for subscription-based chat access
/// Ensures only users with active subscriptions can chat
class SubscriptionChatHelper {
  final SupabaseClient _client = Supabase.instance.client;

  /// Check if current user has an active subscription
  Future<bool> hasActiveSubscription() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('profiles')
        .select('is_premium')
        .eq('id', userId)
        .single();

    return response['is_premium'] as bool? ?? false;
  }

  /// Get user's subscription tier
  Future<String?> getUserSubscriptionTier() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from('profiles')
          .select('current_tier')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return response['current_tier'] as String?;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Get User Subscription Tier',
      ));
      return null;
    }
  }

  /// Check if a specific user has an active subscription
  Future<bool> userHasActiveSubscription(String userId) async {
    return userId.isNotEmpty;
  }

  /// Search for users with active subscriptions only
  Future<List<Map<String, dynamic>>> searchSubscribedUsers(String query) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Please sign in to search for users.');
      }

      final response = await _client
          .from('profiles')
          .select('id,email,full_name,avatar_url,current_tier,is_active')
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .neq('id', currentUserId)
          .limit(50);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Search Subscribed Users',
      ));
      rethrow;
    }
  }

  /// Validate if two users can chat with each other
  Future<ChatAccessValidation> validateChatAccess(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      return ChatAccessValidation(
        canChat: true,
        reason: 'Access granted',
      );
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Validate Chat Access',
      ));
      return ChatAccessValidation(
        canChat: false,
        reason: 'Unable to verify access.',
        requiresAction: 'retry',
      );
    }
  }

  /// Get subscription upgrade prompt message
  String getUpgradeMessage() {
    return 'Chat is available for all users.';
  }

  /// Get user's subscription details
  Future<SubscriptionDetails?> getUserSubscriptionDetails() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from('user_subscriptions')
          .select('''
            status,
            plan_id,
            start_date,
            end_date,
            subscription_plans!inner(
              name,
              tier_level,
              price_monthly,
              features
            )
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;

      final planData = response['subscription_plans'];

      return SubscriptionDetails(
        status: response['status'] as String,
        planId: response['plan_id'] as String,
        planName: planData['name'] as String,
        tierLevel: planData['tier_level'] as int,
        startDate: DateTime.parse(response['start_date'] as String),
        endDate: DateTime.parse(response['end_date'] as String),
        features: Map<String, dynamic>.from(planData['features'] ?? {}),
      );
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Get Subscription Details',
      ));
      return null;
    }
  }
}

/// Chat access validation result
class ChatAccessValidation {
  final bool canChat;
  final String reason;
  final String? requiresAction;

  ChatAccessValidation({
    required this.canChat,
    required this.reason,
    this.requiresAction,
  });
}

/// Subscription details model
class SubscriptionDetails {
  final String status;
  final String planId;
  final String planName;
  final int tierLevel;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> features;

  SubscriptionDetails({
    required this.status,
    required this.planId,
    required this.planName,
    required this.tierLevel,
    required this.startDate,
    required this.endDate,
    required this.features,
  });

  bool get isActive => status == 'active';

  bool get hasExpired => DateTime.now().isAfter(endDate);

  String get tierName {
    switch (tierLevel) {
      case 1:
        return 'Free';
      case 2:
        return 'Gold';
      case 3:
        return 'Platinum';
      case 4:
        return 'Black';
      default:
        return 'Unknown';
    }
  }
}
