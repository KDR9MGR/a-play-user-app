import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service for managing all Supabase real-time subscriptions
/// This ensures data stays in sync between user app, admin app, and org app
class RealtimeSyncService {
  final SupabaseClient _client = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController> _controllers = {};

  // Singleton pattern
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  /// Initialize all real-time subscriptions
  Future<void> initialize() async {
    debugPrint('🔄 RealtimeSync: Initializing real-time subscriptions...');

    try {
      // Subscribe to all tables that can be modified from admin/org apps
      await _subscribeToEvents();
      await _subscribeToClubs();
      await _subscribeToLounges();
      await _subscribeToPubs();
      await _subscribeToArcadeCenters();
      await _subscribeToBeaches();
      await _subscribeToLiveShows();
      await _subscribeToRestaurants();
      await _subscribeToFeed();
      await _subscribeToGifts();
      await _subscribeToSubscriptions();
      await _subscribeToProfiles();

      debugPrint('✅ RealtimeSync: All subscriptions initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ RealtimeSync: Error initializing subscriptions: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Subscribe to events table
  Future<void> _subscribeToEvents() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['events'] = controller;

    final channel = _client.channel('public:events');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          callback: (payload) {
            debugPrint('🎉 Event updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['title'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'events',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['events'] = channel;
    debugPrint('✅ Subscribed to events table');
  }

  /// Subscribe to clubs table
  Future<void> _subscribeToClubs() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['clubs'] = controller;

    final channel = _client.channel('public:clubs');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'clubs',
          callback: (payload) {
            debugPrint('🎊 Club updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'clubs',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['clubs'] = channel;
    debugPrint('✅ Subscribed to clubs table');
  }

  /// Subscribe to lounges table
  Future<void> _subscribeToLounges() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['lounges'] = controller;

    final channel = _client.channel('public:lounges');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lounges',
          callback: (payload) {
            debugPrint('🛋️ Lounge updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'lounges',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['lounges'] = channel;
    debugPrint('✅ Subscribed to lounges table');
  }

  /// Subscribe to pubs table
  Future<void> _subscribeToPubs() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['pubs'] = controller;

    final channel = _client.channel('public:pubs');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pubs',
          callback: (payload) {
            debugPrint('🍺 Pub updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'pubs',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['pubs'] = channel;
    debugPrint('✅ Subscribed to pubs table');
  }

  /// Subscribe to arcade_centers table
  Future<void> _subscribeToArcadeCenters() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['arcade_centers'] = controller;

    final channel = _client.channel('public:arcade_centers');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'arcade_centers',
          callback: (payload) {
            debugPrint('🎮 Arcade Center updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'arcade_centers',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['arcade_centers'] = channel;
    debugPrint('✅ Subscribed to arcade_centers table');
  }

  /// Subscribe to beaches table
  Future<void> _subscribeToBeaches() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['beaches'] = controller;

    final channel = _client.channel('public:beaches');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'beaches',
          callback: (payload) {
            debugPrint('🏖️ Beach updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'beaches',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['beaches'] = channel;
    debugPrint('✅ Subscribed to beaches table');
  }

  /// Subscribe to live_shows table
  Future<void> _subscribeToLiveShows() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['live_shows'] = controller;

    final channel = _client.channel('public:live_shows');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_shows',
          callback: (payload) {
            debugPrint('🎭 Live Show updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'live_shows',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['live_shows'] = channel;
    debugPrint('✅ Subscribed to live_shows table');
  }

  /// Subscribe to restaurants table
  Future<void> _subscribeToRestaurants() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['restaurants'] = controller;

    final channel = _client.channel('public:restaurants');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'restaurants',
          callback: (payload) {
            debugPrint('🍽️ Restaurant updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['name'] : 'N/A'}');
            controller.add(RealtimeUpdate(
              table: 'restaurants',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['restaurants'] = channel;
    debugPrint('✅ Subscribed to restaurants table');
  }

  /// Subscribe to feed table
  Future<void> _subscribeToFeed() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['feed'] = controller;

    final channel = _client.channel('public:feed');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'feed',
          callback: (payload) {
            debugPrint('📝 Feed post updated: ${payload.eventType}');
            controller.add(RealtimeUpdate(
              table: 'feed',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['feed'] = channel;
    debugPrint('✅ Subscribed to feed table');
  }

  /// Subscribe to post_gifts table
  Future<void> _subscribeToGifts() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['post_gifts'] = controller;

    final channel = _client.channel('public:post_gifts');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'post_gifts',
          callback: (payload) {
            debugPrint('🎁 Gift updated: ${payload.eventType} - ${payload.newRecord != null ? payload.newRecord['points_amount'] : 'N/A'} points');
            controller.add(RealtimeUpdate(
              table: 'post_gifts',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['post_gifts'] = channel;
    debugPrint('✅ Subscribed to post_gifts table');
  }

  /// Subscribe to user_subscriptions table
  Future<void> _subscribeToSubscriptions() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['user_subscriptions'] = controller;

    final channel = _client.channel('public:user_subscriptions');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_subscriptions',
          callback: (payload) {
            debugPrint('💳 Subscription updated: ${payload.eventType}');
            controller.add(RealtimeUpdate(
              table: 'user_subscriptions',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['user_subscriptions'] = channel;
    debugPrint('✅ Subscribed to user_subscriptions table');
  }

  /// Subscribe to profiles table
  Future<void> _subscribeToProfiles() async {
    final controller = StreamController<RealtimeUpdate>.broadcast();
    _controllers['profiles'] = controller;

    final channel = _client.channel('public:profiles');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            debugPrint('👤 Profile updated: ${payload.eventType}');
            controller.add(RealtimeUpdate(
              table: 'profiles',
              eventType: payload.eventType.name,
              record: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));
          },
        )
        .subscribe();

    _channels['profiles'] = channel;
    debugPrint('✅ Subscribed to profiles table');
  }

  /// Get stream for a specific table
  Stream<RealtimeUpdate>? getStream(String tableName) {
    return _controllers[tableName]?.stream as Stream<RealtimeUpdate>?;
  }

  /// Dispose a specific subscription
  Future<void> disposeSubscription(String tableName) async {
    final channel = _channels[tableName];
    if (channel != null) {
      await _client.removeChannel(channel);
      _channels.remove(tableName);
      debugPrint('🗑️ Disposed subscription: $tableName');
    }

    final controller = _controllers[tableName];
    if (controller != null) {
      await controller.close();
      _controllers.remove(tableName);
    }
  }

  /// Dispose all subscriptions
  Future<void> disposeAll() async {
    debugPrint('🗑️ Disposing all real-time subscriptions...');

    for (final channel in _channels.values) {
      await _client.removeChannel(channel);
    }
    _channels.clear();

    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();

    debugPrint('✅ All subscriptions disposed');
  }

  /// Check if a table is subscribed
  bool isSubscribed(String tableName) {
    return _channels.containsKey(tableName) && _controllers.containsKey(tableName);
  }

  /// Get list of all subscribed tables
  List<String> getSubscribedTables() {
    return _channels.keys.toList();
  }
}

/// Real-time update model
class RealtimeUpdate {
  final String table;
  final String eventType; // 'INSERT', 'UPDATE', 'DELETE'
  final Map<String, dynamic>? record;
  final Map<String, dynamic>? oldRecord;

  RealtimeUpdate({
    required this.table,
    required this.eventType,
    this.record,
    this.oldRecord,
  });

  bool get isInsert => eventType == 'INSERT';
  bool get isUpdate => eventType == 'UPDATE';
  bool get isDelete => eventType == 'DELETE';

  @override
  String toString() {
    return 'RealtimeUpdate(table: $table, eventType: $eventType, record: $record)';
  }
}
