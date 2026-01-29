import 'dart:async';

import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/booking/screens/event_details_screen.dart';
import 'package:a_play/features/widgets/section_title.dart';
import 'package:a_play/features/widgets/squircle_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventCarousel2 extends StatefulWidget {
  final List<EventModel> events;

  const EventCarousel2({
    super.key,
    required this.events,
  });

  @override
  State<EventCarousel2> createState() => _EventCarousel2State();
}

class _EventCarousel2State extends State<EventCarousel2>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75, // Show more of adjacent items
      initialPage: _currentPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_isAutoScrolling) return;

      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.events.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onEventTapped(BuildContext context, EventModel event) {
    _isAutoScrolling = false;
    _autoScrollTimer?.cancel();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    ).then((_) {
      if (mounted) {
        _isAutoScrolling = true;
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.events.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No events available',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SectionTitle(title: "Featured Events"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                final event = widget.events[index];
                return GestureDetector(
                  onTap: () => _onEventTapped(context, event),
                  onPanDown: (_) {
                    _isAutoScrolling = false;
                    _autoScrollTimer?.cancel();
                  },
                  onPanCancel: () {
                    _isAutoScrolling = true;
                    _startAutoScroll();
                  },
                  onPanEnd: (_) {
                    _isAutoScrolling = true;
                    _startAutoScroll();
                  },
                  child: AnimatedScale(
                    scale: index == _currentPage ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'event_image_${event.id}',
                              child: SquircleContainer(
                                radius: 45,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey.withValues(alpha: 0.2)),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: event.coverImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(Icons.error_outline,
                                            color: Colors.white54, size: 48),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            event.title,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.location,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.events.length > 1) ...[
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.events.length,
            effect: const ScrollingDotsEffect(
              dotHeight: 8,
              dotWidth: 16,
              spacing: 8,
              dotColor: Color.fromARGB(255, 29, 28, 28),
              activeDotColor: Colors.white,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
