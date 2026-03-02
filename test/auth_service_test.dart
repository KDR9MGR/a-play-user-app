import 'package:flutter_test/flutter_test.dart';
import 'package:a_play/core/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('getCurrentUserName returns default "User" when no user is logged in', () async {
      final name = await AuthService.getCurrentUserName();
      expect(name, 'User');
    });
  });
}
