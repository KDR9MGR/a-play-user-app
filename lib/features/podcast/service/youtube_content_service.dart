import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/youtube_content.dart';
import '../../../core/services/auth_service.dart';

class YoutubeContentService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all YouTube content organized by sections
  Future<YoutubeContentSections> getContentSections() async {
    return await AuthService.withAuthRetry(() async {
      final response = await _client
          .from('youtube_content')
          .select('*')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      
      final List<YoutubeContent> allContent = data
          .map((item) => YoutubeContent.fromJson(_mapDatabaseToModel(item)))
          .toList();

      // Group content by section
      final featured = allContent
          .where((content) => content.isFeatured)
          .toList();

      final popular = allContent
          .where((content) => content.sectionName == 'Popular on APlay')
          .toList();

      final trending = allContent
          .where((content) => content.sectionName == 'Trending Now')
          .toList();

      final action = allContent
          .where((content) => content.sectionName == 'Action')
          .toList();

      return YoutubeContentSections(
        featured: featured,
        popular: popular,
        trending: trending,
        action: action,
      );
    });
  }

  /// Fetch featured content for carousel
  Future<List<YoutubeContent>> getFeaturedContent() async {
    return await AuthService.withAuthRetry(() async {
      final response = await _client
          .from('youtube_content')
          .select('*')
          .eq('is_featured', true)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      
      return data
          .map((item) => YoutubeContent.fromJson(_mapDatabaseToModel(item)))
          .toList();
    });
  }

  /// Fetch content by section name
  Future<List<YoutubeContent>> getContentBySection(String sectionName) async {
    return await AuthService.withAuthRetry(() async {
      final response = await _client
          .from('youtube_content')
          .select('*')
          .eq('section_name', sectionName)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      
      return data
          .map((item) => YoutubeContent.fromJson(_mapDatabaseToModel(item)))
          .toList();
    });
  }

  /// Fetch content by category
  Future<List<YoutubeContent>> getContentByCategory(String categoryName) async {
    return await AuthService.withAuthRetry(() async {
      if (categoryName == 'all') {
        // Return all content
        final response = await _client
            .from('youtube_content')
            .select('*')
            .order('created_at', ascending: false);

        final data = response as List<dynamic>;
        
        return data
            .map((item) => YoutubeContent.fromJson(_mapDatabaseToModel(item)))
            .toList();
      } else {
        // Filter by category
        final response = await _client
            .from('youtube_content')
            .select('*, categories!inner(*)')
            .eq('categories.name', categoryName)
            .order('created_at', ascending: false);

        final data = response as List<dynamic>;
        
        return data
            .map((item) => YoutubeContent.fromJson(_mapDatabaseToModel(item)))
            .toList();
      }
    });
  }

  /// Fetch content by video ID
  Future<YoutubeContent?> getContentByVideoId(String videoId) async {
    try {
      return await AuthService.withAuthRetry(() async {
        final response = await _client
            .from('youtube_content')
            .select('*')
            .eq('video_id', videoId)
            .single();

        return YoutubeContent.fromJson(_mapDatabaseToModel(response));
      });
    } catch (e) {
      return null;
    }
  }

  /// Add new content (admin only - handled by RLS policy)
  Future<YoutubeContent> addContent({
    required String youtubeUrl,
    String? title,
    String? description,
    String? category,
    int? year,
    String? maturityRating,
    String? seasons,
    String contentType = 'video',
    String? sectionName,
    bool isFeatured = false,
  }) async {
    return await AuthService.withAuthRetry(() async {
      // Extract video ID from YouTube URL
      final videoId = _extractVideoIdFromUrl(youtubeUrl);
      
      // If title is not provided, we'll fetch it from YouTube API later
      final contentTitle = title ?? 'YouTube Video';
      
      final response = await _client
          .from('youtube_content')
          .insert({
            'video_id': videoId,
            'youtube_url': youtubeUrl,
            'title': contentTitle,
            'description': description,
            'category': category,
            'year': year,
            'maturity_rating': maturityRating,
            'seasons': seasons,
            'content_type': contentType,
            'section_name': sectionName,
            'is_featured': isFeatured,
          })
          .select()
          .single();

      return YoutubeContent.fromJson(_mapDatabaseToModel(response));
    });
  }

  /// Update content (admin only - handled by RLS policy)
  Future<YoutubeContent> updateContent({
    required String id,
    String? youtubeUrl,
    String? title,
    String? description,
    String? category,
    int? year,
    String? maturityRating,
    String? seasons,
    String? contentType,
    String? sectionName,
    bool? isFeatured,
  }) async {
    return await AuthService.withAuthRetry(() async {
      final updateData = <String, dynamic>{};
      
      if (youtubeUrl != null) {
        updateData['youtube_url'] = youtubeUrl;
        updateData['video_id'] = _extractVideoIdFromUrl(youtubeUrl);
      }
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (year != null) updateData['year'] = year;
      if (maturityRating != null) updateData['maturity_rating'] = maturityRating;
      if (seasons != null) updateData['seasons'] = seasons;
      if (contentType != null) updateData['content_type'] = contentType;
      if (sectionName != null) updateData['section_name'] = sectionName;
      if (isFeatured != null) updateData['is_featured'] = isFeatured;

      final response = await _client
          .from('youtube_content')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return YoutubeContent.fromJson(_mapDatabaseToModel(response));
    });
  }

  /// Delete content (admin only - handled by RLS policy)
  Future<void> deleteContent(String id) async {
    return await AuthService.withAuthRetry(() async {
      await _client
          .from('youtube_content')
          .delete()
          .eq('id', id);
    });
  }

  /// Map database fields to model fields (handling snake_case to camelCase)
  Map<String, dynamic> _mapDatabaseToModel(Map<String, dynamic> dbData) {
    final rawYoutubeUrl = dbData['youtube_url'] as String?;
    final rawVideoId = dbData['video_id'] as String?;
    return {
      'id': dbData['id']?.toString() ?? '',
      'videoId': rawVideoId ?? (rawYoutubeUrl != null ? _extractVideoIdFromUrl(rawYoutubeUrl) : ''),
      'title': dbData['title'] ?? 'Untitled',
      'description': dbData['description'],
      'category': dbData['category'],
      'year': dbData['year'],
      'maturityRating': dbData['maturity_rating'],
      'seasons': dbData['seasons'],
      'contentType': dbData['content_type'] ?? 'video',
      'sectionName': dbData['section_name'],
      'isFeatured': dbData['is_featured'] ?? false,
      'youtubeUrl': rawYoutubeUrl,
      'coverImage': dbData['cover_image'],
      'createdAt': _formatDateTimeForJson(dbData['created_at']),
      'updatedAt': _formatDateTimeForJson(dbData['updated_at']),
      'createdBy': dbData['created_by'],
    };
  }

  /// Helper method to safely parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// Helper method to format DateTime for JSON serialization
  String? _formatDateTimeForJson(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return value.toIso8601String();
    }
    
    if (value is String) {
      // Try to parse and reformat to ensure consistency
      try {
        final dateTime = DateTime.parse(value);
        return dateTime.toIso8601String();
      } catch (e) {
        // If it fails to parse, return as is (might be already a valid format)
        return value;
      }
    }
    
    return null;
  }

  /// Extract YouTube video ID from various URL formats
  String _extractVideoIdFromUrl(String url) {
    // Handle various YouTube URL formats
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    
    if (match != null) {
      return match.group(1)!;
    }
    
    // If no pattern matches, assume it's already a video ID
    return url;
  }
} 
