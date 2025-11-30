import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/live_show_model.dart';
import 'package:a_play/features/home/service/live_show_service.dart';

final liveShowServiceProvider = Provider<LiveShowService>((ref) {
  return LiveShowService();
});

final liveShowsProvider = FutureProvider.family<List<LiveShow>, ({String? sortBy, bool ascending})>((ref, params) async {
  final liveShowService = ref.watch(liveShowServiceProvider);
  return liveShowService.getLiveShows(
    sortBy: params.sortBy,
    ascending: params.ascending,
  );
});

final featuredLiveShowsProvider = FutureProvider<List<LiveShow>>((ref) async {
  final liveShowService = ref.watch(liveShowServiceProvider);
  return liveShowService.getFeaturedLiveShows();
});

final upcomingLiveShowsProvider = FutureProvider<List<LiveShow>>((ref) async {
  final liveShowService = ref.watch(liveShowServiceProvider);
  return liveShowService.getUpcomingLiveShows();
});

final liveShowsByTypeProvider = FutureProvider.family<List<LiveShow>, String>((ref, showType) async {
  final liveShowService = ref.watch(liveShowServiceProvider);
  return liveShowService.getLiveShowsByType(showType);
});

final liveShowProvider = FutureProvider.family<LiveShow?, String>((ref, id) async {
  final liveShowService = ref.watch(liveShowServiceProvider);
  return liveShowService.getLiveShowById(id);
});