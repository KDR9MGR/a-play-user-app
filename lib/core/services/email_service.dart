import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Transactional email, sent exclusively through Supabase Edge Functions.
///
/// The Resend API key lives in Supabase secrets (`RESEND_API_KEY`) and is
/// never present in the app bundle, so nothing on the device can send mail
/// by itself. Both functions identify the caller from the session JWT and
/// only ever send to that user's own address.
///
/// Booking / cancellation / subscription emails are sent by their own
/// services via the `send-email` function.
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  /// Sends the welcome email to the currently signed-in user.
  ///
  /// The recipient is taken from the caller's JWT by `send-welcome-email`,
  /// not from the client, so this must be called while a session exists.
  Future<bool> sendWelcomeEmail({required String userName}) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'send-welcome-email',
        body: {'userName': userName},
      );
      return response.status == 200;
    } catch (e) {
      debugPrint('Error sending welcome email: $e');
      return false;
    }
  }
}
