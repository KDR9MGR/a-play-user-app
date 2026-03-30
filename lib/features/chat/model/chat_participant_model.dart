import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_participant_model.freezed.dart';
part 'chat_participant_model.g.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    required String chatRoomId,
    required String userId,
    required String username,
    String? avatarUrl,
    @Default(ParticipantRole.member) ParticipantRole role,
    DateTime? lastReadAt,
    @Default(false) bool isMuted,
    required DateTime joinedAt,
    DateTime? leftAt,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

enum ParticipantRole {
  admin,
  member,
}