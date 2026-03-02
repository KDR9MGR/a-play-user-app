import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/feed_model.dart';
import '../../../data/models/event_model.dart';
import 'package:flutter/foundation.dart';

class FeedService {
  final SupabaseClient _supabase;

  FeedService(this._supabase);

  SupabaseClient get client => _supabase;

  // Get all feeds with like status for current user
  Future<List<FeedModel>> getFeeds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      // Use the stored procedure that correctly checks like status
      final response = await _supabase
          .rpc('get_feeds_with_like_status', params: {
            'current_user_id': userId
          })
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      return (response as List<dynamic>)
          .map((feed) => FeedModel.fromJson(feed))
          .toList();
    } catch (e) {
      debugPrint('Error fetching feeds: $e');
      throw Exception('Failed to fetch feeds: ${e.toString()}');
    }
  }

  // Create a new feed post
  Future<FeedModel> createFeed({
    required String content,
    String? imageUrl,
    String? eventId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final feedModel = FeedModel.create(
        userId: userId,
        content: content,
        imageUrl: imageUrl,
        eventId: eventId,
      );

      final response = await _supabase
          .from('feeds')
          .insert(feedModel.toSupabase())
          .select()
          .single();

      return FeedModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create feed: ${e.toString()}');
    }
  }

  // Create a new post (wrapper around createFeed)
  Future<FeedModel> createPost(String content) async {
    return createFeed(content: content);
  }

  // Like a feed post
  Future<void> likeFeed(String feedId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final feedLike = FeedLike.create(
        feedId: feedId,
        userId: userId,
      );

      await _supabase
          .from('feed_likes')
          .insert({
            'feed_id': feedLike.feedId,
            'user_id': feedLike.userId,
          });
    } catch (e) {
      throw Exception('Failed to like feed: ${e.toString()}');
    }
  }

  // Unlike a feed post
  Future<void> unlikeFeed(String feedId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      await _supabase
          .from('feed_likes')
          .delete()
          .match({
            'feed_id': feedId,
            'user_id': userId,
          });
    } catch (e) {
      throw Exception('Failed to unlike feed: ${e.toString()}');
    }
  }

  // Add a comment to a feed post
  Future<FeedComment> addComment({
    required String feedId,
    required String content,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final comment = FeedComment.create(
        feedId: feedId,
        userId: userId,
        content: content,
      );

      final response = await _supabase
          .from('feed_comments')
          .insert({
            'feed_id': comment.feedId,
            'user_id': comment.userId,
            'content': comment.content,
          })
          .select()
          .single();

      return FeedComment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  // Get comments for a feed post
  Future<List<FeedComment>> getComments(String feedId) async {
    try {
      final response = await _supabase
          .from('feed_comments')
          .select()
          .eq('feed_id', feedId)
          .order('created_at', ascending: false);

      return response.map((comment) => FeedComment.fromJson(comment)).toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  // Delete a feed post
  Future<void> deleteFeed(String feedId) async {
    try {
      await _supabase
          .from('feeds')
          .delete()
          .eq('id', feedId);
    } catch (e) {
      throw Exception('Failed to delete feed: ${e.toString()}');
    }
  }

  // Get event details by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .single();

      return EventModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // NEW FEATURES: Dynamic Feed, Post Duration, Blogger Follow
  // ============================================================================

  /// Get random feeds (fresh content each time)
  /// Improvement 1: Dynamic feed load for fresh feed all the time
  Future<List<FeedModel>> getRandomFeeds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      // Use the updated RPC function that returns random feeds
      final response = await _supabase
          .rpc('get_feeds_with_like_status', params: {
            'current_user_id': userId
          });

      if (response == null) {
        return [];
      }

      return (response as List<dynamic>)
          .map((feed) => FeedModel.fromJson(feed))
          .toList();
    } catch (e) {
      debugPrint('Error fetching random feeds: $e');
      throw Exception('Failed to fetch feeds: ${e.toString()}');
    }
  }

  /// Create a feed post with custom duration
  /// Improvement 2: Post active duration (24hrs, 1 week, 1 month)
  Future<FeedModel> createFeedWithDuration({
    required String content,
    String? imageUrl,
    String? eventId,
    required int durationHours, // 24, 168 (1 week), 720 (1 month), or 0 (permanent)
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final now = DateTime.now();
      final expiresAt = durationHours > 0
          ? now.add(Duration(hours: durationHours))
          : null;

      final feedData = {
        'user_id': userId,
        'content': content,
        'image_url': imageUrl,
        'event_id': eventId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'duration_hours': durationHours,
      };

      final response = await _supabase
          .from('feeds')
          .insert(feedData)
          .select()
          .single();

      return FeedModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating feed with duration: $e');
      throw Exception('Failed to create feed: ${e.toString()}');
    }
  }

  /// Get feeds from followed bloggers only
  /// Improvement 3: Blogger profile follow options
  Future<List<FeedModel>> getFollowedFeeds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final response = await _supabase
          .rpc('get_followed_feeds', params: {
            'current_user_id': userId
          });

      if (response == null) {
        return [];
      }

      return (response as List<dynamic>)
          .map((feed) => FeedModel.fromJson(feed))
          .toList();
    } catch (e) {
      debugPrint('Error fetching followed feeds: $e');
      throw Exception('Failed to fetch followed feeds: ${e.toString()}');
    }
  }

  /// Follow a blogger
  Future<void> followBlogger(String bloggerUserId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      if (userId == bloggerUserId) {
        throw Exception('Cannot follow yourself');
      }

      await _supabase
          .from('blogger_follows')
          .insert({
            'follower_id': userId,
            'following_id': bloggerUserId,
          });
    } catch (e) {
      debugPrint('Error following blogger: $e');
      throw Exception('Failed to follow blogger: ${e.toString()}');
    }
  }

  /// Unfollow a blogger
  Future<void> unfollowBlogger(String bloggerUserId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      await _supabase
          .from('blogger_follows')
          .delete()
          .match({
            'follower_id': userId,
            'following_id': bloggerUserId,
          });
    } catch (e) {
      debugPrint('Error unfollowing blogger: $e');
      throw Exception('Failed to unfollow blogger: ${e.toString()}');
    }
  }

  /// Check if current user is following a blogger
  Future<bool> isFollowingBlogger(String bloggerUserId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      final response = await _supabase
          .from('blogger_follows')
          .select()
          .match({
            'follower_id': userId,
            'following_id': bloggerUserId,
          })
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  /// Get blogger's follower count
  Future<int> getBloggerFollowerCount(String bloggerUserId) async {
    try {
      final response = await _supabase
          .from('blogger_follows')
          .select()
          .eq('following_id', bloggerUserId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting follower count: $e');
      return 0;
    }
  }

  /// Get list of users the current user is following
  Future<List<String>> getFollowingList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('blogger_follows')
          .select('following_id')
          .eq('follower_id', userId);

      return (response as List<dynamic>)
          .map((item) => item['following_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error getting following list: $e');
      return [];
    }
  }
} 