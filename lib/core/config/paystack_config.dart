class PaystackConfig {
  static String get publicKey => const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
}
