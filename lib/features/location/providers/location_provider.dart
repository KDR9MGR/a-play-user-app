import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/location_model.dart';
import '../services/location_service.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<LocationModel?>>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationNotifier(locationService);
});

class LocationNotifier extends StateNotifier<AsyncValue<LocationModel?>> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const AsyncValue.loading()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    state = const AsyncValue.loading();
    try {
      // First try to get saved location
      LocationModel? savedLocation = await _locationService.getSavedLocation();
      if (savedLocation != null) {
        state = AsyncValue.data(savedLocation);
        return;
      }

      // If no saved location, try to get current location
      LocationModel? currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation != null) {
        await _locationService.saveLocation(currentLocation);
        state = AsyncValue.data(currentLocation);
        return;
      }

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateLocation() async {
    state = const AsyncValue.loading();
    try {
      LocationModel? currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation != null) {
        await _locationService.saveLocation(currentLocation);
        state = AsyncValue.data(currentLocation);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearLocation() async {
    state = const AsyncValue.loading();
    try {
      await _locationService.clearSavedLocation();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 