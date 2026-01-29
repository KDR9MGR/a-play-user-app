import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/widgets/sign_in_dialog.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import '../provider/subscription_provider.dart';
import '../provider/backend_subscription_provider.dart';
import '../screens/paywall_screen.dart';
import '../model/subscription_model.dart';
import '../../profile/providers/profile_provider.dart';

class SubscriptionUtils {
  SubscriptionUtils._();

  /// Check if user has an active subscription
  static bool hasActiveSubscription(WidgetRef ref) {
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    return subscription?.isActive ?? false;
  }

  /// Check if user is on trial
  static bool isOnTrial(WidgetRef ref) {
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    return subscription?.isTrial ?? false;
  }

  /// Check if user has premium access
  /// PRIMARY SOURCE: Backend subscription status from Supabase (via get-subscription-status Edge Function)
  /// FALLBACK: Profile is_premium flag (for users with manually granted premium)
  static bool hasPremiumAccess(WidgetRef ref) {
    // PRIMARY: Check backend subscription status (this is the source of truth)
    final backendStatus = ref.watch(backendSubscriptionStatusProvider);

    final hasBackendSub = backendStatus.when(
      data: (status) => status.isActive,
      loading: () => false,
      error: (_, __) => false,
    );

    if (hasBackendSub) {
      return true;
    }

    // FALLBACK: Check profile is_premium flag (for manually granted premium)
    // This is kept as a fallback for users who were given premium access outside of IAP
    final profileAsync = ref.watch(profileFutureProvider);
    return profileAsync.when(
      data: (profile) => profile.isPremium,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Show paywall if user doesn't have premium access
  /// Returns true if user has access, false if paywall was shown
  /// IMPORTANT: Now checks authentication FIRST before checking premium status
  static Future<bool> requirePremiumAccess(
    BuildContext context,
    WidgetRef ref, {
    String? featureName,
    VoidCallback? onSkip,
  }) async {
    // CRITICAL: First check if user is authenticated
    // This prevents crashes when guest users try to access premium features
    final user = ref.read(authStateProvider).value;

    if (user == null) {
      // Show sign-in dialog for guest users
      final signedIn = await SignInDialog.showBottomSheet(
        context,
        featureName: featureName,
        message: featureName != null
            ? 'Sign in to access $featureName'
            : 'Sign in to access premium features',
      );

      if (!signedIn) {
        return false; // User dismissed dialog or didn't sign in
      }

      // Verify user actually signed in
      final userAfter = ref.read(authStateProvider).value;
      if (userAfter == null) {
        return false; // User didn't complete sign-in
      }
    }

    // User is authenticated, now check premium access
    if (hasPremiumAccess(ref)) {
      return true;
    }

    // User is authenticated but not premium, show paywall
    await PaywallModal.show(
      context,
      featureName: featureName,
      onSkip: onSkip,
    );

    return false;
  }

  /// Navigate to subscription flow
  static void navigateToSubscriptionFlow(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription-flow');
  }

  /// Show trial expired dialog
  static Future<void> showTrialExpiredDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Trial Expired'),
          ],
        ),
        content: const Text(
          'Your 3-day free trial has ended. Subscribe now to continue enjoying premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              navigateToSubscriptionFlow(context);
            },
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  /// Get remaining trial days
  static int getRemainingTrialDays(WidgetRef ref) {
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    if (subscription?.isTrial != true) return 0;
    
    final now = DateTime.now();
    final endDate = subscription!.endDate;
    final difference = endDate.difference(now).inDays;
    
    return difference > 0 ? difference : 0;
  }

  /// Check if trial is ending soon (within 24 hours)
  static bool isTrialEndingSoon(WidgetRef ref) {
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    if (subscription?.isTrial != true) return false;
    
    final now = DateTime.now();
    final endDate = subscription!.endDate;
    final hoursRemaining = endDate.difference(now).inHours;
    
    return hoursRemaining <= 24 && hoursRemaining > 0;
  }

  /// Show trial ending soon notification
  static void showTrialEndingSoonNotification(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (!isTrialEndingSoon(ref)) return;
    
    final hoursRemaining = getRemainingTrialHours(ref);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Icon(Icons.timer, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Trial ends in $hoursRemaining hours. Subscribe to continue!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Subscribe',
          textColor: Colors.white,
          onPressed: () => navigateToSubscriptionFlow(context),
        ),
      ),
    );
  }

  /// Get remaining trial hours
  static int getRemainingTrialHours(WidgetRef ref) {
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    if (subscription?.isTrial != true) return 0;
    
    final now = DateTime.now();
    final endDate = subscription!.endDate;
    final difference = endDate.difference(now).inHours;
    
    return difference > 0 ? difference : 0;
  }

  /// Refresh premium status by invalidating relevant providers
  /// This forces a new call to get-subscription-status Edge Function
  static void refreshPremiumStatus(WidgetRef ref) {
    SubscriptionStatusRefresher.refresh(ref);
    ref.invalidate(profileFutureProvider);
    ref.invalidate(activeSubscriptionProvider);
  }

  /// Refresh premium status and wait for completion
  /// Use this after successful purchase to ensure UI updates
  static Future<void> refreshPremiumStatusAndWait(WidgetRef ref) async {
    await SubscriptionStatusRefresher.refreshAndWait(ref);
    ref.invalidate(profileFutureProvider);
    ref.invalidate(activeSubscriptionProvider);
  }
}

/// Widget that conditionally shows content based on subscription status
class PremiumContent extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;
  final String? featureName;
  final bool showPaywall;

  const PremiumContent({
    super.key,
    required this.child,
    this.fallback,
    this.featureName,
    this.showPaywall = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremium = SubscriptionUtils.hasPremiumAccess(ref);
    
    if (hasPremium) {
      return child;
    }
    
    if (fallback != null) {
      return fallback!;
    }
    
    if (showPaywall) {
      return GestureDetector(
        onTap: () => SubscriptionUtils.requirePremiumAccess(
          context,
          ref,
          featureName: featureName,
        ),
        child: Stack(
          children: [
            // Blurred/disabled content
            IgnorePointer(
              child: Opacity(
                opacity: 0.3,
                child: child,
              ),
            ),
            // Lock overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Premium Feature',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap to unlock',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Mixin for screens that need subscription checking
mixin SubscriptionAwareMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSubscriptionStatus();
    });
  }

  void _checkSubscriptionStatus() {
    // Check if trial is ending soon
    SubscriptionUtils.showTrialEndingSoonNotification(context, ref);
    
    // Check if trial has expired
    final subscription = ref.read(activeSubscriptionProvider).valueOrNull;
    if (subscription != null && subscription.isTrial && subscription.isExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SubscriptionUtils.showTrialExpiredDialog(context, ref);
      });
    }
  }

  /// Override this to handle when user gains premium access
  void onPremiumAccessGranted() {}
  
  /// Override this to handle when user loses premium access
  void onPremiumAccessLost() {}
}