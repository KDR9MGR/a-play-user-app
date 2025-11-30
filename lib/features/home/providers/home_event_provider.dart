import 'package:a_play/data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/service/home_service.dart';



final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService();
});

final homeEventProvider = FutureProvider<List<EventModel>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return homeService.getHomeEvents();
});

final featuredEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return homeService.getFeaturedEvents();
});

final whatsHotTonightEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  return homeService.getWhatsHotTonightEvents();
});

final upcomingEventsProvider = FutureProvider<List<dynamic>>((ref) async {
  final homeService = ref.watch(homeServiceProvider);
  // Convert EventModel to Map<String, dynamic> for backward compatibility
  final events = await homeService.getHomeEvents();
  return events.map((event) => {
    'id': event.id,
    'title': event.title,
    'start_date': event.startDate.toIso8601String(),
    'location': event.location,
    'cover_image': event.coverImage,
    'price': event.price,
  }).toList();
});