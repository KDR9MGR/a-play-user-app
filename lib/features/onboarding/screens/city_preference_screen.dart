
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CityPreferenceScreen extends StatelessWidget {
  final PageController pageController;
  const CityPreferenceScreen({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where are you located?'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/location'),
          child: const Text('Select Location'),
        ),
      ),
    );
  }
}
