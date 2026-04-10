import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Hardcoded PayStack key (replace with your actual production key)
  static const String _hardcodedPaystackKey = 'pk_test_your_test_key';

  static String get paystackPublicKey {
    // Try flutter_dotenv first, then dart-define, then fall back to hardcoded
    final dotenvKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    if (dotenvKey.isNotEmpty) return dotenvKey;

    final envKey = const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    return _hardcodedPaystackKey;
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
