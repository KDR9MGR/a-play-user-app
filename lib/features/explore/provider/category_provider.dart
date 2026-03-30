import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/category_model.dart';
import '../service/event_supabase_service.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoriesNotifier(ref.watch(categoryProvider));
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final EventSupabaseService _service;

  CategoriesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _service.getCategories();
      state = AsyncValue.data([CategoryModel(name: 'All'), ...categories]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 