import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'post_gift_model.freezed.dart';
part 'post_gift_model.g.dart';

/// Gift types with predefined amounts
enum GiftType {
  @JsonValue('small')
  small('small', '👍', 'Like', 10),

  @JsonValue('medium')
  medium('medium', '❤️', 'Love', 50),

  @JsonValue('large')
  large('large', '🔥', 'Fire', 100),

  @JsonValue('custom')
  custom('custom', '💎', 'Custom', 0);

  final String id;
  final String emoji;
  final String label;
  final int defaultPoints;

  const GiftType(this.id, this.emoji, this.label, this.defaultPoints);

  static GiftType fromString(String value) {
    return GiftType.values.firstWhere(
      (type) => type.id == value,
      orElse: () => GiftType.small,
    );
  }
}

/// Gift status
enum GiftStatus {
  @JsonValue('pending')
  pending,

  @JsonValue('completed')
  completed,

  @JsonValue('refunded')
  refunded,

  @JsonValue('failed')
  failed;

  static GiftStatus fromString(String value) {
    return GiftStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => GiftStatus.pending,
    );
  }
}

/// Model for post gifts
@freezed
class PostGift with _$PostGift {
  const PostGift._();

  const factory PostGift({
    required String id,
    @JsonKey(name: 'feed_id') required String feedId,
    @JsonKey(name: 'gifter_user_id') required String gifterUserId,
    @JsonKey(name: 'receiver_user_id') required String receiverUserId,
    @JsonKey(name: 'points_amount') required int pointsAmount,
    String? message,
    @JsonKey(name: 'gift_type') required String giftType,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    // Additional fields from joins (not in DB)
    @JsonKey(name: 'gifter_name') String? gifterName,
    @JsonKey(name: 'gifter_avatar') String? gifterAvatar,
    @JsonKey(name: 'receiver_name') String? receiverName,
    @JsonKey(name: 'receiver_avatar') String? receiverAvatar,
  }) = _PostGift;

  factory PostGift.create({
    required String feedId,
    required String gifterUserId,
    required String receiverUserId,
    required int pointsAmount,
    required GiftType giftType,
    String? message,
  }) {
    return PostGift(
      id: const Uuid().v4(),
      feedId: feedId,
      gifterUserId: gifterUserId,
      receiverUserId: receiverUserId,
      pointsAmount: pointsAmount,
      message: message,
      giftType: giftType.id,
      status: GiftStatus.completed.name,
      createdAt: DateTime.now(),
    );
  }

  factory PostGift.fromJson(Map<String, dynamic> json) => _$PostGiftFromJson(json);

  /// Get the gift type enum from string
  GiftType get type => GiftType.fromString(giftType);

  /// Get the gift status enum from string
  GiftStatus get giftStatus => GiftStatus.fromString(status);

  /// Check if gift is completed
  bool get isCompleted => giftStatus == GiftStatus.completed;

  /// Get emoji for this gift type
  String get emoji => type.emoji;

  /// Get label for this gift type
  String get label => type.label;
}

/// Gift preset configuration
@freezed
class GiftPreset with _$GiftPreset {
  const GiftPreset._();

  const factory GiftPreset({
    required String id,
    required String name,
    required String emoji,
    @JsonKey(name: 'points_amount') required int pointsAmount,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _GiftPreset;

  factory GiftPreset.fromJson(Map<String, dynamic> json) => _$GiftPresetFromJson(json);

  /// Get corresponding GiftType enum
  GiftType get type => GiftType.fromString(id);
}

/// Gift summary for a post
@freezed
class PostGiftSummary with _$PostGiftSummary {
  const PostGiftSummary._();

  const factory PostGiftSummary({
    @JsonKey(name: 'total_gifts') @Default(0) int totalGifts,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'unique_gifters') @Default(0) int uniqueGifters,
    @JsonKey(name: 'gift_breakdown') @Default([]) List<GiftBreakdown> giftBreakdown,
    @JsonKey(name: 'user_has_gifted') @Default(false) bool userHasGifted,
    @JsonKey(name: 'user_gift_type') String? userGiftType,
  }) = _PostGiftSummary;

  factory PostGiftSummary.fromJson(Map<String, dynamic> json) => _$PostGiftSummaryFromJson(json);

  /// Check if post has any gifts
  bool get hasGifts => totalGifts > 0;

  /// Get formatted points text
  String get formattedPoints {
    if (totalPoints >= 1000) {
      return '${(totalPoints / 1000).toStringAsFixed(1)}K';
    }
    return totalPoints.toString();
  }
}

/// Gift breakdown by type
@freezed
class GiftBreakdown with _$GiftBreakdown {
  const GiftBreakdown._();

  const factory GiftBreakdown({
    @JsonKey(name: 'gift_type') required String giftType,
    required int count,
  }) = _GiftBreakdown;

  factory GiftBreakdown.fromJson(Map<String, dynamic> json) => _$GiftBreakdownFromJson(json);

  /// Get the gift type enum
  GiftType get type => GiftType.fromString(giftType);

  /// Get emoji for this gift type
  String get emoji => type.emoji;
}

/// Response from gift processing
@freezed
class GiftResponse with _$GiftResponse {
  const GiftResponse._();

  const factory GiftResponse({
    required bool success,
    String? error,
    @JsonKey(name: 'gift_id') String? giftId,
    @JsonKey(name: 'points_gifted') int? pointsGifted,
    @JsonKey(name: 'remaining_points') int? remainingPoints,
    @JsonKey(name: 'current_points') int? currentPoints,
    @JsonKey(name: 'required_points') int? requiredPoints,
  }) = _GiftResponse;

  factory GiftResponse.fromJson(Map<String, dynamic> json) => _$GiftResponseFromJson(json);

  /// Get user-friendly error message
  String get errorMessage {
    if (error == null) return '';
    if (error!.contains('Insufficient points')) {
      return 'Not enough points. You need $requiredPoints but have $currentPoints.';
    }
    if (error!.contains('already gifted')) {
      return 'You\'ve already gifted this post!';
    }
    if (error!.contains('No active subscription')) {
      return 'Please subscribe to gift points.';
    }
    return error!;
  }
}
