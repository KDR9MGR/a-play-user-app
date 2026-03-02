import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/beach_model.dart';
import 'package:a_play/features/home/service/beach_service.dart';

final beachServiceProvider = Provider<BeachService>((ref) {
  return BeachService();
});

final beachesProvider = FutureProvider.family<List<Beach>, ({String? sortBy, bool ascending})>((ref, params) async {
  final beachService = ref.watch(beachServiceProvider);
  return beachService.getBeaches(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

final featuredBeachesProvider = FutureProvider<List<Beach>>((ref) async {
  final beachService = ref.watch(beachServiceProvider);
  return beachService.getFeaturedBeaches();
});

final popularBeachesProvider = FutureProvider<List<Beach>>((ref) async {
  final beachService = ref.watch(beachServiceProvider);
  return beachService.getPopularBeaches();
});

final waterSportsBeachesProvider = FutureProvider<List<Beach>>((ref) async {
  final beachService = ref.watch(beachServiceProvider);
  return beachService.getWaterSportsBeaches();
});

final beachProvider = FutureProvider.family<Beach?, String>((ref, id) async {
  final beachService = ref.watch(beachServiceProvider);
  return beachService.getBeachById(id);
});