class Env {
  static String get paystackPublicKey {
    return const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
  }

  static Future<void> initialize() async {
    return;
  }
} 
