import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Supabase.initialize persists/reads the session through shared_preferences,
  // a platform plugin that doesn't exist under `flutter test`. Without a mock
  // it throws MissingPluginException and every test file fails to load.
  TestWidgetsFlutterBinding.ensureInitialized();
  // The analyzer doesn't treat this root-level file as a test file.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});

  final url = const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://example.supabase.co');
  final anon = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_xxx');

  // Initialization must succeed: if it silently failed, code under test that
  // swallows errors (e.g. AuthService) would "pass" without exercising
  // anything. A MockClient is required because the default client builds a
  // dart:io HttpClient, which flutter_test forbids outside a test zone - and
  // it guarantees tests never reach the network (any call gets a 503).
  await Supabase.initialize(
    url: url,
    anonKey: anon,
    debug: false,
    httpClient: MockClient((http.Request request) async => http.Response('offline (test)', 503)),
    // No session to refresh in tests; don't leave a background timer running.
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
  );

  await testMain();
}
