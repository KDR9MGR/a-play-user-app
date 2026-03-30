import 'package:a_play/features/widgets/squircle_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/section_title.dart';
import '../providers/home_event_provider.dart';

class FilteredEventsSection extends ConsumerStatefulWidget {
  final String selectedTimeFilter;
  
  const FilteredEventsSection({
    super.key,
    required this.selectedTimeFilter,
  });

  @override
  ConsumerState<FilteredEventsSection> createState() => _FilteredEventsSectionState();
}

class _FilteredEventsSectionState extends ConsumerState<FilteredEventsSection> {
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 8),
          child: SectionTitle(
            title: 'Upcoming Events',
          ),
        ),
        
        // Events Grid/List
        eventsAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stackTrace) => Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load events',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          data: (events) {
            final filteredEvents = _filterEventsByTime(events);
            final eventsToShow = filteredEvents.isEmpty ? _sortEventsByStartDate(events) : filteredEvents;

            if (eventsToShow.isEmpty) {
              return Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, color: Colors.grey[600], size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'No events found',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try selecting a different time filter',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Display events in a responsive grid (iPad Air fix)
            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth > 900 ? 6 : (screenWidth > 600 ? 5 : 3);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0, // Square aspect ratio for perfect circles
                ),
                itemCount: eventsToShow.length > 6 ? 6 : eventsToShow.length,
                itemBuilder: (context, index) {
                  final event = eventsToShow[index];
                  return _buildEventCard(event);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  List<dynamic> _filterEventsByTime(List<dynamic> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return events.where((event) {
      try {
        final eventDate = DateTime.parse(event['start_date']);
        final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

        switch (widget.selectedTimeFilter) {
          case 'today':
            return eventDateOnly == today;
          case 'tomorrow':
            return eventDateOnly == tomorrow;
          case 'this_week':
            return eventDateOnly.isAfter(today.subtract(const Duration(days: 1))) && 
                   eventDateOnly.isBefore(nextWeek);
          default:
            return true;
        }
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<dynamic> _sortEventsByStartDate(List<dynamic> events) {
    final sortable = events.map((e) {
      DateTime? parsed;
      try {
        parsed = DateTime.parse(e['start_date']);
      } catch (_) {}
      return (event: e, date: parsed);
    }).toList();

    sortable.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

    return sortable.map((e) => e.event).toList();
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Event Image (Background)
            if (event['cover_image'] != null)
              Image.network(
                event['cover_image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Event Details (Bottom overlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      event['title'] ?? 'Event Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(event['start_date']),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date TBA';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date TBA';
    }
  }
} 
