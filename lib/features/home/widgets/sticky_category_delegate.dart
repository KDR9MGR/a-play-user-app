import 'package:flutter/material.dart';
import 'category_selector.dart';

class StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  StickyCategoryDelegate({
    this.minHeight = 65.0,
    this.maxHeight = 65.0,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212), // Match home screen background
      child: const CategorySelector(),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Rebuild when categories change
  }
} 