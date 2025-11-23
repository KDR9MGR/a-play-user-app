import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Provider for the location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Provider for the current location
final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, AsyncValue<LocationData?>>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return CurrentLocationNotifier(locationService);
});

class LocationData {
  final double latitude;
  final double longitude;
  final String city;
  final String locality;
  final String country;
  final String fullAddress;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.locality,
    required this.country,
    required this.fullAddress,
  });

  @override
  String toString() {
    return '$city, $country';
  }

  String get shortAddress => '$city, $country';
}

class CurrentLocationNotifier extends StateNotifier<AsyncValue<LocationData?>> {
  final LocationService _locationService;

  CurrentLocationNotifier(this._locationService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      // On web, just set to null initially
      state = const AsyncValue.data(null);
      return;
    }
    
    try {
      final hasPermission = await _locationService.handleLocationPermission();
      if (hasPermission) {
        final locationData = await _locationService.getCurrentLocation();
        state = AsyncValue.data(locationData);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshLocation() async {
    if (kIsWeb) {
      state = const AsyncValue.data(null);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final hasPermission = await _locationService.handleLocationPermission();
      if (hasPermission) {
        final locationData = await _locationService.getCurrentLocation();
        state = AsyncValue.data(locationData);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setManualLocation(LocationData locationData) async {
    state = AsyncValue.data(locationData);
  }
}

class LocationService {
  final _locationController = StreamController<Placemark?>.broadcast();

  Stream<Placemark?> get locationStream => _locationController.stream;

  // Check if location services are enabled and request permission
  Future<bool> handleLocationPermission() async {
    if (kIsWeb) {
      return false;
    }
    
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    // Permissions are granted
    return true;
  }

  // Get current location and address details
  Future<LocationData> getCurrentLocation() async {
    if (kIsWeb) {
      throw Exception('Location services not available on web');
    }
    
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          city: place.locality ?? place.subAdministrativeArea ?? 'Unknown',
          locality: place.subLocality ?? place.street ?? '',
          country: place.country ?? '',
          fullAddress: '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}',
        );
      } else {
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          city: 'Unknown',
          locality: '',
          country: '',
          fullAddress: 'Unknown location',
        );
      }
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  // Get address from coordinates
  Future<LocationData> getAddressFromCoordinates(double latitude, double longitude) async {
    if (kIsWeb) {
      throw Exception('Location services not available on web');
    }
    
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          city: place.locality ?? place.subAdministrativeArea ?? 'Unknown',
          locality: place.subLocality ?? place.street ?? '',
          country: place.country ?? '',
          fullAddress: '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}',
        );
      } else {
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          city: 'Unknown',
          locality: '',
          country: '',
          fullAddress: 'Unknown location',
        );
      }
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        _locationController.add(placemarks.first);
      }
    } catch (e) {
      _locationController.addError(e);
    }
  }

  void dispose() {
    _locationController.close();
  }
} 