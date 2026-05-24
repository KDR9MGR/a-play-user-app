// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concierge_request_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConciergeRequestTrackingImpl _$$ConciergeRequestTrackingImplFromJson(
        Map<String, dynamic> json) =>
    _$ConciergeRequestTrackingImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      requestCount: (json['request_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ConciergeRequestTrackingImplToJson(
        _$ConciergeRequestTrackingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'month': instance.month,
      'year': instance.year,
      'request_count': instance.requestCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
