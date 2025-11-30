import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item_model.freezed.dart';
part 'menu_item_model.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    @JsonKey(name: 'restaurant_id') required String restaurantId,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    String? description,
    required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'is_vegetarian') @Default(false) bool isVegetarian,
    @JsonKey(name: 'is_vegan') @Default(false) bool isVegan,
    @JsonKey(name: 'is_spicy') @Default(false) bool isSpicy,
    @Default([]) List<String> allergens,
    int? calories,
    @JsonKey(name: 'preparation_time') @Default(15) int preparationTime,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'is_popular') @Default(false) bool isPopular,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}