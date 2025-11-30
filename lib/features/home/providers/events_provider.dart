import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/home/service/home_service.dart';

// Provider for HomeService
final homeServiceProvider = Provider((ref) => HomeService());

final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase
    .from('events')
    .stream(primaryKey: ['id'])
    .order('start_date')
    .map((data) => data.map((json) => EventModel.fromJson(json)).toList());
});

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final homeService = ref.read(homeServiceProvider);
  return homeService.getHomeEvents();
}); 