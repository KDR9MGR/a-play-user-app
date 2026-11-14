import 'package:flutter_test/flutter_test.dart';
import 'package:a_play/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthService', () {
    test('test harness initialised Supabase (guards against a silently-passing suite)', () {
      // If this throws, the harness is broken and AuthService would hit its
      // catch-all fallback instead of the real code path.
      expect(Supabase.instance.client.auth.currentSession, isNull);
    });

    test('getCurrentUserName returns null when no user is logged in', () async {
      // The UI supplies the "User" fallback (`snapshot.data ?? 'User'`); the
      // service returns null for a signed-out visitor.
      final name = await AuthService.getCurrentUserName();
      expect(name, isNull);
    });

    test('ensureValidSession is false when there is no session', () async {
      expect(await AuthService.ensureValidSession(), isFalse);
    });
  });
}
