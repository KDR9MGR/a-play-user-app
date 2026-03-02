import 'package:flutter/material.dart';
import '../model/category.dart';

class AnimatedFilterChips extends StatelessWidget {
  final List<Category> categories;
  final bool showChips;

  const AnimatedFilterChips({
    super.key,
    required this.categories,
    required this.showChips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: showChips ? 1.0 : 0.0,
        child: Row(
          children: [
            _buildFilterChip('TV Shows', isSelected: true),
            const SizedBox(width: 12),
            _buildFilterChip('Movies', isSelected: false),
            const SizedBox(width: 12),
            _buildFilterChip('Categories', isSelected: false, hasDropdown: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, bool hasDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isSelected ? Colors.black : Colors.white,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }
} 