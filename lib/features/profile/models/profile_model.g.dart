// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPremium: json['is_premium'] as bool? ?? false,
      isOrganizer: json['is_organizer'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'phone': instance.phone,
      'created_at': instance.createdAt.toIso8601String(),
      'is_premium': instance.isPremium,
      'is_organizer': instance.isOrganizer,
    };
