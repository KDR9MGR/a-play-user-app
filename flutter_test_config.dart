import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final url = const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://example.supabase.co');
  final anon = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_xxx');
  try {
    await Supabase.initialize(url: url, anonKey: anon, debug: false);
  } catch (_) {
    // Ignore initialization errors in tests; most tests don't require backend.
  }
  await testMain();
}
