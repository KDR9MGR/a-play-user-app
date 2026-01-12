import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/error_handler.dart';

/// Helper class for subscription-based chat access
/// Ensures only users with active subscriptions can chat
class SubscriptionChatHelper {
  final SupabaseClient _client = Supabase.instance.client;

  /// Check if current user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('user_subscriptions')
          .select('status, plan_id')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Check Active Subscription',
      ));
      return false;
    }
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
    try {
      final response = await _client
          .from('user_subscriptions')
          .select('status')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Check User Has Active Subscription',
      ));
      return false;
    }
  }

  /// Search for users with active subscriptions only
  Future<List<Map<String, dynamic>>> searchSubscribedUsers(String query) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Please sign in to search for users.');
      }

      // First, check if current user has active subscription
      final hasSubscription = await hasActiveSubscription();
      if (!hasSubscription) {
        throw Exception(
          'You need an active subscription to chat. Please subscribe to continue.',
        );
      }

      // Search for users with active subscriptions
      // Using a complex query with joins to filter by subscription status
      final response = await _client.rpc(
        'search_subscribed_users',
        params: {
          'search_query': query,
          'requesting_user_id': currentUserId,
        },
      );

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
      // Check if current user has subscription
      final currentUserHasSub = await userHasActiveSubscription(currentUserId);
      if (!currentUserHasSub) {
        return ChatAccessValidation(
          canChat: false,
          reason: 'You need an active subscription to chat.',
          requiresAction: 'subscribe',
        );
      }

      // Check if other user has subscription
      final otherUserHasSub = await userHasActiveSubscription(otherUserId);
      if (!otherUserHasSub) {
        return ChatAccessValidation(
          canChat: false,
          reason: 'This user doesn\'t have an active subscription.',
          requiresAction: 'inform',
        );
      }

      return ChatAccessValidation(
        canChat: true,
        reason: 'Both users have active subscriptions.',
      );
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(
        e,
        stackTrace,
        context: 'Validate Chat Access',
      ));
      return ChatAccessValidation(
        canChat: false,
        reason: 'Unable to verify subscription status.',
        requiresAction: 'retry',
      );
    }
  }

  /// Get subscription upgrade prompt message
  String getUpgradeMessage() {
    return 'Chat is available for subscribed members only.\n\n'
        'Subscribe to:\n'
        '• Chat with other members\n'
        '• Make new connections\n'
        '• Join group conversations\n'
        '• Access exclusive features';
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
