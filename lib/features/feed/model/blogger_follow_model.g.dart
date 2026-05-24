// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blogger_follow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BloggerFollowImpl _$$BloggerFollowImplFromJson(Map<String, dynamic> json) =>
    _$BloggerFollowImpl(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BloggerFollowImplToJson(_$BloggerFollowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'follower_id': instance.followerId,
      'following_id': instance.followingId,
      'created_at': instance.createdAt.toIso8601String(),
    };
