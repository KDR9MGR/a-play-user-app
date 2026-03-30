import 'package:a_play/features/explore/model/service_event_model.dart';
import 'package:a_play/features/explore/service/event_supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_provider.dart';

final eventServiceProvider = Provider<EventSupabaseService>((ref) {
  return EventSupabaseService();
});

// Create a provider that combines the service and selected category
final eventListProvider = AsyncNotifierProvider<EventListNotifier, List<ServiceEventModel>>(
  EventListNotifier.new
);

class EventListNotifier extends AsyncNotifier<List<ServiceEventModel>> {
  @override
  Future<List<ServiceEventModel>> build() async {
    // Get the initial category
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    // Get the service instance
    final service = ref.watch(eventServiceProvider);
    
    // Load initial events
    return service.getEventsByCategory(selectedCategory);
  }

  Future<void> loadEvents() async {
    try {
      state = const AsyncValue.loading();
      
      // Get the current category and service
      final selectedCategory = ref.read(selectedCategoryProvider);
      final service = ref.read(eventServiceProvider);
      
      // Fetch events for the current category
      final events = await service.getEventsByCategory(selectedCategory);
      
      // Only update state if the notifier hasn't been disposed
      state = AsyncValue.data(events);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshEvents() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final selectedCategory = ref.read(selectedCategoryProvider);
      final service = ref.read(eventServiceProvider);
      return service.getEventsByCategory(selectedCategory);
    });
  }
}
