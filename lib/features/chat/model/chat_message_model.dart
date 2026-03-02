import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    @JsonKey(name: 'content') required String content,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'receiver_id') String? receiverId,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'attachment_url') String? attachmentUrl,
    @JsonKey(name: 'reply_to') String? replyTo,
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Additional fields for UI
    String? senderName,
    String? senderAvatarUrl,
    @Default([]) List<MessageReaction> reactions,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String id,
    @JsonKey(name: 'message_id') required String messageId,
    @JsonKey(name: 'user_id') required String userId,
    required String emoji,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    
    // Additional fields for UI
    String? userName,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('system')
  system,
}

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }
  
  bool get isMedia => this == MessageType.image || this == MessageType.file;
  bool get isSystem => this == MessageType.system;
}
