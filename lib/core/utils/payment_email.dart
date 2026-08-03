import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves the email address to use for payment providers (Paystack
/// requires one) and transactional emails.
///
/// Apple Sign-In accounts may carry a Hide-My-Email relay address (which is
/// a perfectly valid email and works fine), but in known edge cases the auth
/// user can end up with no email at all. Every purchase path used to do
/// `user.email!`, which crashed for exactly those users. Resolve auth email
/// first, then the profiles row, and return null so callers can show a
/// friendly "add an email to your profile" message instead of crashing.
Future<String?> resolvePaymentEmail() async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) return null;

  final authEmail = user.email?.trim();
  if (authEmail != null && authEmail.isNotEmpty) return authEmail;

  try {
    final profile = await client
        .from('profiles')
        .select('email')
        .eq('id', user.id)
        .maybeSingle();
    final profileEmail = (profile?['email'] as String?)?.trim();
    if (profileEmail != null && profileEmail.isNotEmpty) return profileEmail;
  } catch (_) {
    // Fall through to null - caller shows a friendly message.
  }

  return null;
}

const String missingPaymentEmailMessage =
    'An email address is required for payment. Please add one to your '
    'profile and try again.';
