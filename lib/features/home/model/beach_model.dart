import 'package:freezed_annotation/freezed_annotation.dart';

part 'beach_model.freezed.dart';
part 'beach_model.g.dart';

@freezed
class Beach with _$Beach {
  const factory Beach({
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
    @JsonKey(name: 'has_facilities') @Default(true) bool hasFacilities,
    @JsonKey(name: 'has_water_sports') @Default(false) bool hasWaterSports,
    @JsonKey(name: 'has_restaurant') @Default(false) bool hasRestaurant,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _Beach;

  factory Beach.fromJson(Map<String, dynamic> json) => _$BeachFromJson(json);
}