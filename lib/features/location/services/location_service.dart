import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/location_model.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(SharedPreferences.getInstance());
});

class LocationService {
  static const String _locationKey = 'user_location';
  final Future<SharedPreferences> _prefs;

  LocationService(this._prefs);

  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  Future<LocationModel?> getCurrentLocation() async {
    try {
      if (!await hasLocationPermission()) {
        bool granted = await requestLocationPermission();
        if (!granted) return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          address: place.street,
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
          postalCode: place.postalCode,
        );
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_locationKey, location.toJson().toString());
  }

  Future<LocationModel?> getSavedLocation() async {
    final prefs = await _prefs;
    final locationStr = prefs.getString(_locationKey);
    if (locationStr != null) {
      try {
        return LocationModel.fromJson(
          Map<String, dynamic>.from(
            // ignore: unnecessary_cast
            (locationStr as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearSavedLocation() async {
    final prefs = await _prefs;
    await prefs.remove(_locationKey);
  }
} 