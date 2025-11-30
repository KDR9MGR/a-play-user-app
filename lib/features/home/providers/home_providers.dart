import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/services/location_service.dart';
import 'package:a_play/features/home/state/home_state.dart';

final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return HomeStateNotifier(locationService);
}); 