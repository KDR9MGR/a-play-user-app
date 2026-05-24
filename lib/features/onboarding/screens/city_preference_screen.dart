
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/services/location_service.dart';
import 'package:a_play/features/location/screens/select_location_screen.dart';

class CityPreferenceScreen extends ConsumerWidget {
  final PageController pageController;
  const CityPreferenceScreen({super.key, required this.pageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);
    final locationLabel = locationAsync.when(
      data: (location) => location == null ? 'No location selected' : location.shortAddress,
      loading: () => 'Loading location…',
      error: (_, __) => 'No location selected',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Where are you located?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SelectLocationScreen(),
                  ),
                );
              },
              child: Text(locationLabel),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
