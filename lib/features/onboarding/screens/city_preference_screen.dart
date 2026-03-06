
import 'package:a_play/features/onboarding/controllers/onboarding_controller.dart';
import 'package:a_play/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CityPreferenceScreen extends ConsumerWidget {
  final PageController pageController;
  const CityPreferenceScreen({super.key, required this.pageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Where are you located?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/location'),
              child: const Text('Select Location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                profile.whenData((profileData) {
                  ref.read(onboardingControllerProvider.notifier).updateProfile(
                        ref.read(onboardingControllerProvider).copyWith(
                              city: profileData.city,
                            ),
                      );
                });
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
