import 'package:flutter/material.dart';
import 'package:a_play/core/constants/colors.dart';

class FilterButtonsSection extends StatelessWidget {
  final List<String> filterOptions;
  final int selectedIndex;
  final Function(int) onFilterSelected;

  const FilterButtonsSection({
    super.key,
    required this.filterOptions,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onFilterSelected(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filterOptions[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 