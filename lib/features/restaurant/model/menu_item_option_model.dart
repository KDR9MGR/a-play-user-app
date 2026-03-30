import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item_option_model.freezed.dart';
part 'menu_item_option_model.g.dart';

@freezed
class MenuItemOption with _$MenuItemOption {
  const factory MenuItemOption({
    required String id,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    @JsonKey(name: 'option_type') required String optionType,
    @JsonKey(name: 'option_name') required String optionName,
    @JsonKey(name: 'price_modifier') @Default(0.0) double priceModifier,
    @JsonKey(name: 'is_required') @Default(false) bool isRequired,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MenuItemOption;

  factory MenuItemOption.fromJson(Map<String, dynamic> json) =>
      _$MenuItemOptionFromJson(json);
}