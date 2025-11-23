import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/watch_progress.dart';
import '../../../core/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class WatchProgressService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get watch progress for a specific video and user
  Future<WatchProgress?> getWatchProgress(String contentId, String videoId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from('watch_progress')
          .select('*')
          .match({
            'user_id': userId,
            'content_id': contentId,
            'video_id': videoId,
          })
          .maybeSingle();

      if (response == null) return null;

      return WatchProgress.fromJson(_mapDatabaseToModel(response));
    } catch (e) {
      debugPrint('Error getting watch progress: $e');
      return null;
    }
  }

  /// Get all watch progress for current user (for continue watching section)
  Future<List<WatchProgress>> getUserWatchProgress({
    int limit = 20,
    bool onlyIncomplete = true,
  }) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return [];

        PostgrestFilterBuilder query = _client
            .from('watch_progress')
            .select('*');
        
        query = query.eq('user_id', userId);
        
        if (onlyIncomplete) {
          query = query.eq('is_completed', false);
        }
        
        final response = await query
             .order('last_watched', ascending: false)
             .limit(limit);
        final data = response as List<dynamic>;

        return data
            .map((item) => WatchProgress.fromJson(_mapDatabaseToModel(item)))
            .toList();
      });
    } catch (e) {
      debugPrint('Error getting user watch progress: $e');
      return [];
    }
  }

  /// Update or create watch progress
  Future<WatchProgress?> updateWatchProgress({
    required String contentId,
    required String videoId,
    required int watchedDuration,
    required int totalDuration,
  }) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return null;

        final isCompleted = watchedDuration >= (totalDuration * 0.90); // 90% completion
        final now = DateTime.now();

        // Check if record exists
        final existing = await getWatchProgress(contentId, videoId);

        Map<String, dynamic> data = {
          'user_id': userId,
          'content_id': contentId,
          'video_id': videoId,
          'watched_duration': watchedDuration,
          'total_duration': totalDuration,
          'last_watched': now.toIso8601String(),
          'is_completed': isCompleted,
          'updated_at': now.toIso8601String(),
        };

        final response = existing != null
            ? await _client
                .from('watch_progress')
                .update(data)
                .match({'id': existing.id})
                .select()
                .single()
            : await _client
                .from('watch_progress')
                .insert({
                  ...data,
                  'created_at': now.toIso8601String(),
                })
                .select()
                .single();

        return WatchProgress.fromJson(_mapDatabaseToModel(response));
      });
    } catch (e) {
      debugPrint('Error updating watch progress: $e');
      return null;
    }
  }

  /// Mark video as completed
  Future<bool> markAsCompleted(String contentId, String videoId) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return false;

        await _client
            .from('watch_progress')
            .update({
              'is_completed': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .match({
              'user_id': userId,
              'content_id': contentId,
              'video_id': videoId,
            });

        return true;
      });
    } catch (e) {
      debugPrint('Error marking as completed: $e');
      return false;
    }
  }

  /// Remove watch progress (for reset functionality)
  Future<bool> removeWatchProgress(String contentId, String videoId) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return false;

        await _client
            .from('watch_progress')
            .delete()
            .match({
              'user_id': userId,
              'content_id': contentId,
              'video_id': videoId,
            });

        return true;
      });
    } catch (e) {
      debugPrint('Error removing watch progress: $e');
      return false;
    }
  }

  /// Get continue watching content with progress info
  Future<List<Map<String, dynamic>>> getContinueWatchingWithContent() async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return [];

        // Get watch progress first
        final progressResponse = await _client
            .from('watch_progress')
            .select('*')
            .eq('user_id', userId)
            .eq('is_completed', false)
            .order('last_watched', ascending: false)
            .limit(10);

        final progressData = progressResponse as List<dynamic>;
        
        if (progressData.isEmpty) return [];

        // Get content IDs from progress data
        final contentIds = progressData
            .map((item) => item['content_id'])
            .where((id) => id != null)
            .toList();

        if (contentIds.isEmpty) return [];

        // Get corresponding youtube content
        final contentResponse = await _client
            .from('youtube_content')
            .select('*')
            .inFilter('id', contentIds);

        final contentDataList = contentResponse as List<dynamic>;
        
        // Map content by ID for quick lookup
        final contentMap = <String, Map<String, dynamic>>{};
        for (final content in contentDataList) {
          contentMap[content['id']] = content;
        }

        // Combine progress and content data
        return progressData.map((item) {
          final progressItem = _mapDatabaseToModel(item);
          final contentId = item['content_id'];
          final contentData = contentMap[contentId];
          
          return {
            'progress': WatchProgress.fromJson(progressItem),
            'content': contentData != null ? _mapYoutubeContentDatabaseToModel(contentData) : null,
          };
        }).where((item) => item['content'] != null).toList();
      });
    } catch (e) {
      debugPrint('Error getting continue watching with content: $e');
      return [];
    }
  }

  /// Map database fields to model fields (handling snake_case to camelCase)
  /// Map database response to model format
  Map<String, dynamic> _mapDatabaseToModel(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'userId': dbData['user_id'],
      'contentId': dbData['content_id'],
      'videoId': dbData['video_id'],
      'watchedDuration': dbData['watched_duration'],
      'totalDuration': dbData['total_duration'],
      'lastWatched': dbData['last_watched'],
      'isCompleted': dbData['is_completed'],
      'createdAt': dbData['created_at'],
      'updatedAt': dbData['updated_at'],
    };
  }

  /// Map YouTube content database fields to model format
  Map<String, dynamic> _mapYoutubeContentDatabaseToModel(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'videoId': dbData['video_id'],
      'title': dbData['title'],
      'description': dbData['description'],
      'category': dbData['category'],
      'year': dbData['year'],
      'maturityRating': dbData['maturity_rating'],
      'seasons': dbData['seasons'],
      'contentType': dbData['content_type'],
      'sectionName': dbData['section_name'],
      'isFeatured': dbData['is_featured'],
      'youtubeUrl': dbData['youtube_url'],
      'coverImage': dbData['cover_image'],
      'createdAt': dbData['created_at'],
      'updatedAt': dbData['updated_at'],
      'createdBy': dbData['created_by'],
    };
  }

}