import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: () {
        onFilterChanged(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[600]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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