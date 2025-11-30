import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

final selectedLocationProvider = StateNotifierProvider<SelectedLocationNotifier, Placemark?>((ref) {
  return SelectedLocationNotifier();
});

class SelectedLocationNotifier extends StateNotifier<Placemark?> {
  SelectedLocationNotifier() : super(null);

  void setLocation(Placemark location) {
    state = location;
  }

  void clearLocation() {
    state = null;
  }
} 