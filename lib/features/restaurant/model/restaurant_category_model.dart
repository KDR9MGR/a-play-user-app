import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_category_model.freezed.dart';
part 'restaurant_category_model.g.dart';

@freezed
class RestaurantCategory with _$RestaurantCategory {
  const factory RestaurantCategory({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _RestaurantCategory;

  factory RestaurantCategory.fromJson(Map<String, dynamic> json) =>
      _$RestaurantCategoryFromJson(json);
}