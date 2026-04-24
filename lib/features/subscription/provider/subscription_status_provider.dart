import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscription status model
class SubscriptionStatus {
  final bool isSubscribed;
  final String tier;
  final DateTime? expiresAt;
  final int? daysRemaining;

  SubscriptionStatus({
    required this.isSubscribed,
    required this.tier,
    this.expiresAt,
    this.daysRemaining,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final expiresAtStr = json['subscription_expires_at'] as String?;
    final expiresAt = expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

    int? daysRemaining;
    if (expiresAt != null) {
      daysRemaining = expiresAt.difference(DateTime.now()).inDays;
    }

    return SubscriptionStatus(
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      tier: json['subscription_tier'] as String? ?? 'Free',
      expiresAt: expiresAt,
      daysRemaining: daysRemaining,
    );
  }

  bool get isActive => isSubscribed && (expiresAt?.isAfter(DateTime.now()) ?? false);
  bool get isPremium => isActive && tier != 'Free';
  bool get isExpiringSoon => daysRemaining != null && daysRemaining! <= 7;
}

/// Provider to get current user's subscription status
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value(SubscriptionStatus(
      isSubscribed: false,
      tier: 'Free',
    ));
  }

  // Watch profile changes for subscription status
  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', userId)
      .map((data) {
        if (data.isEmpty) {
          return SubscriptionStatus(
            isSubscribed: false,
            tier: 'Free',
          );
        }
        return SubscriptionStatus.fromJson(data.first);
      });
});

/// Provider to check if user is subscribed (simple boolean)
final isSubscribedProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider);
  return status.maybeWhen(
    data: (data) => data.isActive,
    orElse: () => false,
  );
});

/// Provider to get user tier
final userTierProvider = Provider<String>((ref) {
  final status = ref.watch(subscriptionStatusProvider);
  return status.maybeWhen(
    data: (data) => data.tier,
    orElse: () => 'Free',
  );
});

/// Provider to check if subscription is expiring soon
final isExpiringSoonProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider);
  return status.maybeWhen(
    data: (data) => data.isExpiringSoon,
    orElse: () => false,
  );
});
