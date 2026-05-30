class PaystackConfig {
  // TEST credentials - active for testing
  static const String _testPublicKey = 'pk_test_f396c0cdcfed4c303906d61f6b1be25eb6e5ae36';

  // LIVE credentials - commented out for testing
  // static const String _livePublicKey = 'pk_live_YOUR_LIVE_KEY';

  static String get publicKey {
    // Check environment variable first
    final envKey = const String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Use TEST key by default
    return _testPublicKey;
  }
}
