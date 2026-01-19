// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concierge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConciergeRequestImpl _$$ConciergeRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ConciergeRequestImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      status: $enumDecodeNullable(_$RequestStatusEnumMap, json['status']) ??
          RequestStatus.pending,
      isUrgent: json['is_urgent'] as bool? ?? false,
      requestedAt: json['requested_at'] == null
          ? null
          : DateTime.parse(json['requested_at'] as String),
      additionalDetails: json['additional_details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ConciergeRequestImplToJson(
        _$ConciergeRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'category': instance.category,
      'service_name': instance.serviceName,
      'description': instance.description,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'is_urgent': instance.isUrgent,
      'requested_at': instance.requestedAt?.toIso8601String(),
      'additional_details': instance.additionalDetails,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.inProgress: 'in_progress',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
};
