import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'referral_model.freezed.dart';
part 'referral_model.g.dart';

@freezed
class Referral with _$Referral {
  const factory Referral({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'referral_code') required String referralCode,
    @JsonKey(name: 'referral_count') @Default(0) int referralCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Referral;

  factory Referral.fromJson(Map<String, dynamic> json) => 
      _$ReferralFromJson(json);
}

@freezed
class ReferralHistory with _$ReferralHistory {
  const factory ReferralHistory({
    required String id,
    @JsonKey(name: 'referred_user_id') required String userId,
    @JsonKey(name: 'referrer_user_id') required String referrerId,
    @JsonKey(name: 'points_earned') required int pointsEarned,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReferralHistory;

  factory ReferralHistory.fromJson(Map<String, dynamic> json) => 
      _$ReferralHistoryFromJson(json);
}

@freezed
class UserPoints with _$UserPoints {
  const factory UserPoints({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'available_points') @Default(0) int availablePoints,
    @JsonKey(name: 'used_points') @Default(0) int usedPoints,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
    @JsonKey(name: 'tier_name') String? membershipTierName,
    @JsonKey(name: 'tier_benefits') String? tierBenefits,
    @JsonKey(name: 'tier_min_points') int? tierMinPoints,
    @JsonKey(name: 'tier_max_points') int? tierMaxPoints,
    String? username,
  }) = _UserPoints;

  const UserPoints._();

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      id: json['id'] as String? ?? json['user_id'] as String?,
      userId: json['user_id'] as String,
      totalPoints: json['total_points'] as int? ?? 0,
      availablePoints: json['available_points'] as int? ?? 0,
      usedPoints: json['used_points'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      membershipTierName: json['tier_name'] as String?,
      tierBenefits: json['tier_benefits'] as String?,
      tierMinPoints: json['tier_min_points'] as int?,
      tierMaxPoints: json['tier_max_points'] as int?,
      username: json['username'] as String?,
    );
  }
}

@freezed
class PointTransaction with _$PointTransaction {
  const factory PointTransaction({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required int points,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @Default('') String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    Map<String, dynamic>? metadata,
  }) = _PointTransaction;

  factory PointTransaction.fromJson(Map<String, dynamic> json) => 
      _$PointTransactionFromJson(json);
}

@freezed
class MembershipTier with _$MembershipTier {
  const factory MembershipTier({
    required String id,
    required String name,
    @JsonKey(name: 'min_points') required int minPoints,
    @JsonKey(name: 'max_points') int? maxPoints,
    String? benefits,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MembershipTier;

  factory MembershipTier.fromJson(Map<String, dynamic> json) => 
      _$MembershipTierFromJson(json);
}

@freezed
class UserChallenge with _$UserChallenge {
  const factory UserChallenge({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'challenge_type') required String challengeType,
    @JsonKey(name: 'target_count') required int targetCount,
    @JsonKey(name: 'period_days') required int periodDays,
    @JsonKey(name: 'reward_points') required int rewardPoints,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserChallenge;

  factory UserChallenge.fromJson(Map<String, dynamic> json) => 
      _$UserChallengeFromJson(json);
}

@freezed
class UserChallengeProgress with _$UserChallengeProgress {
  const factory UserChallengeProgress({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'challenge_id') required String challengeId,
    @JsonKey(name: 'current_count') @Default(0) int currentCount,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @Default(false) bool completed,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    UserChallenge? challenge,
  }) = _UserChallengeProgress;

  factory UserChallengeProgress.fromJson(Map<String, dynamic> json) => 
      _$UserChallengeProgressFromJson(json);
}

@freezed
class TimeLimitedOffer with _$TimeLimitedOffer {
  const factory TimeLimitedOffer({
    required String id,
    required String name,
    String? description,
    @Default(1.0) double multiplier,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TimeLimitedOffer;

  factory TimeLimitedOffer.fromJson(Map<String, dynamic> json) => 
      _$TimeLimitedOfferFromJson(json);
}