import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/arcade_center_model.dart';
import 'package:a_play/features/home/service/arcade_center_service.dart';

final arcadeCenterServiceProvider = Provider<ArcadeCenterService>((ref) {
  return ArcadeCenterService();
});

final arcadeCentersProvider = FutureProvider.family<List<ArcadeCenter>, ({String? sortBy, bool ascending})>((ref, params) async {
  final arcadeCenterService = ref.watch(arcadeCenterServiceProvider);
  return arcadeCenterService.getArcadeCenters(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

final featuredArcadeCentersProvider = FutureProvider<List<ArcadeCenter>>((ref) async {
  final arcadeCenterService = ref.watch(arcadeCenterServiceProvider);
  return arcadeCenterService.getFeaturedArcadeCenters();
});

final popularArcadeCentersProvider = FutureProvider<List<ArcadeCenter>>((ref) async {
  final arcadeCenterService = ref.watch(arcadeCenterServiceProvider);
  return arcadeCenterService.getPopularArcadeCenters();
});

final vrArcadeCentersProvider = FutureProvider<List<ArcadeCenter>>((ref) async {
  final arcadeCenterService = ref.watch(arcadeCenterServiceProvider);
  return arcadeCenterService.getVrArcadeCenters();
});

final arcadeCenterProvider = FutureProvider.family<ArcadeCenter?, String>((ref, id) async {
  final arcadeCenterService = ref.watch(arcadeCenterServiceProvider);
  return arcadeCenterService.getArcadeCenterById(id);
});