import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'blogger_follow_model.freezed.dart';
part 'blogger_follow_model.g.dart';

/// Model for blogger follow relationships
@freezed
class BloggerFollow with _$BloggerFollow {
  const factory BloggerFollow({
    required String id,
    @JsonKey(name: 'follower_id') required String followerId, // User who is following
    @JsonKey(name: 'following_id') required String followingId, // Blogger being followed
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BloggerFollow;

  factory BloggerFollow.create({
    required String followerId,
    required String followingId,
  }) {
    return BloggerFollow(
      id: const Uuid().v4(),
      followerId: followerId,
      followingId: followingId,
      createdAt: DateTime.now(),
    );
  }

  factory BloggerFollow.fromJson(Map<String, dynamic> json) => _$BloggerFollowFromJson(json);
}

/// Post duration options for bloggers
enum PostDuration {
  hours24(24, '24 Hours'),
  week(168, '1 Week'),
  month(720, '1 Month'),
  permanent(0, 'Permanent');

  final int hours;
  final String label;

  const PostDuration(this.hours, this.label);

  static PostDuration fromHours(int hours) {
    return PostDuration.values.firstWhere(
      (d) => d.hours == hours,
      orElse: () => PostDuration.hours24,
    );
  }
}
