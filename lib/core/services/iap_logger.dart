import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists structured breadcrumbs for the Apple IAP purchase flow to the
/// `iap_events` table.
///
/// Why this exists: iap_service.dart already had extensive debugPrint()
/// logging, but debugPrint output is invisible once the app is running on a
/// real user's device (TestFlight/App Store) - there was no way to see what
/// actually happened when a purchase failed for a real user, only what the
/// user could describe after the fact. Every call here is best-effort: a
/// logging failure (e.g. offline) must never interrupt the purchase flow it
/// is trying to observe.
class IAPLogger {
  static String? _appVersion;

  static Future<void> _ensureAppVersion() async {
    if (_appVersion != null) return;
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {
      _appVersion = 'unknown';
    }
  }

  static Future<void> log(
    String event, {
    String level = 'info',
    String? productId,
    String? transactionId,
    String? message,
    Map<String, dynamic>? detail,
  }) async {
    debugPrint('IAPLogger[$level]: $event${message != null ? ' - $message' : ''}');

    try {
      await _ensureAppVersion();
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return; // RLS requires auth.uid() = user_id; nothing to log yet.

      await client.from('iap_events').insert({
        'user_id': userId,
        'source': 'client',
        'event': event,
        'level': level,
        'product_id': productId,
        'transaction_id': transactionId,
        'platform': kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other')),
        'app_version': _appVersion,
        'message': message,
        'detail': detail,
      });
    } catch (e) {
      debugPrint('IAPLogger: failed to persist "$event": $e');
    }
  }
}
