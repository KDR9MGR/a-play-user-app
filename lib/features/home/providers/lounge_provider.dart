import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/lounge_model.dart';
import 'package:a_play/features/home/service/lounge_service.dart';

final loungeServiceProvider = Provider<LoungeService>((ref) {
  return LoungeService();
});

final loungesProvider = FutureProvider.family<List<Lounge>, ({String? sortBy, bool ascending})>((ref, params) async {
  final loungeService = ref.watch(loungeServiceProvider);
  return loungeService.getLounges(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

final featuredLoungesProvider = FutureProvider<List<Lounge>>((ref) async {
  final loungeService = ref.watch(loungeServiceProvider);
  return loungeService.getFeaturedLounges();
});

final popularLoungesProvider = FutureProvider<List<Lounge>>((ref) async {
  final loungeService = ref.watch(loungeServiceProvider);
  return loungeService.getPopularLounges();
});

final loungeProvider = FutureProvider.family<Lounge?, String>((ref, id) async {
  final loungeService = ref.watch(loungeServiceProvider);
  return loungeService.getLoungeById(id);
});