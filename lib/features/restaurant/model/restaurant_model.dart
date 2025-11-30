import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_model.freezed.dart';
part 'restaurant_model.g.dart';

@freezed
class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    required String address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'price_range') int? priceRange,
    @JsonKey(name: 'delivery_fee') @Default(0.0) double deliveryFee,
    @JsonKey(name: 'minimum_order') @Default(0.0) double minimumOrder,
    @JsonKey(name: 'estimated_delivery_time') @Default(30) int estimatedDeliveryTime,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'accepts_cash') @Default(true) bool acceptsCash,
    @JsonKey(name: 'accepts_card') @Default(true) bool acceptsCard,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
}