import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/post_gift_model.dart';
import '../../../core/utils/error_handler.dart';

/// Service for handling post gift operations
class GiftService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Gift points to a post
  ///
  /// Uses the database function `process_post_gift` which handles:
  /// - Points validation
  /// - Deducting from gifter
  /// - Adding to receiver
  /// - Creating gift record
  /// - Updating post statistics
  Future<GiftResponse> giftPointsToPost({
    required String feedId,
    required String receiverUserId,
    required int pointsAmount,
    required GiftType giftType,
    String? message,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return const GiftResponse(
          success: false,
          error: 'Please sign in to gift points.',
        );
      }

      // Call the database function
      final response = await _supabase.rpc(
        'process_post_gift',
        params: {
          'p_feed_id': feedId,
          'p_gifter_user_id': currentUser.id,
          'p_receiver_user_id': receiverUserId,
          'p_points_amount': pointsAmount,
          'p_gift_type': giftType.id,
          'p_message': message,
        },
      );

      return GiftResponse.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Gift Points'));

      return GiftResponse(
        success: false,
        error: ErrorHandler.handle(e, context: 'gift'),
      );
    }
  }

  /// Get gift summary for a post
  Future<PostGiftSummary> getPostGiftSummary(String feedId) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      final response = await _supabase.rpc(
        'get_post_gift_summary',
        params: {'p_feed_id': feedId},
      );

      final summary = PostGiftSummary.fromJson(response as Map<String, dynamic>);

      // Check if current user has gifted this post
      if (currentUser != null) {
        final userGift = await _getUserGiftForPost(feedId, currentUser.id);
        if (userGift != null) {
          return summary.copyWith(
            userHasGifted: true,
            userGiftType: userGift.giftType,
          );
        }
      }

      return summary;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Gift Summary'));
      // Return empty summary on error
      return const PostGiftSummary();
    }
  }

  /// Check if user has already gifted a post
  Future<PostGift?> _getUserGiftForPost(String feedId, String userId) async {
    try {
      final response = await _supabase
          .from('post_gifts')
          .select()
          .eq('feed_id', feedId)
          .eq('gifter_user_id', userId)
          .eq('status', 'completed')
          .maybeSingle();

      if (response == null) return null;

      return PostGift.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get User Gift'));
      return null;
    }
  }

  /// Get user's gifting history
  Future<List<PostGift>> getUserGiftHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _supabase.rpc(
        'get_user_gift_history',
        params: {
          'p_user_id': currentUser.id,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      return (response as List)
          .map((json) => PostGift.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Gift History'));
      return [];
    }
  }

  /// Get gifts received by current user
  Future<List<PostGift>> getUserGiftsReceived({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _supabase.rpc(
        'get_user_gifts_received',
        params: {
          'p_user_id': currentUser.id,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      return (response as List)
          .map((json) => PostGift.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Gifts Received'));
      return [];
    }
  }

  /// Get available gift presets
  Future<List<GiftPreset>> getGiftPresets() async {
    try {
      final response = await _supabase
          .from('gift_presets')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return (response as List)
          .map((json) => GiftPreset.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Gift Presets'));
      // Return default presets if database fetch fails
      return _getDefaultPresets();
    }
  }

  /// Get default gift presets (fallback)
  List<GiftPreset> _getDefaultPresets() {
    final now = DateTime.now();
    return [
      GiftPreset(
        id: 'small',
        name: 'Like',
        emoji: '👍',
        pointsAmount: 10,
        displayOrder: 1,
        createdAt: now,
      ),
      GiftPreset(
        id: 'medium',
        name: 'Love',
        emoji: '❤️',
        pointsAmount: 50,
        displayOrder: 2,
        createdAt: now,
      ),
      GiftPreset(
        id: 'large',
        name: 'Fire',
        emoji: '🔥',
        pointsAmount: 100,
        displayOrder: 3,
        createdAt: now,
      ),
    ];
  }

  /// Get user's current points balance
  Future<int> getUserPointsBalance() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return 0;

      final response = await _supabase
          .from('user_subscriptions')
          .select('reward_points')
          .eq('user_id', currentUser.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return 0;

      return response['reward_points'] as int? ?? 0;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Get Points Balance'));
      return 0;
    }
  }

  /// Check if user can gift (has active subscription and points)
  Future<bool> canUserGift({required int pointsRequired}) async {
    try {
      final balance = await getUserPointsBalance();
      return balance >= pointsRequired;
    } catch (e, stackTrace) {
      debugPrint(ErrorHandler.formatForLogging(e, stackTrace, context: 'Can User Gift'));
      return false;
    }
  }
}
