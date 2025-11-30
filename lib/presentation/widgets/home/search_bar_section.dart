import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/constants/colors.dart';

final searchQueryProvider = StateProvider.family<String, String>((ref, providerId) => '');

class SearchBarSection extends ConsumerStatefulWidget {
  final String providerId;
  final String hintText;
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  final bool autofocus;
  final TextEditingController? controller;

  const SearchBarSection({
    super.key,
    required this.providerId,
    this.hintText = 'Search...',
    this.onChanged,
    this.padding,
    this.autofocus = false,
    this.controller,
  });

  @override
  ConsumerState<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends ConsumerState<SearchBarSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text;
    ref.read(searchQueryProvider(widget.providerId).notifier).state = query;
    widget.onChanged?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.5)),
            prefixIcon: Icon(Icons.search, color: AppColors.onSurface.withValues(alpha: 0.7)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          cursorColor: AppColors.primary,
        ),
      ),
    );
  }
} 