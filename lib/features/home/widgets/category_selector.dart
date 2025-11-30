import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_category_provider.dart';
import 'category_chip.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(eventCategoriesProvider);
    final selectedCategory = ref.watch(selectedEventCategoryProvider);

    return categoriesAsync.when(
      loading: () => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (error, stackTrace) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Failed to load categories',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ),
      ),
      data: (categories) => Container(
        height: 65,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category.name;
            
            return CategoryChip(
              title: category.displayName,
              isSelected: isSelected,
              backgroundColor: category.color != null 
                  ? Colors.black
                  : null,
              onTap: () {
                ref.read(selectedEventCategoryProvider.notifier).state = category.name;
              },
            );
          },
        ),
      ),
    );
  }
} 