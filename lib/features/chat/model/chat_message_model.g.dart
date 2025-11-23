// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      roomId: json['roomId'] as String,
      receiverId: json['receiverId'] as String?,
      messageType: json['messageType'] as String? ?? 'text',
      attachmentUrl: json['attachmentUrl'] as String?,
      replyTo: json['replyTo'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'senderId': instance.senderId,
      'roomId': instance.roomId,
      'receiverId': instance.receiverId,
      'messageType': instance.messageType,
      'attachmentUrl': instance.attachmentUrl,
      'replyTo': instance.replyTo,
      'isEdited': instance.isEdited,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'reactions': instance.reactions,
    };

_$MessageReactionImpl _$$MessageReactionImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageReactionImpl(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$MessageReactionImplToJson(
        _$MessageReactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'emoji': instance.emoji,
      'createdAt': instance.createdAt.toIso8601String(),
      'userName': instance.userName,
    };
