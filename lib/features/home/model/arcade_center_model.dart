import 'package:freezed_annotation/freezed_annotation.dart';

part 'arcade_center_model.freezed.dart';
part 'arcade_center_model.g.dart';

@freezed
class ArcadeCenter with _$ArcadeCenter {
  const factory ArcadeCenter({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @Default('') String address,
    String? phone,
    String? email,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'entry_fee') @Default(0.0) double entryFee,
    @JsonKey(name: 'has_vr_games') @Default(false) bool hasVrGames,
    @JsonKey(name: 'has_console_games') @Default(true) bool hasConsoleGames,
    @JsonKey(name: 'has_arcade_machines') @Default(true) bool hasArcadeMachines,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _ArcadeCenter;

  factory ArcadeCenter.fromJson(Map<String, dynamic> json) => _$ArcadeCenterFromJson(json);
}