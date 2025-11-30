import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/youtube_content.dart';
import '../../../core/services/auth_service.dart';

class UserFavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all favorites for the current user
  Future<List<YoutubeContent>> getUserFavorites() async {
    return await AuthService.withAuthRetry(() async {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.from('user_favorites').select('''
            id,
            content_id,
            created_at,
            youtube_content:content_id (
              id,
              video_id,
              title,
              description,
              category,
              year,
              maturity_rating,
              seasons,
              content_type,
              section_name,
              is_featured,
              youtube_url,
              created_at,
              updated_at
            )
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return (response as List).map((item) {
        final contentData = item['youtube_content'] as Map<String, dynamic>;
        return YoutubeContent.fromJson({
          ...contentData,
          'created_at': _formatDateTimeForJson(contentData['created_at']),
          'updated_at': _formatDateTimeForJson(contentData['updated_at']),
        });
      }).toList();
    });
  }

  // Check if content is in user's favorites
  Future<bool> isContentInFavorites(String contentId) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return false;

        final response = await _supabase
            .from('user_favorites')
            .select('id')
            .eq('user_id', userId)
            .eq('content_id', contentId)
            .maybeSingle();

        return response != null;
      });
    } catch (e) {
      return false;
    }
  }

  // Add content to user's favorites
  Future<void> addToFavorites(String contentId) async {
    return await AuthService.withAuthRetry(() async {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('user_favorites').insert({
        'user_id': userId,
        'content_id': contentId,
      });
    });
  }

  // Remove content from user's favorites
  Future<void> removeFromFavorites(String contentId) async {
    return await AuthService.withAuthRetry(() async {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('content_id', contentId);
    });
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String contentId) async {
    final isCurrentlyFavorite = await isContentInFavorites(contentId);

    if (isCurrentlyFavorite) {
      await removeFromFavorites(contentId);
      return false;
    } else {
      await addToFavorites(contentId);
      return true;
    }
  }

  String _formatDateTimeForJson(dynamic dateTime) {
    if (dateTime == null) return DateTime.now().toIso8601String();
    if (dateTime is String) return dateTime;
    if (dateTime is DateTime) return dateTime.toIso8601String();
    return DateTime.now().toIso8601String();
  }
}
