// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_by_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventByCategoryModelImpl _$$EventByCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EventByCategoryModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImage: json['cover_image'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      clubId: json['club_id'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      categoryName: json['category_name'] as String,
    );

Map<String, dynamic> _$$EventByCategoryModelImplToJson(
        _$EventByCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'cover_image': instance.coverImage,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'club_id': instance.clubId,
      'location': instance.location,
      'created_at': instance.createdAt.toIso8601String(),
      'category_name': instance.categoryName,
    };
