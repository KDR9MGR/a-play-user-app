import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get paystackPublicKey {
    final key = dotenv.env['PAYSTACK_PUBLIC_KEY'];
    if (key == null) {
      throw Exception('PAYSTACK_PUBLIC_KEY not found in .env file');
    }
    return key;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
} 