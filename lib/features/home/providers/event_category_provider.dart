import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_category.dart';
import '../services/event_category_service.dart';

// Service provider
final eventCategoryServiceProvider = Provider<EventCategoryService>((ref) {
  return EventCategoryService();
});

// Provider to get all event categories
final eventCategoriesProvider = FutureProvider<List<EventCategory>>((ref) async {
  final service = ref.read(eventCategoryServiceProvider);
  return service.getEventCategories();
});

// Selected category state provider
final selectedEventCategoryProvider = StateProvider<String>((ref) => 'all_events');

// Provider to get events by selected category
final eventsByCategoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(eventCategoryServiceProvider);
  final selectedCategory = ref.watch(selectedEventCategoryProvider);
  
  // Get the category details to determine the actual ID to use
  final categories = await ref.watch(eventCategoriesProvider.future);
  
  // Find the selected category
  final category = categories.firstWhere(
    (cat) => cat.name == selectedCategory,
    orElse: () => categories.first, // Default to first category
  );
  
  return service.getEventsByCategory(category.id);
});

// Provider to get specific category by name
final categoryByNameProvider = FutureProvider.family<EventCategory?, String>((ref, name) async {
  final service = ref.read(eventCategoryServiceProvider);
  return service.getCategoryByName(name);
});

// Provider to get currently selected category details
final selectedCategoryDetailsProvider = FutureProvider<EventCategory?>((ref) async {
  final selectedCategoryName = ref.watch(selectedEventCategoryProvider);
  final categories = await ref.watch(eventCategoriesProvider.future);
  
  try {
    return categories.firstWhere((cat) => cat.name == selectedCategoryName);
  } catch (e) {
    return categories.isNotEmpty ? categories.first : null;
  }
}); 