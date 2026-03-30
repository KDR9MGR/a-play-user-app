import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/cart_item_model.dart';
import '../model/menu_item_model.dart';
import '../model/menu_item_option_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem menuItem, {List<MenuItemOption>? options, String? instructions}) {
    final cartItem = CartItem(
      id: '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuItem: menuItem,
      quantity: 1,
      selectedOptions: options ?? [],
      specialInstructions: instructions,
    );

    final existingIndex = state.indexWhere((item) => 
        item.menuItem.id == menuItem.id && 
        _optionsEqual(item.selectedOptions, options ?? []) &&
        item.specialInstructions == instructions);

    if (existingIndex != -1) {
      updateQuantity(state[existingIndex].id, state[existingIndex].quantity + 1);
    } else {
      state = [...state, cartItem];
    }
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    state = state.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void removeItem(String cartItemId) {
    state = state.where((item) => item.id != cartItemId).toList();
  }

  void updateInstructions(String cartItemId, String instructions) {
    state = state.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(specialInstructions: instructions);
      }
      return item;
    }).toList();
  }

  void clearCart() {
    state = [];
  }

  bool _optionsEqual(List<MenuItemOption> options1, List<MenuItemOption> options2) {
    if (options1.length != options2.length) return false;
    
    final ids1 = options1.map((o) => o.id).toSet();
    final ids2 = options2.map((o) => o.id).toSet();
    
    return ids1.containsAll(ids2) && ids2.containsAll(ids1);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (total, item) => total + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0.0, (total, item) => total + item.totalPrice);
});

final cartRestaurantIdProvider = Provider<String?>((ref) {
  final cartItems = ref.watch(cartProvider);
  if (cartItems.isEmpty) return null;
  return cartItems.first.menuItem.restaurantId;
});