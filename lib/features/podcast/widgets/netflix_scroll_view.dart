import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../model/youtube_content.dart';
import '../model/category.dart';
import 'animated_filter_chips.dart';
import 'featured_content_section.dart';
import 'content_sections.dart';

class NetflixScrollView extends ConsumerStatefulWidget {
  final List<YoutubeContent> content;
  final List<Category> categories;

  const NetflixScrollView({
    super.key,
    required this.content,
    required this.categories,
  });

  @override
  ConsumerState<NetflixScrollView> createState() => _NetflixScrollViewState();
}

class _NetflixScrollViewState extends ConsumerState<NetflixScrollView> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;
  bool _showChips = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final delta = (currentOffset - _lastScrollOffset).abs();
    
    // Only update if there's significant scroll movement
    if (delta > 5) {
      setState(() {
        _scrollOffset = currentOffset;
        if (isScrollingDown != _isScrollingDown) {
          _isScrollingDown = isScrollingDown;
          // Show chips when scrolling up, hide when scrolling down
          _showChips = !isScrollingDown || currentOffset < 100;
        }
        _lastScrollOffset = currentOffset;
      });
    }
  }

  bool get _showBlur {
    return _scrollOffset > 30.0; // Start blur effect earlier
  }

  double get _gradientOpacity {
    const double fadeStart = 0.0;
    const double fadeEnd = 300.0;
    
    if (_scrollOffset <= fadeStart) return 1.0;
    if (_scrollOffset >= fadeEnd) return 0.0;
    
    return 1.0 - ((_scrollOffset - fadeStart) / (fadeEnd - fadeStart));
  }

  @override
  Widget build(BuildContext context) {
    final featuredContent = widget.content.isNotEmpty ? widget.content.first : null;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Netflix-style SliverAppBar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            pinned: true,
            snap: false,
            expandedHeight: 0,
            collapsedHeight: 80,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _showBlur ? 25.0 : 0.0,
                  sigmaY: _showBlur ? 25.0 : 0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: _showBlur ? 0.3 : 0.0),
                    border: _showBlur ? Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ) : null,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // User greeting
                          Text(
                            'For Saurabh Saini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              shadows: !_showBlur ? [
                                const Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black54,
                                ),
                              ] : null,
                            ),
                          ),
                          // Action icons
                          Row(
                            children: [
                              _buildActionIcon(Icons.cast),
                              const SizedBox(width: 16),
                              _buildActionIcon(Icons.download),
                              const SizedBox(width: 16),
                              _buildActionIcon(Icons.search),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Persistent header with filter chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverFilterChipsDelegate(
              categories: widget.categories,
              showChips: _showChips,
              showBlur: _showBlur,
            ),
          ),
          // Featured content
          if (featuredContent != null)
            SliverToBoxAdapter(
              child: FeaturedContentSection(
                content: featuredContent,
              ),
            ),
          // Content sections
          SliverToBoxAdapter(
            child: ContentSections(
              content: widget.content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: !_showBlur 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
        shadows: !_showBlur ? [
          const Shadow(
            offset: Offset(0, 1),
            blurRadius: 3,
            color: Colors.black54,
          ),
        ] : null,
      ),
    );
  }
}

class _SliverFilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final List<Category> categories;
  final bool showChips;
  final bool showBlur;

  _SliverFilterChipsDelegate({
    required this.categories,
    required this.showChips,
    required this.showBlur,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: showBlur ? 25.0 : 0.0,
          sigmaY: showBlur ? 25.0 : 0.0,
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: showBlur ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
            border: showBlur ? const Border(
              bottom: BorderSide(
                color: Colors.white12,
                width: 0.5,
              ),
            ) : null,
          ),
          child: AnimatedFilterChips(
            categories: categories,
            showChips: showChips,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is _SliverFilterChipsDelegate && 
           (oldDelegate.showChips != showChips || 
            oldDelegate.categories != categories ||
            oldDelegate.showBlur != showBlur);
  }
} 