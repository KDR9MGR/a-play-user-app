# Upcoming Events & Club Features - Analysis & Recommendations

## 📋 Issues Identified

### Issue #1: Upcoming Events Section Shows Nothing

**Location**: [filtered_events_section.dart](lib/features/home/widgets/filtered_events_section.dart)

**Root Cause Analysis**:

1. **Date Filtering Too Strict**
   - The filter logic in `_filterEventsByTime()` (lines 122-148) is filtering events based on `start_date`
   - For "today" filter: Requires exact match with today's date
   - For "tomorrow" filter: Requires exact match with tomorrow's date
   - For "this_week" filter: Events between today and 7 days from now

2. **Possible Data Issues**:
   - Events in database might not have proper `start_date` values
   - Events might all be in the past (already ended)
   - Event dates might be stored in incorrect format
   - No events marked as upcoming in the database

3. **Provider Issue**:
   - `upcomingEventsProvider` (line 26 in home_event_provider.dart) returns ALL home events
   - Then filters them on the client side
   - If `getHomeEvents()` returns empty list, nothing will show

**Current Filter Logic**:
```dart
case 'today':
  return eventDateOnly == today; // Exact match only

case 'tomorrow':
  return eventDateOnly == tomorrow; // Exact match only

case 'this_week':
  return eventDateOnly.isAfter(today.subtract(const Duration(days: 1))) &&
         eventDateOnly.isBefore(nextWeek); // 7-day window
```

---

### Issue #2: Club Details - No Upcoming Events Listed

**Location**: [club_details_screen.dart](lib/features/club_booking/screens/club_details_screen.dart)

**Root Cause**:
- Club details screen only shows table booking functionality
- **No section for upcoming events at that club**
- **No events associated with clubs** in the data model
- No service method to fetch events by club/venue

**Missing Features**:
1. Events list for specific club
2. Events filtered by venue
3. "Buy Tickets" option for club events
4. Events calendar for the club

---

## 🔍 Database Investigation Needed

### Events Table Structure
Check if the following exists in Supabase:

```sql
-- Check if events table has proper date columns
SELECT
  id,
  title,
  start_date,
  end_date,
  location,
  is_featured
FROM events
WHERE end_date > NOW()
ORDER BY start_date ASC
LIMIT 10;
```

### Check Event Counts
```sql
-- Count events by status
SELECT
  COUNT(*) as total_events,
  COUNT(CASE WHEN end_date > NOW() THEN 1 END) as upcoming_events,
  COUNT(CASE WHEN end_date < NOW() THEN 1 END) as past_events,
  COUNT(CASE WHEN is_featured = true THEN 1 END) as featured_events
FROM events;
```

### Check Club-Event Relationship
```sql
-- Check if clubs are linked to events
SELECT
  c.name as club_name,
  COUNT(e.id) as event_count
FROM clubs c
LEFT JOIN events e ON e.venue_id = c.id  -- Assuming this relationship exists
GROUP BY c.id, c.name;
```

---

## 🛠️ Recommended Fixes

### Fix #1: Improve Upcoming Events Display

#### Option A: Relax Filter Logic (Quick Fix)
Make filters more lenient to show more events:

**File**: `lib/features/home/widgets/filtered_events_section.dart`

```dart
List<dynamic> _filterEventsByTime(List<dynamic> events) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final nextWeek = today.add(const Duration(days: 7));
  final endOfWeek = today.add(const Duration(days: 7));

  return events.where((event) {
    try {
      final eventDate = DateTime.parse(event['start_date']);
      final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

      switch (widget.selectedTimeFilter) {
        case 'today':
          // Show events starting today or later (more lenient)
          return eventDateOnly.isAtSameMomentAs(today) ||
                 (eventDateOnly.isAfter(today.subtract(const Duration(days: 1))) &&
                  eventDateOnly.isBefore(tomorrow));

        case 'tomorrow':
          return eventDateOnly.isAtSameMomentAs(tomorrow);

        case 'this_week':
          // Show all events from today up to next week
          return eventDateOnly.isAtSameMomentAs(today) ||
                 (eventDateOnly.isAfter(today) && eventDateOnly.isBefore(endOfWeek.add(const Duration(days: 1))));

        default:
          // Default: show all upcoming events
          return eventDateOnly.isAtSameMomentAs(today) || eventDateOnly.isAfter(today);
      }
    } catch (e) {
      print('Error parsing date: $e');
      return false;
    }
  }).toList();
}
```

