import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend subscription status fetched from Supabase Edge Function
/// This is the single source of truth for subscription state
class BackendSubscriptionStatus {
  final bool isSubscribed;
  final String? productId;
  final DateTime? expiry;
  final String? platform;
  final String? status;
  final bool? autoRenewEnabled;
  final bool? sandbox;

  BackendSubscriptionStatus({
    required this.isSubscribed,
    this.productId,
    this.expiry,
    this.platform,
    this.status,
    this.autoRenewEnabled,
    this.sandbox,
  });

  factory BackendSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return BackendSubscriptionStatus(
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      productId: json['productId'] as String?,
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry'] as String) : null,
      platform: json['platform'] as String?,
      status: json['status'] as String?,
      autoRenewEnabled: json['autoRenewEnabled'] as bool?,
      sandbox: json['sandbox'] as bool?,
    );
  }

  factory BackendSubscriptionStatus.notSubscribed() {
    return BackendSubscriptionStatus(isSubscribed: false);
  }

  /// Check if subscription is active (not just subscribed, but actually active)
  bool get isActive {
    if (!isSubscribed) return false;

    // Check status is in allowed set
    final allowedStatuses = ['active', 'grace_period'];
    if (status != null && !allowedStatuses.contains(status)) {
      return false;
    }

    // Check expiry (if present, must be in future)
    if (expiry != null && expiry!.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'BackendSubscriptionStatus(isSubscribed: $isSubscribed, productId: $productId, expiry: $expiry, status: $status, active: $isActive)';
  }
}

/// Provider that fetches subscription status from Supabase backend
/// This is the single source of truth - all subscription checks should use this
final backendSubscriptionStatusProvider = FutureProvider<BackendSubscriptionStatus>((ref) async {
  if (kDebugMode) print('BackendSubscriptionProvider: Fetching subscription status from backend...');

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  // If no user is logged in, they don't have a subscription
  if (user == null) {
    if (kDebugMode) print('BackendSubscriptionProvider: No user logged in - not subscribed');
    return BackendSubscriptionStatus.notSubscribed();
  }

  try {
    if (kDebugMode) print('BackendSubscriptionProvider: User ID: ${user.id}');
    if (kDebugMode) print('BackendSubscriptionProvider: Calling get-subscription-status Edge Function...');

    // Call Supabase Edge Function to get subscription status
    final response = await supabase.functions.invoke(
      'get-subscription-status',
      body: {
        'userId': user.id,
      },
    );

    if (kDebugMode) print('BackendSubscriptionProvider: Response status: ${response.status}');

    if (response.status != 200) {
      throw Exception('Edge Function returned status ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;
    if (kDebugMode) print('BackendSubscriptionProvider: Response data: $data');

    final status = BackendSubscriptionStatus.fromJson(data);
    if (kDebugMode) print('BackendSubscriptionProvider: $status');

    return status;

  } catch (e) {
    if (kDebugMode) print('❌ BackendSubscriptionProvider: Error fetching status: $e');
    // On error, return not subscribed (fail-safe)
    return BackendSubscriptionStatus.notSubscribed();
  }
});

/// Simple boolean provider - does user have premium access?
/// This is what most UI should check
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(backendSubscriptionStatusProvider);

  return subscriptionAsync.when(
    data: (status) => status.isActive,
    loading: () => false, // While loading, assume no access
    error: (_, __) => false, // On error, assume no access
  );
});

/// Provider to manually refresh subscription status
/// Call this after a successful purchase or when you need to force refresh
class SubscriptionStatusRefresher {
  static void refresh(WidgetRef ref) {
    if (kDebugMode) print('SubscriptionStatusRefresher: Invalidating subscription status...');
    ref.invalidate(backendSubscriptionStatusProvider);
  }

  static Future<void> refreshAndWait(WidgetRef ref) async {
    if (kDebugMode) print('SubscriptionStatusRefresher: Refreshing and waiting for subscription status...');
    ref.invalidate(backendSubscriptionStatusProvider);
    await ref.read(backendSubscriptionStatusProvider.future);
    if (kDebugMode) print('SubscriptionStatusRefresher: Refresh complete');
  }
}
