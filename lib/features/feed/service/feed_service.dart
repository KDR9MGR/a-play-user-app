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
} 