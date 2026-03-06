
import 'package:a_play/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  final PageController pageController;
  const InterestsScreen({super.key, required this.pageController});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final List<String> _interests = [
    'Clubs',
    'Restaurants',
    'Live Events',
    'Beaches',
    'Arcades',
  ];

  final List<String> _selectedInterests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What are your interests?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 10.0,
              children: _interests.map((interest) {
                return FilterChip(
                  label: Text(interest),
                  selected: _selectedInterests.contains(interest),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(onboardingControllerProvider.notifier).updateProfile(
                      ref.read(onboardingControllerProvider).copyWith(
                            interests: _selectedInterests,
                          ),
                    );
                ref.read(onboardingControllerProvider.notifier).saveProfile();
                context.go('/home');
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
