import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class PermissionHandler {
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services'),
      ));
      return false;
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Location permissions are denied'),
        ));
        return false;
      }
    }

    // Handle permanently denied permissions
    if (permission == LocationPermission.deniedForever) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied, we cannot request permissions.'),
      ));
      return false;
    }

    return true;
  }
} 