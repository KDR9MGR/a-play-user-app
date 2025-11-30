import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item_model.dart';
import 'menu_item_option_model.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required MenuItem menuItem,
    required int quantity,
    @Default([]) List<MenuItemOption> selectedOptions,
    String? specialInstructions,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

extension CartItemExtension on CartItem {
  double get totalPrice {
    double optionsPrice = selectedOptions.fold(0.0, (sum, option) => sum + option.priceModifier);
    return (menuItem.price + optionsPrice) * quantity;
  }
}