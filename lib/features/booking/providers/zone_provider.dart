import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/booking/service/zone_service.dart';

final zoneServiceProvider = Provider<ZoneService>((ref) {
  return ZoneService();
});

// Provider for zones with availability
final eventZonesProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String eventId, DateTime date})>((ref, params) async {
  final zoneService = ref.watch(zoneServiceProvider);
  return zoneService.getEventZonesWithAvailability(params.eventId, params.date);
});

final bookedSeatsProvider = FutureProvider.family<int, String>((ref, zoneId) async {
  final zoneService = ref.watch(zoneServiceProvider);
  return zoneService.getBookedSeatsCount(zoneId);
}); 