#### Option B: Add Fallback Display (Better UX)
Show message when filter results are empty but events exist:

```dart
data: (events) {
  final filteredEvents = _filterEventsByTime(events);

  if (filteredEvents.isEmpty && events.isNotEmpty) {
    // Has events but filter excluded them all
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 48),
            const SizedBox(height: 8),
            Text(
              'No events found for "${widget.selectedTimeFilter}"',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Show all upcoming events instead
                setState(() {
                  // Reset filter or navigate to full events page
                });
              },
              child: const Text('View All Upcoming Events'),
            ),
          ],
        ),
      ),
    );
  }

  if (filteredEvents.isEmpty) {
    // Actually no events in database
    return Container(...); // Existing empty state
  }

  // Display filtered events grid
  return Container(...);
}
```

#### Option C: Add Debug Logging (Diagnostic)
Add logging to understand what's happening:

```dart
List<dynamic> _filterEventsByTime(List<dynamic> events) {
  print('=== FILTER DEBUG ===');
  print('Total events received: ${events.length}');
  print('Selected filter: ${widget.selectedTimeFilter}');

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  print('Today date: $today');

  final filtered = events.where((event) {
    try {
      final eventDate = DateTime.parse(event['start_date']);
      final eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
      print('Event: ${event['title']} - Date: $eventDateOnly');

      bool matches = false;
      switch (widget.selectedTimeFilter) {
        case 'today':
          matches = eventDateOnly == today;
          break;
        // ... other cases
      }

      print('  Matches filter: $matches');
      return matches;
    } catch (e) {
      print('  Error parsing: $e');
      return false;
    }
  }).toList();

  print('Filtered events count: ${filtered.length}');
  print('===================');
  return filtered;
}
```

---

### Fix #2: Add Events to Club Details Page

#### Step 1: Create Club Events Service Method

**File**: `lib/features/home/service/home_service.dart`

Add new method:

```dart
Future<List<EventModel>> getEventsByVenue(String venueId) async {
  try {
    final now = DateTime.now().toIso8601String();
    final response = await supabase
        .from('events')
        .select()
        .eq('venue_id', venueId)  // Assuming events have venue_id field
        .gt('end_date', now)
        .order('start_date', ascending: true)
        .limit(10);

    return response.map((data) => EventModel.fromJson(data)).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching events by venue: $e');
    }
    return [];
  }
}

Future<List<EventModel>> getEventsByClub(String clubId) async {
  try {
    final now = DateTime.now().toIso8601String();
    final response = await supabase
        .from('events')
        .select()
        .eq('club_id', clubId)  // Or use venue_id if clubs are venues
        .gt('end_date', now)
        .order('start_date', ascending: true)
        .limit(10);

    return response.map((data) => EventModel.fromJson(data)).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching events by club: $e');
    }
    return [];
  }
}
```

#### Step 2: Create Provider

**File**: `lib/features/home/providers/home_event_provider.dart`

Add:

```dart
final clubEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, clubId) async {
  final homeService = ref.watch(homeServiceProvider);
  return homeService.getEventsByClub(clubId);
});
```

#### Step 3: Update Club Details Screen

**File**: `lib/features/club_booking/screens/club_details_screen.dart`

Add events section to the UI:

```dart
// Add this import
import 'package:a_play/features/home/providers/home_event_provider.dart';
import 'package:a_play/data/models/event_model.dart';

// In build method, add this section after the booking section:

// Club Events Section
_buildClubEventsSection(),

// Add this method to the class:
Widget _buildClubEventsSection() {
  final clubEvents = ref.watch(clubEventsProvider(widget.club.id));

  return clubEvents.when(
    loading: () => const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    ),
    error: (error, stack) => const SizedBox.shrink(),
    data: (events) {
      if (events.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Upcoming Events at this Club',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(event);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

Widget _buildEventCard(EventModel event) {
  return GestureDetector(
    onTap: () {
      // Navigate to event details
      context.push('/event/${event.id}');
    },
    child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: event.coverImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(event.coverImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: event.coverImage.isEmpty ? Colors.grey[800] : null,
            ),
            child: event.coverImage.isEmpty
                ? const Center(
                    child: Icon(Icons.event, color: Colors.white, size: 32),
                  )
                : null,
          ),

          // Event Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(event.startDate),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push('/event/${event.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text('Buy Tickets'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 🗄️ Database Schema Updates Needed

### 1. Add Club/Venue Relationship to Events

```sql
-- Add venue_id or club_id to events table
ALTER TABLE events
ADD COLUMN venue_id UUID REFERENCES clubs(id) ON DELETE SET NULL;

