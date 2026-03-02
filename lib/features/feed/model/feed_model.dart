import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'feed_model.freezed.dart';
part 'feed_model.g.dart';

@freezed
class FeedModel with _$FeedModel {
  const FeedModel._();

  const factory FeedModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'event_id') String? eventId,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // New fields for feed improvements
    @JsonKey(name: 'expires_at') DateTime? expiresAt, // Post expiration date
    @JsonKey(name: 'duration_hours') @Default(24) int durationHours, // Post active duration (24hrs, 168hrs=1week, 720hrs=1month)
    @JsonKey(name: 'is_following_author') @Default(false) bool isFollowingAuthor, // User following the blogger
    @JsonKey(name: 'author_name') String? authorName, // Blogger's display name
    @JsonKey(name: 'author_avatar') String? authorAvatar, // Blogger's profile picture
    @JsonKey(name: 'follower_count') @Default(0) int followerCount, // How many followers the author has
  }) = _FeedModel;

  factory FeedModel.create({
    required String userId,
    required String content,
    String? imageUrl,
    String? eventId,
    int durationHours = 24, // Default to 24 hours
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: durationHours));

    return FeedModel(
      id: const Uuid().v4(),
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      eventId: eventId,
      createdAt: now,
      updatedAt: now,
      expiresAt: expiresAt,
      durationHours: durationHours,
    );
  }

  factory FeedModel.fromJson(Map<String, dynamic> json) => _$FeedModelFromJson(json);

  Map<String, dynamic> toSupabase() {
    // Note: After running build_runner, Freezed will generate proper getters
    // For now, we'll let the generated code handle the map conversion
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
      'event_id': eventId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'duration_hours': durationHours,
    };
  }
}

@freezed
class FeedComment with _$FeedComment {
  const FeedComment._();

  const factory FeedComment({
    required String id,
    @JsonKey(name: 'feed_id') required String feedId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FeedComment;

  factory FeedComment.create({
    required String feedId,
    required String userId,
    required String content,
  }) {
    final now = DateTime.now();
    return FeedComment(
      id: const Uuid().v4(),
      feedId: feedId,
      userId: userId,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory FeedComment.fromJson(Map<String, dynamic> json) => _$FeedCommentFromJson(json);
}

@freezed
class FeedLike with _$FeedLike {
  const FeedLike._();

  const factory FeedLike({
    required String id,
    @JsonKey(name: 'feed_id') required String feedId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FeedLike;

  factory FeedLike.create({
    required String feedId,
    required String userId,
  }) {
    return FeedLike(
      id: const Uuid().v4(),
      feedId: feedId,
      userId: userId,
      createdAt: DateTime.now(),
    );
  }

  factory FeedLike.fromJson(Map<String, dynamic> json) => _$FeedLikeFromJson(json);
}
