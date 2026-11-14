import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/subscription_model.dart';
import '../service/subscription_service.dart';
import '../controller/subscription_controller.dart';
import '../../../core/services/iap_service.dart';
import 'backend_subscription_provider.dart';

// Service provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

// Subscription plans provider
final subscriptionPlansProvider = AsyncNotifierProvider<SubscriptionPlansNotifier, List<SubscriptionPlan>>(() {
  return SubscriptionPlansNotifier();
});

// Active subscription provider
final activeSubscriptionProvider = AsyncNotifierProvider<ActiveSubscriptionNotifier, UserSubscription?>(() {
  return ActiveSubscriptionNotifier();
});

// Subscription history provider
final subscriptionHistoryProvider = AsyncNotifierProvider<SubscriptionHistoryNotifier, List<UserSubscription>>(() {
  return SubscriptionHistoryNotifier();
});

// Payment history provider
final paymentHistoryProvider = AsyncNotifierProvider<PaymentHistoryNotifier, List<SubscriptionPayment>>(() {
  return PaymentHistoryNotifier();
});

// Payment provider for handling payment operations
final paymentProvider = AsyncNotifierProvider<PaymentNotifier, Map<String, dynamic>?>(() {
  return PaymentNotifier();
});

// Provider to check if user has active subscription
final hasActiveSubscriptionProvider = FutureProvider<bool>((ref) async {
  final activeSubscriptionNotifier = ref.watch(activeSubscriptionProvider.notifier);
  return await activeSubscriptionNotifier.hasActiveSubscription();
});

// Provider to get Paystack public key
final paystackPublicKeyProvider = Provider<String>((ref) {
  final paymentNotifier = ref.watch(paymentProvider.notifier);
  return paymentNotifier.getPaystackPublicKey();
}); 

/// Refreshes subscription state app-wide whenever the backend verifies an
/// Apple purchase - including one recovered silently at launch (a paid
/// transaction StoreKit redelivered after an earlier failure). Without this
/// the app keeps showing "Free" until something else happens to refresh it.
/// Watched once from the app root.
final iapVerifiedListenerProvider = Provider<void>((ref) {
  final sub = IAPService.instance.verifiedSubscriptions.listen((_) {
    ref.invalidate(activeSubscriptionProvider);
    ref.invalidate(hasActiveSubscriptionProvider);
    ref.invalidate(backendSubscriptionStatusProvider);
  });
  ref.onDispose(sub.cancel);
});
