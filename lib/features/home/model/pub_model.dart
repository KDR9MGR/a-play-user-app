import 'package:freezed_annotation/freezed_annotation.dart';

part 'pub_model.freezed.dart';
part 'pub_model.g.dart';

@freezed
class Pub with _$Pub {
  const factory Pub({
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
    @JsonKey(name: 'price_range') @Default(2) int priceRange,
    @JsonKey(name: 'has_sports_viewing') @Default(true) bool hasSportsViewing,
    @JsonKey(name: 'has_live_music') @Default(false) bool hasLiveMusic,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _Pub;

  factory Pub.fromJson(Map<String, dynamic> json) => _$PubFromJson(json);
}