import 'package:flutter/material.dart';
import 'package:a_play/features/home/model/home_even_model.dart';
import 'package:a_play/features/home/widgets/event_card.dart';

class FeaturedEventsSection extends StatelessWidget {
  final List<HomeEventModel> events;

  const FeaturedEventsSection({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: EventCard(
                event: event,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/event/${event.id}',
                    arguments: event,
                  );
                },
              ),
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }
} 