import 'package:flutter/material.dart';
import 'package:a_play/core/constants/colors.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        'Premium',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