-- Create index for faster queries
CREATE INDEX idx_events_venue_id ON events(venue_id);

-- Update existing events to link with clubs/venues
UPDATE events
SET venue_id = clubs.id
FROM clubs
WHERE events.location ILIKE '%' || clubs.name || '%';
```

### 2. Ensure Proper Date Indexes

```sql
-- Add indexes for date filtering
CREATE INDEX idx_events_start_date ON events(start_date);
CREATE INDEX idx_events_end_date ON events(end_date);
CREATE INDEX idx_events_dates_active ON events(start_date, end_date)
WHERE end_date > NOW();
```

---

## 🎯 Testing Checklist

### Test Upcoming Events
- [ ] Add test events with today's date
- [ ] Add test events with tomorrow's date
- [ ] Add test events within next 7 days
- [ ] Verify "Today" filter shows correct events
- [ ] Verify "Tomorrow" filter shows correct events
- [ ] Verify "This Week" filter shows correct events
- [ ] Test with empty database
- [ ] Test with past events only
- [ ] Check error handling
- [ ] Verify loading states

### Test Club Events
- [ ] Create events linked to specific clubs
- [ ] Navigate to club details
- [ ] Verify events section appears
- [ ] Click on event card
- [ ] Verify navigation to event details
- [ ] Test with club having no events
- [ ] Test with club having many events
- [ ] Verify "Buy Tickets" button works

---

## 📊 Data Requirements

### Sample Events Data Needed

```sql
-- Insert sample upcoming events
INSERT INTO events (
  id,
  title,
  description,
  start_date,
  end_date,
  location,
  cover_image,
  price,
  is_featured,
  venue_id
) VALUES
(
  uuid_generate_v4(),
  'Afrobeats Night',
  'The hottest Afrobeats party in Accra',
  NOW() + INTERVAL '1 day',  -- Tomorrow
  NOW() + INTERVAL '2 days',
  'Accra Sports Stadium',
  'https://example.com/afrobeats.jpg',
  50.00,
  true,
  (SELECT id FROM clubs WHERE name = 'Republic Bar' LIMIT 1)
),
(
  uuid_generate_v4(),
  'Weekend Vibes',
  'End your week with amazing music and vibes',
  NOW() + INTERVAL '3 days',  -- This weekend
  NOW() + INTERVAL '4 days',
  'Osu Oxford Street',
  'https://example.com/weekend.jpg',
  30.00,
  false,
  (SELECT id FROM clubs WHERE name = 'Twist Nightclub' LIMIT 1)
);
```

---

## 🚀 Immediate Action Items

### Priority 1 (Critical)
1. ✅ **Created subscription plans documentation**
2. ⚠️ **Add debug logging** to upcoming events filter
3. ⚠️ **Check Supabase** for existing events data
4. ⚠️ **Relax filter logic** to show more events

### Priority 2 (High)
1. ⚠️ Add `venue_id` field to events table
2. ⚠️ Create `getEventsByClub()` service method
3. ⚠️ Add events section to club details screen
4. ⚠️ Test with real data

### Priority 3 (Medium)
1. Add empty state with helpful message
2. Add "View All Events" button
3. Improve error messages
4. Add event count badge to clubs

---

## 🐛 Known Issues & Limitations

### Current Limitations
1. **No Club-Event Linking**: Events not linked to clubs in database
2. **Strict Filters**: Date filters too strict, may exclude valid events
3. **No Fallback**: If filter returns empty, user sees nothing
4. **Poor Error Messages**: Generic "No events found" message
5. **No Debug Info**: Hard to diagnose why events don't show

### Future Improvements
1. Add event search functionality
2. Add event categories/tags
3. Add "Save Event" functionality
4. Add event sharing
5. Add event notifications
6. Add club-specific event calendar

---

**Created**: December 15, 2024
**Last Updated**: December 15, 2024
**Status**: Analysis Complete - Awaiting Implementation
**Priority**: HIGH
