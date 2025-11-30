import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_model.freezed.dart';
part 'friendship_model.g.dart';

@freezed
class Friendship with _$Friendship {
  const factory Friendship({
    required String id,
    required String userId,
    required String friendId,
    @Default('pending') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Additional fields for UI
    String? friendName,
    String? friendUsername,
    String? friendAvatarUrl,
    bool? friendIsOnline,
    String? friendStatus,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) = _Friendship;

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);
}

enum FriendshipStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('blocked')
  blocked,
}

extension FriendshipStatusExtension on FriendshipStatus {
  String get value {
    switch (this) {
      case FriendshipStatus.pending:
        return 'pending';
      case FriendshipStatus.accepted:
        return 'accepted';
      case FriendshipStatus.blocked:
        return 'blocked';
    }
  }
  
  bool get isAccepted => this == FriendshipStatus.accepted;
  bool get isPending => this == FriendshipStatus.pending;
  bool get isBlocked => this == FriendshipStatus.blocked;
}