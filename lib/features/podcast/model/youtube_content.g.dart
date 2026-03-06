// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YoutubeContentImpl _$$YoutubeContentImplFromJson(Map<String, dynamic> json) =>
    _$YoutubeContentImpl(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      year: (json['year'] as num?)?.toInt(),
      maturityRating: json['maturityRating'] as String?,
      seasons: json['seasons'] as String?,
      contentType: json['contentType'] as String? ?? 'video',
      sectionName: json['sectionName'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      youtubeUrl: json['youtubeUrl'] as String?,
      coverImage: json['coverImage'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$$YoutubeContentImplToJson(
        _$YoutubeContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'year': instance.year,
      'maturityRating': instance.maturityRating,
      'seasons': instance.seasons,
      'contentType': instance.contentType,
      'sectionName': instance.sectionName,
      'isFeatured': instance.isFeatured,
      'youtubeUrl': instance.youtubeUrl,
      'coverImage': instance.coverImage,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
    };

_$YoutubeContentSectionsImpl _$$YoutubeContentSectionsImplFromJson(
        Map<String, dynamic> json) =>
    _$YoutubeContentSectionsImpl(
      featured: (json['featured'] as List<dynamic>?)
              ?.map((e) => YoutubeContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      popular: (json['popular'] as List<dynamic>?)
              ?.map((e) => YoutubeContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trending: (json['trending'] as List<dynamic>?)
              ?.map((e) => YoutubeContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      action: (json['action'] as List<dynamic>?)
              ?.map((e) => YoutubeContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$YoutubeContentSectionsImplToJson(
        _$YoutubeContentSectionsImpl instance) =>
    <String, dynamic>{
      'featured': instance.featured,
      'popular': instance.popular,
      'trending': instance.trending,
      'action': instance.action,
    };
