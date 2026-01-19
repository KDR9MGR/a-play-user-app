# 🚀 Real-Time Sync - Quick Start Guide

**For Developers**: Quick reference for implementing real-time data sync

---

## ⚡ Quick Setup (Already Done!)

The real-time system is **already configured** and running! Here's what's set up:

### ✅ What's Already Working

1. **Service Initialized** - [main.dart:68-72](lib/main.dart)
   - Runs on app startup
   - Subscribes to 12 tables automatically
   - Logs: `✅ Real-time sync initialized`

2. **12 Tables Monitored**:
   - ✅ events
   - ✅ clubs, lounges, pubs, arcade_centers, beaches, live_shows
   - ✅ restaurants
   - ✅ feed, post_gifts
   - ✅ user_subscriptions, profiles

3. **Example Provider Created** - [realtime_event_provider.dart](lib/core/providers/realtime_event_provider.dart)
   - Shows how to build real-time enabled providers
   - Automatically updates when admin changes data

---

## 🔨 How to Add Real-Time to Your Feature

### Option 1: Use Existing Event Provider (Recommended)

```dart
import 'package:a_play/core/providers/realtime_event_provider.dart';

// In your widget
class MyEventsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(realtimeEventProvider);

    return eventsAsync.when(
      data: (events) => EventsList(events: events),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

**That's it!** Your UI will now update automatically when admin creates/updates events.

### Option 2: Create Your Own Real-Time Provider

Copy the pattern from `realtime_event_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/core/services/realtime_sync_service.dart';

class RealtimeClubNotifier extends AsyncNotifier<List<Club>> {
  final SupabaseClient _client = Supabase.instance.client;
  final RealtimeSyncService _realtimeSync = RealtimeSyncService();
  StreamSubscription? _subscription;

  @override
  Future<List<Club>> build() async {
    final clubs = await _fetchClubs();
    _subscribeToRealtime();
    ref.onDispose(() => _subscription?.cancel());
    return clubs;
  }

  Future<List<Club>> _fetchClubs() async {
    final response = await _client.from('clubs').select();
    return (response as List)
        .map((json) => Club.fromJson(json))
        .toList();
  }

  void _subscribeToRealtime() {
    final stream = _realtimeSync.getStream('clubs');
    if (stream == null) return;

    _subscription = stream.listen((update) async {
      if (update.isInsert || update.isUpdate) {
        final clubs = await _fetchClubs();
        state = AsyncData(clubs);
      } else if (update.isDelete) {
        final currentClubs = state.value ?? [];
        final deletedId = update.oldRecord!['id'];
        state = AsyncData(
          currentClubs.where((club) => club.id != deletedId).toList(),
        );
      }
    });
  }
}

