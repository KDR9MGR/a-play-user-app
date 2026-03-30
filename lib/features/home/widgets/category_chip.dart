import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const CategoryChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? (borderColor ?? Colors.white)
                : Colors.grey[600]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? (backgroundColor ?? Colors.transparent)
              : Colors.transparent,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected 
                ? (textColor ?? Colors.white)
                : Colors.grey[400],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            height: 1.2, // Line height for better spacing
          ),
        ),
      ),
    );
  }
} 