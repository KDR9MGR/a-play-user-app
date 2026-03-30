import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/podcast_categories.dart';
import '../provider/category_provider.dart';

class PodcastTabBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int, String) onTabSelected;

  const PodcastTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: categoriesAsync.when(
        data: (categories) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTab('All Content', 0, 'all'),
              const SizedBox(width: 8),
              ...PodcastCategories.mainCategories.take(8).map((category) {
                final index = PodcastCategories.mainCategories.indexOf(category) + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildTab(category.name, index, category.id),
                );
              }),
            ],
          ),
        ),
        loading: () => Row(
          children: [
            _buildTab('All Content', 0, 'all'),
            const SizedBox(width: 8),
            _buildTab('Loading...', 1, 'loading'),
          ],
        ),
        error: (error, stack) => Row(
          children: [
            _buildTab('All Content', 0, 'all'),
            const SizedBox(width: 20),
            _buildTab('Categories', 1, 'error'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index, String categoryId) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index, categoryId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected ? Border.all(color: Colors.white24) : Border.all(color: Colors.white24),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
