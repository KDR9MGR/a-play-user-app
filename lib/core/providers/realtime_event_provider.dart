import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/event_model.dart';
import '../services/realtime_sync_service.dart';

/// Provider for events with real-time synchronization
/// Automatically updates when admin/org app creates/updates/deletes events
class RealtimeEventNotifier extends AsyncNotifier<List<EventModel>> {
  final SupabaseClient _client = Supabase.instance.client;
  final RealtimeSyncService _realtimeSync = RealtimeSyncService();
  StreamSubscription? _subscription;

  @override
  Future<List<EventModel>> build() async {
    // Load initial events
    final events = await _fetchEvents();

    // Subscribe to real-time updates
    _subscribeToRealtime();

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return events;
  }

  /// Fetch all active events from database
  Future<List<EventModel>> _fetchEvents() async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('is_active', true)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  /// Subscribe to real-time updates from Supabase
  void _subscribeToRealtime() {
    final stream = _realtimeSync.getStream('events');
    if (stream == null) return;

    _subscription = stream.listen((update) async {
      try {
        if (update.isInsert || update.isUpdate) {
          // Refresh data when event is added or updated
          await _refreshEvents();
        } else if (update.isDelete) {
          // Remove deleted event from list
          final currentState = state.value;
          if (currentState != null && update.oldRecord != null) {
            final deletedId = update.oldRecord!['id'];
            state = AsyncData(
              currentState.where((event) => event.id != deletedId).toList(),
            );
          }
        }
      } catch (e) {
        // Don't crash on realtime errors, just log them
        debugPrint('Error handling realtime event update: $e');
      }
    });
  }

  /// Refresh events list
  Future<void> _refreshEvents() async {
    try {
      final events = await _fetchEvents();
      state = AsyncData(events);
    } catch (e) {
      // Keep existing state on error
      debugPrint('Error refreshing events: $e');
    }
  }

  /// Manual refresh method
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchEvents());
  }

  /// Get upcoming events (future events only)
  List<EventModel> getUpcomingEvents() {
    final events = state.value ?? [];
    final now = DateTime.now();
    return events.where((event) => event.startDate.isAfter(now)).toList();
  }

  /// Get featured events
  List<EventModel> getFeaturedEvents() {
    final events = state.value ?? [];
    return events.where((event) => event.isFeatured).toList();
  }

  /// Get events by club
  List<EventModel> getEventsByClub(String clubId) {
    final events = state.value ?? [];
    return events.where((event) => event.clubId == clubId).toList();
  }
}

/// Provider instance
final realtimeEventProvider = AsyncNotifierProvider<RealtimeEventNotifier, List<EventModel>>(
  () => RealtimeEventNotifier(),
);

/// Provider for upcoming events only
final upcomingEventsProvider = Provider<List<EventModel>>((ref) {
  final eventsAsync = ref.watch(realtimeEventProvider);
  return eventsAsync.when(
    data: (events) {
      final now = DateTime.now();
      return events.where((event) => event.startDate.isAfter(now)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for featured events
final featuredEventsProvider = Provider<List<EventModel>>((ref) {
  final eventsAsync = ref.watch(realtimeEventProvider);
  return eventsAsync.when(
    data: (events) => events.where((event) => event.isFeatured).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for events by club
final eventsByClubProvider = Provider.family<List<EventModel>, String>((ref, clubId) {
  final eventsAsync = ref.watch(realtimeEventProvider);
  return eventsAsync.when(
    data: (events) => events.where((event) => event.clubId == clubId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
