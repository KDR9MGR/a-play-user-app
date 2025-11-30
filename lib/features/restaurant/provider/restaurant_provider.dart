import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/restaurant_model.dart';
import '../model/restaurant_category_model.dart';
import '../model/menu_category_model.dart';
import '../model/menu_item_model.dart';
import '../model/menu_item_option_model.dart';
import '../service/restaurant_service.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

final restaurantCategoriesProvider = FutureProvider<List<RestaurantCategory>>((ref) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getRestaurantCategories();
});

final restaurantsProvider = FutureProvider.family<List<Restaurant>, RestaurantFilters>((ref, filters) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getRestaurants(
    categoryId: filters.categoryId,
    sortBy: filters.sortBy,
    ascending: filters.ascending,
    featuredOnly: filters.featuredOnly,
  );
});

final featuredRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getRestaurants(featuredOnly: true);
});

final restaurantByIdProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getRestaurantById(id);
});

final menuCategoriesProvider = FutureProvider.family<List<MenuCategory>, String>((ref, restaurantId) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getMenuCategories(restaurantId);
});

final menuItemsProvider = FutureProvider.family<List<MenuItem>, MenuItemFilters>((ref, filters) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getMenuItems(
    restaurantId: filters.restaurantId,
    categoryId: filters.categoryId,
    popularOnly: filters.popularOnly,
  );
});

final menuItemOptionsProvider = FutureProvider.family<List<MenuItemOption>, String>((ref, menuItemId) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getMenuItemOptions(menuItemId);
});

final restaurantSearchProvider = FutureProvider.family<List<Restaurant>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.watch(restaurantServiceProvider);
  return service.searchRestaurants(query);
});

final menuItemSearchProvider = FutureProvider.family<List<MenuItem>, MenuSearchParams>((ref, params) async {
  if (params.query.isEmpty) return [];
  final service = ref.watch(restaurantServiceProvider);
  return service.searchMenuItems(params.restaurantId, params.query);
});

class RestaurantFilters {
  final String? categoryId;
  final String? sortBy;
  final bool ascending;
  final bool featuredOnly;

  const RestaurantFilters({
    this.categoryId,
    this.sortBy,
    this.ascending = true,
    this.featuredOnly = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantFilters &&
        other.categoryId == categoryId &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.featuredOnly == featuredOnly;
  }

  @override
  int get hashCode {
    return Object.hash(categoryId, sortBy, ascending, featuredOnly);
  }
}

class MenuItemFilters {
  final String restaurantId;
  final String? categoryId;
  final bool popularOnly;

  const MenuItemFilters({
    required this.restaurantId,
    this.categoryId,
    this.popularOnly = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemFilters &&
        other.restaurantId == restaurantId &&
        other.categoryId == categoryId &&
        other.popularOnly == popularOnly;
  }

  @override
  int get hashCode {
    return Object.hash(restaurantId, categoryId, popularOnly);
  }
}

class MenuSearchParams {
  final String restaurantId;
  final String query;

  const MenuSearchParams({
    required this.restaurantId,
    required this.query,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuSearchParams &&
        other.restaurantId == restaurantId &&
        other.query == query;
  }

  @override
  int get hashCode {
    return Object.hash(restaurantId, query);
  }
}