final realtimeClubProvider = AsyncNotifierProvider<RealtimeClubNotifier, List<Club>>(
  () => RealtimeClubNotifier(),
);
```

---

## 📝 Testing Your Real-Time Implementation

### Test 1: Manual Test
1. Run your app
2. Open Supabase Dashboard → Table Editor
3. Insert/Update/Delete a record
4. ✅ Changes should appear in your app within 1-2 seconds

### Test 2: Admin App Test
1. Run user app on device/emulator
2. Run admin app
3. Create/update data in admin app
4. ✅ User app should update automatically

### Test 3: Check Console Logs
```
Look for these logs:
🔄 RealtimeSync: Initializing real-time subscriptions...
✅ Subscribed to events table
✅ Subscribed to clubs table
...
✅ RealtimeSync: All subscriptions initialized successfully
```

---

## 🎯 Common Patterns

### Pattern 1: List View with Real-Time Updates

```dart
class EventsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(realtimeEventProvider);

    return eventsAsync.when(
      data: (events) => ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) => EventCard(event: events[index]),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorMessage(error: error),
    );
  }
}
```

### Pattern 2: Detail View with Real-Time Updates

```dart
class EventDetailView extends ConsumerWidget {
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(realtimeEventProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere(
          (e) => e.id == eventId,
          orElse: () => null,
        );

        if (event == null) {
          return EventNotFound();
        }

        return EventDetails(event: event);
      },
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error),
    );
  }
}
```

### Pattern 3: Filtered List with Real-Time Updates

```dart
class FeaturedEventsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider automatically filters and updates!
    final featuredEvents = ref.watch(featuredEventsProvider);

    return ListView.builder(
      itemCount: featuredEvents.length,
      itemBuilder: (context, index) => EventCard(event: featuredEvents[index]),
    );
  }
}
```

### Pattern 4: Pull-to-Refresh (Optional)

```dart
class EventsWithRefresh extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(realtimeEventProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(realtimeEventProvider.notifier).refresh();
      },
      child: eventsAsync.when(
        data: (events) => ListView(...),
        loading: () => LoadingIndicator(),
        error: (error, stack) => ErrorWidget(error),
      ),
    );
  }
}
```

---

## 🔍 Debugging Real-Time Issues

### Check 1: Is Service Initialized?

```dart
// In your app, add this debug code:
final realtimeService = RealtimeSyncService();
print('Subscribed tables: ${realtimeService.getSubscribedTables()}');
print('Is events subscribed? ${realtimeService.isSubscribed('events')}');
```

Expected output:
```
Subscribed tables: [events, clubs, lounges, pubs, ...]
Is events subscribed? true
```

### Check 2: Are Updates Being Received?

Add listener to see updates:

```dart
final stream = RealtimeSyncService().getStream('events');
stream?.listen((update) {
  print('📥 Received update: ${update.eventType} for ${update.table}');
  print('   Record: ${update.record}');
});
```

### Check 3: Supabase Real-Time Enabled?

1. Go to Supabase Dashboard
2. Database → Replication
3. Ensure your table has **Realtime** enabled
4. Click "Add table" if not listed

---

## 🚨 Common Issues & Fixes

### Issue: "Stream is null"

**Cause**: Table not subscribed or service not initialized

**Fix**:
```dart
// Ensure service is initialized in main.dart
await RealtimeSyncService().initialize();

// Check if table is subscribed
if (!RealtimeSyncService().isSubscribed('events')) {
  print('❌ Events table not subscribed!');
}
```

### Issue: Updates Not Showing

**Cause 1**: Using old static provider instead of real-time provider

**Fix**:
```dart
// ❌ Old way
final events = ref.watch(eventsProvider);

// ✅ New way
final eventsAsync = ref.watch(realtimeEventProvider);
```

**Cause 2**: Supabase real-time not enabled for table

**Fix**: Enable in Supabase Dashboard → Database → Replication

### Issue: Duplicate Updates

**Cause**: Multiple subscriptions to same table

**Fix**: RealtimeSyncService is singleton, so this shouldn't happen. If it does:
```dart
// Dispose old subscription first
await RealtimeSyncService().disposeSubscription('events');
```

---

## ✅ Verification Checklist

Before marking your feature as real-time enabled:

- [ ] Provider extends `AsyncNotifier`
- [ ] Uses `RealtimeSyncService().getStream()`
- [ ] Subscribes to real-time in `build()` method
- [ ] Cleans up with `ref.onDispose()`
- [ ] Handles INSERT, UPDATE, DELETE events
- [ ] UI uses `.when()` to handle loading/error/data states
- [ ] Tested with admin app making changes
- [ ] Console logs show updates being received
- [ ] No memory leaks observed

---

## 📚 Files to Reference

| File | Purpose |
|------|---------|
| [realtime_sync_service.dart](lib/core/services/realtime_sync_service.dart) | Core service managing all subscriptions |
| [realtime_event_provider.dart](lib/core/providers/realtime_event_provider.dart) | Example real-time provider |
| [main.dart](lib/main.dart) | Service initialization |
| [REALTIME_DATA_SYNC_GUIDE.md](REALTIME_DATA_SYNC_GUIDE.md) | Complete documentation |

---

## 🎯 Next Steps

1. **Use existing providers** for events (already real-time!)
2. **Create new providers** for clubs, restaurants, etc. using the same pattern
3. **Test thoroughly** with admin app
4. **Monitor performance** and optimize if needed

---

**Need Help?**
- Check [REALTIME_DATA_SYNC_GUIDE.md](REALTIME_DATA_SYNC_GUIDE.md) for detailed docs
- Review [realtime_event_provider.dart](lib/core/providers/realtime_event_provider.dart) for example
- Test with Supabase Dashboard to verify setup

**Happy Coding! 🚀**
