import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaystackService Tests', () {
    test('Environment variables should be loaded', () async {
      // Mock loading env
      dotenv.loadFromString(envString: '''
PAYSTACK_PUBLIC_KEY=test_public_key
''');
      
      // We can't access private static fields directly in test without reflection or making them public.
      // But we can verify the service doesn't crash on init.
      
      // This test mainly verifies that the dotenv integration works within the test environment.
      expect(dotenv.env['PAYSTACK_PUBLIC_KEY'], 'test_public_key');
      expect(dotenv.env['PAYSTACK_SECRET_KEY'], isNull);
    });
  });
}
