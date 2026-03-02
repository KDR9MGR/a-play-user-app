// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastCategoryImpl _$$PodcastCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$PodcastCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$PodcastCategoryImplToJson(
        _$PodcastCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emoji': instance.emoji,
      'subcategories': instance.subcategories,
      'isActive': instance.isActive,
    };
