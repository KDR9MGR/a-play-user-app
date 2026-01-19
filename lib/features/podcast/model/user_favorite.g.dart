// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserFavoriteImpl _$$UserFavoriteImplFromJson(Map<String, dynamic> json) =>
    _$UserFavoriteImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$UserFavoriteImplToJson(_$UserFavoriteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
