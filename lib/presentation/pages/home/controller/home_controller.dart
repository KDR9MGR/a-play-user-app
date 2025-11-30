import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/domain/entities/event.dart';
import 'package:a_play/domain/repositories/event_repository.dart';

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

final filteredEventsProvider = Provider<List<Event>>((ref) {
  final eventsAsyncValue = ref.watch(eventsProvider);
  final selectedFilter = ref.watch(selectedFilterProvider);

  return eventsAsyncValue.when(
    data: (events) {
      switch (selectedFilter) {
        case 'Today':
          final now = DateTime.now();
          return events.where((event) {
            return event.date.year == now.year &&
                event.date.month == now.month &&
                event.date.day == now.day;
          }).toList();
        case 'Tomorrow':
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          return events.where((event) {
            return event.date.year == tomorrow.year &&
                event.date.month == tomorrow.month &&
                event.date.day == tomorrow.day;
          }).toList();
        case 'This Weekend':
          final now = DateTime.now();
          final saturday = now.add(Duration(days: (6 - now.weekday)));
          final sunday = saturday.add(const Duration(days: 1));
          return events.where((event) {
            return event.date.isAfter(saturday.subtract(const Duration(days: 1))) &&
                event.date.isBefore(sunday.add(const Duration(days: 1)));
          }).toList();
        case 'Under 10 Km':
          // TODO: Implement location-based filtering
          return events;
        default:
          return events;
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final selectedFilterProvider = StateProvider<String>((ref) => 'Today');