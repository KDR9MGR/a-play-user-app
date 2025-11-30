import 'package:flutter/material.dart';
import 'package:a_play/core/constants/colors.dart';

class HomeAppBarSection extends StatelessWidget {
  const HomeAppBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo or App Name
          const Text(
            'A Play',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Profile Icon
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              onPressed: () {
                // Navigate to profile
              },
            ),
          ),
        ],
      ),
    );
  }
} 