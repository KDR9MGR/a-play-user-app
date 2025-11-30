import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_category_model.freezed.dart';
part 'menu_category_model.g.dart';

@freezed
class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String id,
    @JsonKey(name: 'restaurant_id') required String restaurantId,
    required String name,
    String? description,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}