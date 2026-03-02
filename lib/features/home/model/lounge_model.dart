import 'package:freezed_annotation/freezed_annotation.dart';

part 'lounge_model.freezed.dart';
part 'lounge_model.g.dart';

@freezed
class Lounge with _$Lounge {
  const factory Lounge({
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
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _Lounge;

  factory Lounge.fromJson(Map<String, dynamic> json) => _$LoungeFromJson(json);
}