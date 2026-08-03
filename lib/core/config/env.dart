import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // NOTE: this client-side public key is not actually used by the live
  // payment flow - PaystackService.initializeTransaction() calls the
  // `paystack` Supabase edge function, which uses PAYSTACK_SECRET_KEY
  // server-side and returns a checkout URL the app just opens in a webview.
  // Whether payments run in test or live mode is controlled entirely by
  // that server-side secret (managed separately via Supabase secrets), not
  // by this value, so it's not safe/meaningful to crash app startup over
  // it being a pk_test_ key. Still throws on a genuinely missing value
  // since some plumbing does read it (paystackPublicKeyProvider etc), even
  // though nothing currently calls that plumbing from the UI.
  static String get paystackPublicKey {
    final dotenvKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    final envKey = const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
    final key = dotenvKey.isNotEmpty ? dotenvKey : envKey;

    if (key.isEmpty) {
      throw StateError(
        'Missing PAYSTACK_PUBLIC_KEY. Pass it via --dart-define, '
        '--dart-define-from-file, or a .env file.',
      );
    }

    return key;
  }

  // OneSignal App ID
  static String get oneSignalAppId {
    final dotenvKey = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
    if (dotenvKey.isNotEmpty) return dotenvKey;

    return const String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');
  }

  // Resend API Key
  static String get resendApiKey {
    final dotenvKey = dotenv.env['RESEND_API_KEY'] ?? '';
    if (dotenvKey.isNotEmpty) return dotenvKey;

    return const String.fromEnvironment('RESEND_API_KEY', defaultValue: '');
  }

  // Resend From Email
  static String get resendFromEmail {
    final dotenvKey = dotenv.env['RESEND_FROM_EMAIL'] ?? '';
    if (dotenvKey.isNotEmpty) return dotenvKey;

    return const String.fromEnvironment('RESEND_FROM_EMAIL', defaultValue: 'A-Play <noreply@aplayapp.com>');
  }

  static Future<void> initialize() async {
    // Load environment variables from .env file
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If .env doesn't exist, fall back to dart-defines
      // This is fine for production builds with dart-defines
    }
  }
}
