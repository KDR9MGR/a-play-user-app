import 'package:a_play/features/search/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/widgets/search_bar_section.dart';

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final WidgetRef ref;
  final Key? key;

  const SearchBarDelegate({required this.ref, this.key});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = shrinkOffset / maxExtent;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Material(
        color: const Color(0xFF121212),
        elevation: overlapsContent ? 4 : 0,
        child: Container(
          key: key,
          height: 80,
          padding: EdgeInsets.lerp(
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            progress,
          ),
          child: const SearchBarSection(),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is SearchBarDelegate && oldDelegate.ref != ref;
  }
}