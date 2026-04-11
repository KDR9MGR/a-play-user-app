import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterDelegate extends SliverPersistentHeaderDelegate {
  final WidgetRef ref;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  FilterDelegate({
    required this.ref,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _buildFilterButton(context, 'today', 'Today'),
          const SizedBox(width: 8),
          _buildFilterButton(context, 'tomorrow', 'Tomorrow'),
          const SizedBox(width: 8),
          _buildFilterButton(context, 'this_week', 'This Week'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String filter, String label) {
    final isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.lightImpact();
          onFilterChanged(filter);
        }
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white.withAlpha(230),
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.white : Colors.white.withAlpha(100),
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      elevation: 0,
      pressElevation: 0,
      showCheckmark: false,
    );
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is FilterDelegate && 
           (oldDelegate.selectedFilter != selectedFilter);
  }
} 