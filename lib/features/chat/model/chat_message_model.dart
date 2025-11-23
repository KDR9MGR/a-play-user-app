import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required String senderId,
    required String roomId,
    String? receiverId,
    @Default('text') String messageType,
    String? attachmentUrl,
    String? replyTo,
    @Default(false) bool isEdited,
    required DateTime createdAt,
    required DateTime updatedAt,
    
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
    required String messageId,
    required String userId,
    required String emoji,
    required DateTime createdAt,
    
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