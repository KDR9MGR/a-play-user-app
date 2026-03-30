import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../model/youtube_content.dart';

class FeaturedContent extends StatefulWidget {
  final List<YoutubeContent> featuredContent;
  final Function(YoutubeContent) onPlayVideo;
  final Function(YoutubeContent) onAddToWatchlist;

  const FeaturedContent({
    super.key,
    required this.featuredContent,
    required this.onPlayVideo,
    required this.onAddToWatchlist,
  });

  @override
  State<FeaturedContent> createState() => _FeaturedContentState();
}

class _FeaturedContentState extends State<FeaturedContent> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<YoutubeContent> _items;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _items = widget.featuredContent.isEmpty ? [] : widget.featuredContent;
    _pageController = PageController(viewportFraction: 0.9);
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _items.length <= 1) return;
      _currentPage = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.52,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // PageView with Netflix-style card
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final featured = _items[index];
              final scale = 1 - (index - _currentPage).abs() * 0.08;
              final opacity = 1 - (index - _currentPage).abs() * 0.4;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()..scale(scale),
                child: Opacity(opacity: opacity, child: _NetflixCard(featured)),
              );
            },
          ),

          // Dots indicator
          Positioned(
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _NetflixCard(YoutubeContent item) {
    return GestureDetector(
      onTap: () => widget.onPlayVideo(item),
      child: Hero(
        tag: 'featured_${item.id}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: item.coverImage ?? item.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[900]),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.5, 1],
                      ),
                    ),
                  ),
                ),

                // Meta & buttons
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with drop-shadow for readability
                      Text(
                        item.title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.9),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Subtitle row
                      if (item.category != null || item.year != null)
                        Text(
                          [
                            item.category,
                            item.year?.toString(),
                            item.maturityRating,
                          ].where((e) => e != null).join(' • '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      // Buttons row
                      Row(
                        children: [
                          _PlayButton(onTap: () => widget.onPlayVideo(item)),
                          const SizedBox(width: 8),
                          _MyListButton(onTap: () => widget.onAddToWatchlist(item)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
      label: const Text('Play', style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _MyListButton extends StatelessWidget {
  const _MyListButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, color: Colors.white, size: 20),
      label: const Text('My List', style: TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
