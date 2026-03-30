
import 'package:flutter/material.dart';
import 'package:a_play/features/onboarding/screens/interests_screen.dart';
import 'package:a_play/features/onboarding/screens/phone_screen.dart';
import 'package:a_play/features/onboarding/screens/dob_screen.dart';
import 'package:a_play/features/onboarding/screens/city_preference_screen.dart';
import 'package:a_play/features/onboarding/screens/profile_photo_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          ProfilePhotoScreen(pageController: _pageController),
          PhoneScreen(pageController: _pageController),
          DateOfBirthScreen(pageController: _pageController),
          CityPreferenceScreen(pageController: _pageController),
          InterestsScreen(pageController: _pageController),
        ],
      ),
    );
  }
}
