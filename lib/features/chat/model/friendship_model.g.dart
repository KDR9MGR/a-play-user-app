// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipImpl _$$FriendshipImplFromJson(Map<String, dynamic> json) =>
    _$FriendshipImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      friendName: json['friendName'] as String?,
      friendUsername: json['friendUsername'] as String?,
      friendAvatarUrl: json['friendAvatarUrl'] as String?,
      friendIsOnline: json['friendIsOnline'] as bool?,
      friendStatus: json['friendStatus'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] == null
          ? null
          : DateTime.parse(json['lastMessageTime'] as String),
    );

Map<String, dynamic> _$$FriendshipImplToJson(_$FriendshipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'friendId': instance.friendId,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'friendName': instance.friendName,
      'friendUsername': instance.friendUsername,
      'friendAvatarUrl': instance.friendAvatarUrl,
      'friendIsOnline': instance.friendIsOnline,
      'friendStatus': instance.friendStatus,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime?.toIso8601String(),
    };
