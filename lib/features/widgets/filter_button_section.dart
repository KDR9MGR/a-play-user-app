import 'package:flutter/material.dart';

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: List.generate(
            filterOptions.length,
            (index) => _buildFilterButton(
              filterOptions[index],
              index == selectedIndex,
              () => onFilterSelected(index),
              context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.grey,
          backgroundColor: isSelected ? Colors.black87 : Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? Colors.white24 : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
