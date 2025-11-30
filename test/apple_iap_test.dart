import 'package:flutter_test/flutter_test.dart';
import 'package:a_play/features/subscription/service/platform_subscription_service.dart';

void main() {
  group('Platform Subscription Service Tests', () {
    test('should create PlatformSubscriptionService without errors', () {
      expect(() => PlatformSubscriptionService(), returnsNormally);
    });

    test('should have initialize method', () {
      final service = PlatformSubscriptionService();
      expect(service.initialize, isA<Function>());
    });

    test('should have getAvailablePlans method', () {
      final service = PlatformSubscriptionService();
      expect(service.getAvailablePlans, isA<Function>());
    });

    test('should have purchaseSubscription method', () {
      final service = PlatformSubscriptionService();
      expect(service.purchaseSubscription, isA<Function>());
    });

    test('should have restorePurchases method', () {
      final service = PlatformSubscriptionService();
      expect(service.restorePurchases, isA<Function>());
    });

    test('should have appleIAPService getter', () {
      final service = PlatformSubscriptionService();
      // The getter should exist (not throw an error when accessed)
      expect(() => service.appleIAPService, returnsNormally);
    });
  });
}