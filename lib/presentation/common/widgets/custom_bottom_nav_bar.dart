import 'package:flutter/material.dart';
import 'package:a_play/core/constants/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onHomeTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.explore_outlined,
                      label: 'Explore',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavBarItem(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Bookings',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ],
                ),
              ),
              // Center space for FAB
              const SizedBox(width: 80),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.diamond_outlined,
                      label: 'Concierge',
                      isSelected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _NavBarItem(
                      icon: Icons.rss_feed_outlined,
                      label: 'Feeds',
                      isSelected: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Floating Home Button
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: onHomeTap,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        // Notch
        Positioned(
          top: 0,
          child: Container(
            width: 70,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.orange : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.orange : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 