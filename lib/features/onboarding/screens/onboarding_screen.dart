
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simplified onboarding screen - skip unnecessary fields
/// Users can complete their profile later from settings
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Icon
              const Icon(
                Icons.celebration,
                size: 120,
                color: Colors.orange,
              ),
              const SizedBox(height: 40),

              // Welcome Title
              Text(
                'Welcome to A-Play!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Your account has been created successfully.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start exploring events, clubs, and entertainment in Ghana!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Get Started Button
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Optional: Complete profile later
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Complete profile later',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
