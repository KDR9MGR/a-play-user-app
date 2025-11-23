import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:a_play/features/home/service/club_service.dart';

final clubServiceProvider = Provider<ClubService>((ref) {
  return ClubService();
});

final clubsProvider = FutureProvider.family<List<Club>, ({String? sortBy, bool ascending})>((ref, params) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getClubs(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

// Popular clubs - most recently created
final popularClubsProvider = FutureProvider<List<Club>>((ref) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getPopularClubs();
});

// Featured clubs - first 8 clubs
final featuredClubsProvider = FutureProvider<List<Club>>((ref) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getFeaturedClubs();
});

// Top rated clubs - sorted by name (as proxy for rating)
final topRatedClubsProvider = FutureProvider<List<Club>>((ref) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getTopRatedClubs();
});

// New clubs - most recently created
final newClubsProvider = FutureProvider<List<Club>>((ref) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getNewClubs();
});

final clubProvider = FutureProvider.family<Club?, String>((ref, id) async {
  final clubService = ref.watch(clubServiceProvider);
  return clubService.getClubById(id);
}); 