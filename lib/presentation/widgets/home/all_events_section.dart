import 'package:flutter/material.dart';
import 'package:a_play/core/constants/colors.dart';
import 'package:a_play/domain/entities/event.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllEventsSection extends StatelessWidget {
  final List<Event> events;

  const AllEventsSection({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = events[index];
            return _EventCard(
              event: event,
              index: index,
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final int index;

  const _EventCard({
    required this.event,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = event.isExpired;
    return ColorFiltered(
      colorFilter: isExpired
          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              AspectRatio(
                aspectRatio: 1.5,
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Event Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white54,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.formattedDate,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white54,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? Colors.grey.withValues(alpha: 0.2)
                                : AppColors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpired ? 'Expired' : 'Book Now',
                            style: TextStyle(
                              color: isExpired ? Colors.grey : AppColors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: 100 * index),
    );
  }
} 