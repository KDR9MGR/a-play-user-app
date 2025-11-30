import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/youtube_content_controller.dart';
import '../model/youtube_content.dart';

/// Provider for YouTube content sections
final youtubeContentProvider = AsyncNotifierProvider<YoutubeContentController, YoutubeContentSections>(
  () => YoutubeContentController(),
);

/// Provider for featured content only
final featuredContentProvider = FutureProvider<List<YoutubeContent>>((ref) async {
  final controller = ref.read(youtubeContentProvider.notifier);
  return await controller.getFeaturedContent();
});

/// Provider for specific section content
final sectionContentProvider = FutureProvider.family<List<YoutubeContent>, String>((ref, sectionName) async {
  final controller = ref.read(youtubeContentProvider.notifier);
  return await controller.getContentBySection(sectionName);
});

/// Provider for getting content by video ID
final videoContentProvider = FutureProvider.family<YoutubeContent?, String>((ref, videoId) async {
  final controller = ref.read(youtubeContentProvider.notifier);
  return await controller.getContentByVideoId(videoId);
});

/// Provider for content filtered by category
final contentByCategoryProvider = FutureProvider.family<List<YoutubeContent>, String>((ref, categoryName) async {
  final controller = ref.read(youtubeContentProvider.notifier);
  return controller.getContentByCategory(categoryName);
}); 