import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../model/youtube_content.dart';
import '../service/youtube_content_service.dart';

class YoutubeContentController extends AsyncNotifier<YoutubeContentSections> {
  YoutubeContentService? _service;

  YoutubeContentService get service {
    _service ??= YoutubeContentService();
    return _service!;
  }

  @override
  Future<YoutubeContentSections> build() async {
    try {
      debugPrint('YoutubeContentController: Starting to fetch content...');
      final sections = await service.getContentSections();
      debugPrint('YoutubeContentController: Successfully fetched ${sections.featured.length} featured, ${sections.popular.length} popular, ${sections.trending.length} trending, ${sections.action.length} action items');
      return sections;
    } catch (e, stackTrace) {
      debugPrint('YoutubeContentController: Error in build method: $e');
      debugPrint('YoutubeContentController: Stack trace: $stackTrace');
      throw Exception('Failed to load YouTube content: $e');
    }
  }

  /// Refresh all content sections
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final sections = await service.getContentSections();
      state = AsyncData(sections);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Get featured content only
  Future<List<YoutubeContent>> getFeaturedContent() async {
    try {
      return await service.getFeaturedContent();
    } catch (e) {
      throw Exception('Failed to get featured content: $e');
    }
  }

  /// Get content by section
  Future<List<YoutubeContent>> getContentBySection(String sectionName) async {
    try {
      return await service.getContentBySection(sectionName);
    } catch (e) {
      throw Exception('Failed to get content for section: $e');
    }
  }

  /// Get content by video ID
  Future<YoutubeContent?> getContentByVideoId(String videoId) async {
    try {
      return await service.getContentByVideoId(videoId);
    } catch (e) {
      return null;
    }
  }

  /// Get content by category
  Future<List<YoutubeContent>> getContentByCategory(String categoryName) async {
    try {
      return await service.getContentByCategory(categoryName);
    } catch (e) {
      throw Exception('Failed to get content for category: $e');
    }
  }

  /// Add new content (admin only)
  Future<void> addContent({
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
    try {
      await service.addContent(
        youtubeUrl: youtubeUrl,
        title: title,
        description: description,
        category: category,
        year: year,
        maturityRating: maturityRating,
        seasons: seasons,
        contentType: contentType,
        sectionName: sectionName,
        isFeatured: isFeatured,
      );
      
      // Refresh the data
      await refresh();
    } catch (e) {
      throw Exception('Failed to add content: $e');
    }
  }

  /// Update existing content (admin only)
  Future<void> updateContent({
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
    try {
      await service.updateContent(
        id: id,
        youtubeUrl: youtubeUrl,
        title: title,
        description: description,
        category: category,
        year: year,
        maturityRating: maturityRating,
        seasons: seasons,
        contentType: contentType,
        sectionName: sectionName,
        isFeatured: isFeatured,
      );
      
      // Refresh the data
      await refresh();
    } catch (e) {
      throw Exception('Failed to update content: $e');
    }
  }

  /// Delete content (admin only)
  Future<void> deleteContent(String id) async {
    try {
      await service.deleteContent(id);
      
      // Refresh the data
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete content: $e');
    }
  }
} 