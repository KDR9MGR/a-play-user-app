import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/subscription_model.dart';
import '../service/subscription_service.dart';
import '../provider/subscription_provider.dart';

class SubscriptionPlansNotifier extends AsyncNotifier<List<SubscriptionPlan>> {
  SubscriptionService get _subscriptionService => ref.read(subscriptionServiceProvider);

  @override
  Future<List<SubscriptionPlan>> build() {
    return _fetchSubscriptionPlans();
  }

  Future<List<SubscriptionPlan>> _fetchSubscriptionPlans() async {
    try {
      return await _subscriptionService.getSubscriptionPlans();
    } catch (e) {
      if (e.toString().contains('not initialized')) {
        throw AsyncError('Subscription service not ready. Please try again.', StackTrace.current);
      }
      throw AsyncError('Failed to fetch subscription plans: $e', StackTrace.current);
    }
  }
}

class ActiveSubscriptionNotifier extends AsyncNotifier<UserSubscription?> {
  SubscriptionService get _subscriptionService => ref.read(subscriptionServiceProvider);

  @override
  Future<UserSubscription?> build() {
    return _fetchActiveSubscription();
  }

  Future<UserSubscription?> _fetchActiveSubscription() async {
    try {
      return await _subscriptionService.getActiveSubscription();
    } catch (e) {
      if (e.toString().contains('not initialized')) {
        throw AsyncError('Subscription service not ready. Please try again.', StackTrace.current);
      }
      throw AsyncError('Failed to fetch active subscription: $e', StackTrace.current);
    }
  }

  Future<bool> hasActiveSubscription() async {
    try {
      return await _subscriptionService.hasActiveSubscription();
    } catch (e) {
      return false;
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      state = const AsyncLoading();
      await _subscriptionService.cancelSubscription(subscriptionId);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> isEligibleForTrial() async {
    try {
      return await _subscriptionService.isEligibleForTrial();
    } catch (e) {
      return false;
    }
  }

  Future<UserSubscription> startFreeTrial() async {
    try {
      state = const AsyncLoading();
      final subscription = await _subscriptionService.startFreeTrial();
      state = AsyncData(subscription);
      
      // Refresh other providers
      ref.invalidate(subscriptionPlansProvider);
      ref.invalidate(subscriptionHistoryProvider);
      
      return subscription;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

class SubscriptionHistoryNotifier extends AsyncNotifier<List<UserSubscription>> {
  SubscriptionService get _subscriptionService => ref.read(subscriptionServiceProvider);

  @override
  Future<List<UserSubscription>> build() {
    return _fetchSubscriptionHistory();
  }

  Future<List<UserSubscription>> _fetchSubscriptionHistory() async {
    try {
      return await _subscriptionService.getSubscriptionHistory();
    } catch (e) {
      throw AsyncError(e, StackTrace.current);
    }
  }
}

class PaymentHistoryNotifier extends AsyncNotifier<List<SubscriptionPayment>> {
  SubscriptionService get _subscriptionService => ref.read(subscriptionServiceProvider);

  @override
  Future<List<SubscriptionPayment>> build() {
    return _fetchPaymentHistory();
  }

  Future<List<SubscriptionPayment>> _fetchPaymentHistory() async {
    try {
      return await _subscriptionService.getPaymentHistory();
    } catch (e) {
      throw AsyncError(e, StackTrace.current);
    }
  }
}

class PaymentNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  SubscriptionService get _subscriptionService => ref.read(subscriptionServiceProvider);
  
  @override
  Future<Map<String, dynamic>?> build() async {
    return null; // No initial payment state
  }
  
  Future<Map<String, dynamic>> initializePayment(String email, double amount, String planId) async {
    try {
      state = const AsyncLoading();
      final result = await _subscriptionService.initializePaystackPayment(email, amount, planId);
      state = AsyncData(result);
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<PaystackVerification> verifyPayment(String reference) async {
    try {
      state = const AsyncLoading();
      final result = await _subscriptionService.verifyPaystackPayment(reference);
      // Access the status safely
      final bool isVerified = result.status;
      state = AsyncData({'verified': isVerified, 'reference': reference});
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<UserSubscription> createSubscription(String planId, String paymentReference) async {
    try {
      state = const AsyncLoading();
      final result = await _subscriptionService.createSubscription(planId, paymentReference);
      state = AsyncData({'subscribed': true, 'subscription': result});
      
      // Refresh other providers
      ref.invalidate(activeSubscriptionProvider);
      ref.invalidate(subscriptionHistoryProvider);
      ref.invalidate(paymentHistoryProvider);
      
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
  
  String getPaystackPublicKey() {
    return _subscriptionService.getPaystackPublicKey();
  }
  
  Future<bool> hasAppliedReferralCode() async {
    try {
      return await _subscriptionService.hasAppliedReferralCode();
    } catch (e) {
      return false;
    }
  }
  
  Future<void> applyReferralCode(String code) async {
    try {
      await _subscriptionService.applyReferralCode(code);
    } catch (e) {
      rethrow;
    }
  }
} 