// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceEventModelImpl _$$ServiceEventModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceEventModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      coverImage: json['cover_image'] as String,
      createdAt: json['created_at'] as String,
      clubId: json['club_id'] as String?,
      category: json['category_name'] as String?,
    );

Map<String, dynamic> _$$ServiceEventModelImplToJson(
        _$ServiceEventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'cover_image': instance.coverImage,
      'created_at': instance.createdAt,
      'club_id': instance.clubId,
      'category_name': instance.category,
    };
