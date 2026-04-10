import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OneSignal Notification Service
/// Handles push notifications for:
/// - Booking confirmations
/// - Event reminders (24h before)
/// - New messages in chat
/// - Subscription renewals
/// - Payment confirmations
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// Initialize OneSignal
  /// Call this in main.dart before runApp()
  Future<void> initialize({required String appId}) async {
    if (_isInitialized) {
      debugPrint('OneSignal already initialized');
      return;
    }

    try {
      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(appId);

      // Request notification permissions (iOS)
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      _setupNotificationHandlers();

      _isInitialized = true;
      debugPrint('OneSignal initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
    }
  }

  /// Setup notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('Foreground notification: ${event.notification.title}');
      // Allow the notification to display
      event.notification.display();
    });

    // Handle notification opened/clicked
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('Notification clicked: ${event.notification.additionalData}');
      _handleNotificationClick(event.notification.additionalData);
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint('Notification permission state: $state');
    });
  }

  /// Handle notification click routing
  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data == null) return;

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    debugPrint('Notification type: $type, ID: $id');

    // TODO: Implement navigation based on notification type
    // Example navigation logic:
    // - type: 'booking' → Navigate to booking details
    // - type: 'message' → Navigate to chat screen
    // - type: 'event_reminder' → Navigate to event details
    // - type: 'subscription' → Navigate to subscription screen
  }

  /// Set external user ID (Supabase user ID)
  /// Call this after user signs in
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('Error setting external user ID: $e');
    }
  }

  /// Remove external user ID
  /// Call this when user signs out
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal external user ID removed');
    } catch (e) {
      debugPrint('Error removing external user ID: $e');
    }
  }

  /// Send tag for user segmentation
  Future<void> sendTag(String key, String value) async {
    try {
      await OneSignal.User.addTagWithKey(key, value);
      debugPrint('OneSignal tag sent: $key = $value');
    } catch (e) {
      debugPrint('Error sending tag: $e');
    }
  }

  /// Remove tag
  Future<void> removeTag(String key) async {
    try {
      await OneSignal.User.removeTag(key);
      debugPrint('OneSignal tag removed: $key');
    } catch (e) {
      debugPrint('Error removing tag: $e');
    }
  }

  /// Get push subscription state
  Future<bool> isPushEnabled() async {
    try {
      final state = OneSignal.User.pushSubscription.optedIn;
      return state ?? false;
    } catch (e) {
      debugPrint('Error checking push state: $e');
      return false;
    }
  }

  /// Enable push notifications
  Future<void> enablePush() async {
    try {
      await OneSignal.User.pushSubscription.optIn();
      debugPrint('Push notifications enabled');
    } catch (e) {
      debugPrint('Error enabling push: $e');
    }
  }

  /// Disable push notifications
  Future<void> disablePush() async {
    try {
      await OneSignal.User.pushSubscription.optOut();
      debugPrint('Push notifications disabled');
    } catch (e) {
      debugPrint('Error disabling push: $e');
    }
  }

  /// Get OneSignal player ID
  String? get playerId {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      debugPrint('Error getting player ID: $e');
      return null;
    }
  }

  /// Send tags for user preferences
  Future<void> updateUserPreferences({
    required String userId,
    String? subscriptionTier,
    List<String>? eventCategories,
    String? location,
  }) async {
    try {
      final tags = <String, String>{
        'user_id': userId,
        if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
        if (location != null) 'location': location,
      };

      // Add event categories as individual tags
      if (eventCategories != null && eventCategories.isNotEmpty) {
        for (var i = 0; i < eventCategories.length; i++) {
          tags['category_$i'] = eventCategories[i];
        }
      }

      for (final entry in tags.entries) {
        await sendTag(entry.key, entry.value);
      }

      debugPrint('User preferences updated in OneSignal');
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
    }
  }
}

/// Riverpod provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
