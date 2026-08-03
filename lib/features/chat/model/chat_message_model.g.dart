// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String,
      roomId: json['room_id'] as String,
      receiverId: json['receiver_id'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      attachmentUrl: json['attachment_url'] as String?,
      replyTo: json['reply_to'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      senderName: json['senderName'] as String?,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'sender_id': instance.senderId,
      'room_id': instance.roomId,
      'receiver_id': instance.receiverId,
      'message_type': instance.messageType,
      'attachment_url': instance.attachmentUrl,
      'reply_to': instance.replyTo,
      'is_edited': instance.isEdited,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'reactions': instance.reactions,
    };

_$MessageReactionImpl _$$MessageReactionImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageReactionImpl(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$MessageReactionImplToJson(
        _$MessageReactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_id': instance.messageId,
      'user_id': instance.userId,
      'emoji': instance.emoji,
      'created_at': instance.createdAt.toIso8601String(),
      'userName': instance.userName,
    };
