import 'package:freezed_annotation/freezed_annotation.dart';

part 'youtube_content.freezed.dart';
part 'youtube_content.g.dart';

@freezed
class YoutubeContent with _$YoutubeContent {
  const YoutubeContent._();
  
  const factory YoutubeContent({
    required String id,
    required String videoId,
    required String title,
    String? description,
    String? category,
    int? year,
    String? maturityRating,
    String? seasons,
    @Default('video') String contentType,
    String? sectionName,
    @Default(false) bool isFeatured,
    String? youtubeUrl,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) = _YoutubeContent;

  factory YoutubeContent.fromJson(Map<String, dynamic> json) =>
      _$YoutubeContentFromJson(json);

  // Helper methods for YouTube integration
  String get thumbnailUrl {
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  String get thumbnailUrlMedium {
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  String get thumbnailUrlHigh {
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  String get fallbackThumbnailUrl {
    if (videoId.isEmpty) return '';
    return 'https://img.youtube.com/vi/$videoId/default.jpg';
  }

  String get youtubeWatchUrl {
    if (videoId.isEmpty) return '';
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  // Auto-generate year from creation date
  int get autoYear {
    return createdAt?.year ?? DateTime.now().year;
  }
}

@freezed
class YoutubeContentSections with _$YoutubeContentSections {
  const factory YoutubeContentSections({
    @Default([]) List<YoutubeContent> featured,
    @Default([]) List<YoutubeContent> popular,
    @Default([]) List<YoutubeContent> trending,
    @Default([]) List<YoutubeContent> action,
  }) = _YoutubeContentSections;

  factory YoutubeContentSections.fromJson(Map<String, dynamic> json) =>
      _$YoutubeContentSectionsFromJson(json);
} 