// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomImpl _$$ChatRoomImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      participantIds: (json['participant_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] == null
          ? null
          : DateTime.parse(json['last_message_time'] as String),
      isGroup: json['is_group'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unreadCount: (json['unread_count'] as num?)?.toInt(),
      isOnline: json['is_online'] as bool?,
      roomTypeId: json['room_type_id'] as String?,
      roomType: json['room_type'] == null
          ? null
          : RoomType.fromJson(json['room_type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatRoomImplToJson(_$ChatRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'participant_ids': instance.participantIds,
      'last_message': instance.lastMessage,
      'last_message_time': instance.lastMessageTime?.toIso8601String(),
      'is_group': instance.isGroup,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'participants': instance.participants,
      'unread_count': instance.unreadCount,
      'is_online': instance.isOnline,
      'room_type_id': instance.roomTypeId,
      'room_type': instance.roomType,
    };

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatParticipantImpl(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'member',
      lastReadAt: json['last_read_at'] == null
          ? null
          : DateTime.parse(json['last_read_at'] as String),
      isMuted: json['is_muted'] as bool? ?? false,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] == null
          ? null
          : DateTime.parse(json['left_at'] as String),
      isOnline: json['is_online'] as bool?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$ChatParticipantImplToJson(
        _$ChatParticipantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room_id': instance.chatRoomId,
      'user_id': instance.userId,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
      'last_read_at': instance.lastReadAt?.toIso8601String(),
      'is_muted': instance.isMuted,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'left_at': instance.leftAt?.toIso8601String(),
      'is_online': instance.isOnline,
      'status': instance.status,
    };

_$RoomTypeImpl _$$RoomTypeImplFromJson(Map<String, dynamic> json) =>
    _$RoomTypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RoomTypeImplToJson(_$RoomTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };
