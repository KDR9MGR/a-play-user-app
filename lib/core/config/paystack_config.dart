import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaystackConfig {
  static String get publicKey => dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
}
