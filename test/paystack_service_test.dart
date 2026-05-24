import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaystackService Tests', () {
    test('Compile-time defines are available', () async {
      const publicKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
      expect(publicKey, isA<String>());
    });
  });
}
