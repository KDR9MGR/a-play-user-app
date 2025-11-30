import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/pub_model.dart';
import 'package:a_play/features/home/service/pub_service.dart';

final pubServiceProvider = Provider<PubService>((ref) {
  return PubService();
});

final pubsProvider = FutureProvider.family<List<Pub>, ({String? sortBy, bool ascending})>((ref, params) async {
  final pubService = ref.watch(pubServiceProvider);
  return pubService.getPubs(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

final featuredPubsProvider = FutureProvider<List<Pub>>((ref) async {
  final pubService = ref.watch(pubServiceProvider);
  return pubService.getFeaturedPubs();
});

final popularPubsProvider = FutureProvider<List<Pub>>((ref) async {
  final pubService = ref.watch(pubServiceProvider);
  return pubService.getPopularPubs();
});

final sportsViewingPubsProvider = FutureProvider<List<Pub>>((ref) async {
  final pubService = ref.watch(pubServiceProvider);
  return pubService.getSportsViewingPubs();
});

final pubProvider = FutureProvider.family<Pub?, String>((ref, id) async {
  final pubService = ref.watch(pubServiceProvider);
  return pubService.getPubById(id);
});