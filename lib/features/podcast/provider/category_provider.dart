import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/category.dart';
import '../service/category_service.dart';

/// Provider for CategoryService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

/// Provider for fetching all active categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(categoryServiceProvider);
  return service.getActiveCategories();
});

/// Provider for the currently selected category
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

/// Provider for category by name
final categoryByNameProvider = FutureProvider.family<Category?, String>((ref, name) async {
  final service = ref.read(categoryServiceProvider);
  return service.getCategoryByName(name);
});

/// Provider for category by ID
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, id) async {
  final service = ref.read(categoryServiceProvider);
  return service.getCategoryById(id);
}); 