class Env {
  // Hardcoded PayStack key (replace with your actual production key)
  static const String _hardcodedPaystackKey = 'pk_test_your_test_key';

  static String get paystackPublicKey {
    final envKey = const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
    // First try dart-define, then fall back to hardcoded value
    if (envKey.isNotEmpty) return envKey;
    return _hardcodedPaystackKey;
  }

  static Future<void> initialize() async {
    return;
  }
} 
