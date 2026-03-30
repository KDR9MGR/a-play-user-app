import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required String name,
    @JsonKey(name: 'participant_ids') List<String>? participantIds,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Additional fields for UI
    @Default([]) List<ChatParticipant> participants,
    @JsonKey(name: 'unread_count') int? unreadCount,
    @JsonKey(name: 'is_online') bool? isOnline,
    @JsonKey(name: 'room_type_id') String? roomTypeId,
    @JsonKey(name: 'room_type') RoomType? roomType,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    @JsonKey(name: 'chat_room_id') required String chatRoomId,
    @JsonKey(name: 'user_id') required String userId,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('member') String role,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
    @JsonKey(name: 'is_muted') @Default(false) bool isMuted,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'left_at') DateTime? leftAt,
    
    // Additional fields for UI
    @JsonKey(name: 'is_online') bool? isOnline,
    String? status,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

@freezed
class RoomType with _$RoomType {
  const factory RoomType({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RoomType;

  factory RoomType.fromJson(Map<String, dynamic> json) =>
      _$RoomTypeFromJson(json);
}

enum ParticipantRole {
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member,
}

extension ParticipantRoleExtension on ParticipantRole {
  String get value {
    switch (this) {
      case ParticipantRole.admin:
        return 'admin';
      case ParticipantRole.moderator:
        return 'moderator';
      case ParticipantRole.member:
        return 'member';
    }
  }
  
  bool get canModerate => this == ParticipantRole.admin || this == ParticipantRole.moderator;
  bool get isAdmin => this == ParticipantRole.admin;
}