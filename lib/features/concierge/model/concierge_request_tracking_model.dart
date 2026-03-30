import 'package:freezed_annotation/freezed_annotation.dart';

part 'concierge_request_tracking_model.freezed.dart';
part 'concierge_request_tracking_model.g.dart';

/// Tracks monthly concierge request counts for enforcing tier limits
/// Gold tier: 3 requests/month
/// Platinum/Black tier: unlimited
@freezed
class ConciergeRequestTracking with _$ConciergeRequestTracking {
  const factory ConciergeRequestTracking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required int month, // 1-12
    required int year, // >= 2020
    @JsonKey(name: 'request_count') @Default(0) int requestCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ConciergeRequestTracking;

  factory ConciergeRequestTracking.fromJson(Map<String, dynamic> json) =>
      _$ConciergeRequestTrackingFromJson(json);
}

extension ConciergeRequestTrackingExtension on ConciergeRequestTracking {
  /// Check if the user has reached their monthly limit for the given tier
  bool hasReachedLimit(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return true; // Free tier has no concierge access
      case 'gold':
        return requestCount >= 3; // Gold tier: 3 requests/month
      case 'platinum':
      case 'black':
        return false; // Unlimited for Platinum and Black
      default:
        return true;
    }
  }

  /// Get remaining requests for the tier
  int getRemainingRequests(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return 0;
      case 'gold':
        return (3 - requestCount).clamp(0, 3);
      case 'platinum':
      case 'black':
        return 999; // Effectively unlimited
      default:
        return 0;
    }
  }

  /// Get the limit for the tier
  static int getLimitForTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return 0;
      case 'gold':
        return 3;
      case 'platinum':
      case 'black':
        return 999; // Unlimited
      default:
        return 0;
    }
  }
}
