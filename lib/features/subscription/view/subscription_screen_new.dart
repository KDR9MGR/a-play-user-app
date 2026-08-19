import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/iap_service.dart';
import '../../../services/unified_payment_service.dart';
import '../model/subscription_model.dart';
import '../provider/subscription_provider.dart';
import '../screens/subscription_success_screen.dart';
import '../screens/subscription_failure_screen.dart';
import '../service/subscription_sync_service.dart';
import '../../../core/utils/payment_email.dart';

/// Brand new, clean subscription screen
class SubscriptionScreenNew extends ConsumerStatefulWidget {
  const SubscriptionScreenNew({super.key});

  @override
  ConsumerState<SubscriptionScreenNew> createState() => _SubscriptionScreenNewState();
}

class _SubscriptionScreenNewState extends ConsumerState<SubscriptionScreenNew> {
  final _iapService = IAPService.instance;
  final _syncService = SubscriptionSyncService();

  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _hasActiveSubscription = false;
  Map<String, dynamic>? _activeSubscription;
  List<ProductDetails> _products = [];
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('SubscriptionScreen: Initializing...');

      // DEBUG: Check current user
      final currentUser = Supabase.instance.client.auth.currentUser;
      debugPrint('SubscriptionScreen: Current User ID = ${currentUser?.id}');
      debugPrint('SubscriptionScreen: Current User Email = ${currentUser?.email}');

      // CRITICAL: Sync database with StoreKit state FIRST
      // This detects cancellations and restores
      debugPrint('SubscriptionScreen: Syncing with StoreKit...');
      try {
        await _iapService.syncDatabaseWithStoreKit();
      } catch (e) {
        debugPrint('SubscriptionScreen: StoreKit sync failed (non-fatal): $e');
        // Continue anyway - this might fail in simulator or if StoreKit isn't configured
      }

      // STEP 1: Check for existing subscription AFTER sync
      debugPrint('SubscriptionScreen: Checking for existing subscriptions...');
      try {
        final hasActive = await _syncService.hasActiveSubscription();
        final activeSub = await _syncService.getActiveSubscription();

        debugPrint('SubscriptionScreen: hasActive = $hasActive');
        debugPrint('SubscriptionScreen: activeSub = $activeSub');

        if (hasActive) {
          debugPrint('SubscriptionScreen: ✓ User already has active subscription - SHOWING MANAGEMENT VIEW');
          if (mounted) {
            setState(() {
              _hasActiveSubscription = true;
              _activeSubscription = activeSub;
              _isLoading = false;
            });
          }
          return; // Don't load products if already subscribed
        }
      } catch (e) {
        debugPrint('SubscriptionScreen: Error checking subscriptions: $e');
        // Continue to load products even if subscription check fails
      }

      debugPrint('SubscriptionScreen: No active subscription found, loading products...');

      // STEP 2: Set up IAP callbacks
      _iapService.onPurchaseSuccess = _handlePurchaseSuccess;
      _iapService.onPurchaseError = _handlePurchaseError;
      _iapService.onPurchaseCancelled = _handlePurchaseCancelled;

      // STEP 3: Initialize IAP (or, if this is a retry after the first
      // attempt already initialized but came up with 0 products - e.g. a
      // transient StoreKit/network failure - just re-query products.
      // initialize() itself is a one-shot no-op once _isInitialized is true,
      // so calling it again here would silently do nothing and "Retry"
      // would never actually retry anything).
      try {
        if (_iapService.isInitialized) {
          await _iapService.reloadProducts();
        } else {
          await _iapService.initialize();
        }
      } catch (e) {
        debugPrint('SubscriptionScreen: IAP initialization failed: $e');
        // Don't set error - will fall back to PayStack plans
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _products = _iapService.products;
          _isLoading = false;
        });
      }

      debugPrint('SubscriptionScreen: Found ${_products.length} products');
    } catch (e, stackTrace) {
      debugPrint('SubscriptionScreen: Fatal initialization error: $e');
      debugPrint('StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize subscriptions: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _handlePurchaseSuccess(ProductDetails product) async {
    // By the time this fires, IAPService has already verified the receipt with
    // Apple via the backend and activated the subscription - this callback only
    // needs to update the UI.
    debugPrint('SubscriptionScreen: Purchase verified and activated: ${product.id}');

    // The home app bar's "Premium"/"Go Pro" badge and other screens read
    // subscription status from these Riverpod providers, not this screen's
    // local state - without invalidating them here they'd keep showing
    // stale "no subscription" data (cached FutureProvider) until something
    // else happened to refresh them, even though the purchase succeeded.
    ref.invalidate(hasActiveSubscriptionProvider);
    ref.invalidate(activeSubscriptionProvider);

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubscriptionSuccessScreen(
            planName: product.title.split('(').first.trim(),
            transactionId: product.id,
            expiryDate: DateTime.now().add(const Duration(days: 30)), // Default to 30 days
          ),
        ),
      );
    }
  }

  void _handlePurchaseError(String error) {
    debugPrint('SubscriptionScreen: Purchase error: $error');

    if (mounted) {
      setState(() {
        _isPurchasing = false;
        _errorMessage = error;
        _successMessage = null;
      });

      // Navigate to failure screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubscriptionFailureScreen(
            errorMessage: error,
            planName: null,
            onRetry: null, // Can't automatically retry IAP
          ),
        ),
      );
    }
  }

  void _handlePurchaseCancelled() {
    debugPrint('SubscriptionScreen: Purchase cancelled');

    if (mounted) {
      setState(() {
        _isPurchasing = false;
        _errorMessage = null;
        _successMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase cancelled')),
      );
    }
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    debugPrint('SubscriptionScreen: Purchasing ${product.id}');

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await _iapService.purchaseSubscription(product.id);
  }


  // Load PayStack subscription plans from database
  Future<List<SubscriptionPlan>> _loadPayStackPlans() async {
    try {
      debugPrint('Loading PayStack subscription plans from database...');

      final response = await Supabase.instance.client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('price');

      debugPrint('Loaded ${response.length} PayStack plans');

      return (response as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Failed to load PayStack plans: $e');
      // Return default plans as fallback
      return SubscriptionPlan.defaultPlans;
    }
  }

  // Build UI for PayStack subscription plans
  Widget _buildPayStackPlansUI(List<SubscriptionPlan> plans) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Get access to premium features',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Plans
        ...plans.map((plan) => _buildPayStackPlanCard(plan)),

        const SizedBox(height: 24),

        // Terms
        const Text(
          'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build individual PayStack plan card
  Widget _buildPayStackPlanCard(SubscriptionPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Card(
            elevation: plan.isPopular ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: plan.isPopular
                  ? const BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: _isPurchasing ? null : () => _purchaseWithPayStack(plan),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    if (plan.description != null && plan.description!.isNotEmpty)
                      Text(
                        plan.description!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      children: [
                        Text(
                          '${plan.currency} ${plan.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPayStackPeriodText(plan),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    // Benefits
                    if (plan.benefits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...plan.benefits.take(3).map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                benefit,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],

                    const SizedBox(height: 16),

                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPurchasing ? null : () => _purchaseWithPayStack(plan),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: plan.isPopular ? Colors.blue : null,
                        ),
                        child: const Text(
                          'Subscribe Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Popular badge
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPayStackPeriodText(SubscriptionPlan plan) {
    if (plan.planType == SubscriptionPlanType.trial) return 'free trial';
    if (plan.planType == SubscriptionPlanType.weekly) return '/ week';
    if (plan.planType == SubscriptionPlanType.monthly) return '/ month';
    if (plan.planType == SubscriptionPlanType.quarterly) return '/ 3 months';
    if (plan.planType == SubscriptionPlanType.annual) return '/ year';
    return '';
  }

  // Purchase subscription using PayStack
  Future<void> _purchaseWithPayStack(SubscriptionPlan plan) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showErrorDialog('Please sign in to subscribe');
      return;
    }

    if (plan.price == null || plan.price == 0) {
      _showErrorDialog('Invalid subscription plan');
      return;
    }

    // Robust email resolution: Apple Sign-In accounts can have a hidden
    // relay email (fine) or no auth email at all (previously crashed here
    // on user.email! and blocked the purchase entirely).
    final paymentEmail = await resolvePaymentEmail();
    if (paymentEmail == null) {
      _showErrorDialog(missingPaymentEmailMessage);
      return;
    }

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final reference = 'aplay_sub_${DateTime.now().millisecondsSinceEpoch}';

    try {
      debugPrint('Processing PayStack subscription payment for plan: ${plan.name}');

      final success = await UnifiedPaymentService.instance.processPayment(
        context: context,
        email: paymentEmail,
        amount: plan.price!,
        reference: reference,
        metadata: {
          'type': 'subscription',
          'plan_id': plan.id,
          'plan_type': plan.planType?.toString(),
          'user_id': user.id,
        },
        onSuccess: () async {
          debugPrint('PayStack payment successful, creating subscription...');
          try {
            await _createPayStackSubscription(plan, reference);

            // Same reason as the Apple IAP success path: refresh the
            // shared subscription-status providers so the home app bar and
            // other screens pick up the new subscription immediately.
            ref.invalidate(hasActiveSubscriptionProvider);
            ref.invalidate(activeSubscriptionProvider);

            // Navigate to success screen
            if (mounted) {
              setState(() {
                _isPurchasing = false;
              });

              final endDate = _calculateEndDate(plan);

              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SubscriptionSuccessScreen(
                    planName: plan.name,
                    transactionId: reference,
                    expiryDate: endDate,
                  ),
                ),
              );
            }
          } catch (e) {
            debugPrint('Failed to create subscription: $e');
            // Show failure screen even though payment succeeded
            if (mounted) {
              setState(() {
                _isPurchasing = false;
              });

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubscriptionFailureScreen(
                    errorMessage: 'Payment succeeded but failed to activate subscription. Please contact support with transaction ID: $reference',
                    planName: plan.name,
                    onRetry: () {
                      Navigator.of(context).pop();
                      _purchaseWithPayStack(plan);
                    },
                  ),
                ),
              );
            }
          }
        },
        onError: (error) {
          debugPrint('PayStack payment failed: $error');
          if (mounted) {
            setState(() {
              _isPurchasing = false;
            });

            // Navigate to failure screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SubscriptionFailureScreen(
                  errorMessage: error,
                  planName: plan.name,
                  onRetry: () {
                    Navigator.of(context).pop();
                    _purchaseWithPayStack(plan);
                  },
                ),
              ),
            );
          }
        },
      );

      // Handle case where payment was cancelled
      if (!success && mounted) {
        setState(() {
          _isPurchasing = false;
        });

        // User cancelled payment - just reset state, don't show error
        debugPrint('Payment was cancelled by user');
      }
    } catch (e) {
      debugPrint('PayStack subscription error: $e');
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });

        // Navigate to failure screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SubscriptionFailureScreen(
              errorMessage: 'An unexpected error occurred: ${e.toString()}',
              planName: plan.name,
              onRetry: () {
                Navigator.of(context).pop();
                _purchaseWithPayStack(plan);
              },
            ),
          ),
        );
      }
    }
  }

  // S2: fulfillment happens server-side now. This re-verifies the reference
  // with Paystack itself and creates the subscription strictly from what
  // paystack/initialize computed and recorded for it - the client can no
  // longer insert a subscription of its own choosing after a payment.
  Future<void> _createPayStackSubscription(SubscriptionPlan plan, String transactionId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'confirm-purchase',
        body: {'reference': transactionId},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw Exception(data is Map ? (data['error'] ?? 'Failed to confirm subscription') : 'Failed to confirm subscription');
      }
      debugPrint('Subscription confirmed successfully');
    } catch (e) {
      debugPrint('Failed to confirm subscription: $e');
      throw Exception('Failed to activate subscription: $e');
    }
  }

  DateTime _calculateEndDate(SubscriptionPlan plan) {
    final now = DateTime.now();
    if (plan.durationDays != null) {
      return now.add(Duration(days: plan.durationDays!));
    }

    // Fallback based on plan type
    switch (plan.planType) {
      case SubscriptionPlanType.trial:
        return now.add(const Duration(days: 3));
      case SubscriptionPlanType.weekly:
        return now.add(const Duration(days: 7));
      case SubscriptionPlanType.monthly:
        return now.add(const Duration(days: 30));
      case SubscriptionPlanType.quarterly:
        return now.add(const Duration(days: 90));
      case SubscriptionPlanType.annual:
        return now.add(const Duration(days: 365));
      default:
        return now.add(const Duration(days: 30));
    }
  }


  void _showErrorDialog(String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionFailureScreen(
          errorMessage: message,
          planName: null,
          onRetry: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _openSubscriptionManagement() async {
    // iOS Settings URL for managing subscriptions
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open subscription management. Please go to iOS Settings > Your Name > Subscriptions.'),
          ),
        );
      }
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You\'ll still have access to premium features until the end of your current billing period.\n\n'
          'To cancel, you need to manage your subscription in iOS Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSubscriptionManagement();
            },
            child: const Text('Manage in Settings'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeOptions() {
    final currentTier = _activeSubscription?['subscription_tier'] ?? 'Gold';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade/Change Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: $currentTier Tier'),
            const SizedBox(height: 16),
            const Text(
              'To change or upgrade your subscription, you need to manage it through iOS Settings.\n\n'
              'Steps:\n'
              '1. Go to iOS Settings\n'
              '2. Tap your name at the top\n'
              '3. Tap Subscriptions\n'
              '4. Select this app\n'
              '5. Choose a different plan',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSubscriptionManagement();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadySubscribedView() {
    final tier = _activeSubscription?['subscription_tier'] ?? 'Premium';
    final planId = _activeSubscription?['plan_id'] ?? '';
    final expiresAtStr = _activeSubscription?['subscription_expires_at'] as String?;

    DateTime? expiresAt;
    int? daysRemaining;

    if (expiresAtStr != null) {
      expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null) {
        daysRemaining = expiresAt.difference(DateTime.now()).inDays;
      }
    }

    Color tierColor;
    IconData tierIcon;

    switch (tier) {
      case 'Black':
        tierColor = Colors.black;
        tierIcon = Icons.workspace_premium;
        break;
      case 'Platinum':
        tierColor = const Color(0xFFE5E4E2);
        tierIcon = Icons.diamond;
        break;
      case 'Gold':
        tierColor = const Color(0xFFFFD700);
        tierIcon = Icons.star;
        break;
      default:
        tierColor = Colors.blue;
        tierIcon = Icons.check_circle;
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Tier Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tierIcon,
              size: 60,
              color: tierColor,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        const Text(
          'Active Subscription',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Tier Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: tierColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$tier Tier',
              style: TextStyle(
                color: tier == 'Platinum' ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Subscription Details Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Type
                _buildDetailRow(
                  Icons.card_membership,
                  'Plan',
                  _getPlanName(planId),
                ),
                const Divider(height: 24),

                // Days Remaining
                if (daysRemaining != null) ...[
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Time Remaining',
                    daysRemaining > 0
                        ? '$daysRemaining days'
                        : 'Expires today',
                  ),
                  const Divider(height: 24),
                ],

                // Renewal Date
                if (expiresAt != null) ...[
                  _buildDetailRow(
                    Icons.event_repeat,
                    'Renews On',
                    '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Management Actions
        const Text(
          'Manage Subscription',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Upgrade/Change Plan Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showUpgradeOptions,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.blue),
            ),
            icon: const Icon(Icons.upgrade),
            label: const Text(
              'Change Plan',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Manage in Settings Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openSubscriptionManagement,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.settings),
            label: const Text(
              'Manage in iOS Settings',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Subscription Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showCancelConfirmation,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            icon: const Icon(Icons.cancel),
            label: const Text(
              'Cancel Subscription',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info Message
        Card(
          color: Colors.blue.withValues(alpha: 0.1),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your subscription is managed through the App Store. Changes made in iOS Settings will be reflected here.',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Back Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getPlanName(String planId) {
    switch (planId) {
      case '7day':
        return 'Weekly Plan';
      case '1month':
        return 'Monthly Plan';
      case '3SUB':
        return 'Quarterly Plan';
      case '365day':
        return 'Annual Plan';
      default:
        return 'Premium Plan';
    }
  }

  Future<void> _restorePurchases() async {
    debugPrint('SubscriptionScreen: Restore Purchases tapped');
    setState(() => _isLoading = true);

    await _iapService.restorePurchases();
    // Restored purchases arrive asynchronously via the purchase stream and are
    // synced to the database by IAPService; re-check status shortly after.
    await Future.delayed(const Duration(seconds: 2));
    await _iapService.syncDatabaseWithStoreKit();

    final hasActive = await _syncService.hasActiveSubscription();
    final activeSub = await _syncService.getActiveSubscription();

    ref.invalidate(hasActiveSubscriptionProvider);
    ref.invalidate(activeSubscriptionProvider);

    if (mounted) {
      setState(() {
        _hasActiveSubscription = hasActive;
        _activeSubscription = activeSub;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasActive
              ? 'Purchases restored successfully'
              : 'No previous purchases found to restore'),
          backgroundColor: hasActive ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _refreshSubscriptionStatus() async {
    setState(() => _isLoading = true);

    debugPrint('SubscriptionScreen: Manual refresh triggered');
    await _iapService.syncDatabaseWithStoreKit();

    final hasActive = await _syncService.hasActiveSubscription();
    final activeSub = await _syncService.getActiveSubscription();

    ref.invalidate(hasActiveSubscriptionProvider);
    ref.invalidate(activeSubscriptionProvider);

    setState(() {
      _hasActiveSubscription = hasActive;
      _activeSubscription = activeSub;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasActive
            ? 'Subscription status refreshed'
            : 'No active subscription found'),
          backgroundColor: hasActive ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe to Premium'),
        centerTitle: true,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshSubscriptionStatus,
            tooltip: 'Refresh subscription status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    // PRIORITY 1: If user already has active subscription, show that
    debugPrint('SubscriptionScreen: _buildBody() - _hasActiveSubscription = $_hasActiveSubscription');
    if (_hasActiveSubscription) {
      debugPrint('SubscriptionScreen: Rendering ALREADY SUBSCRIBED view with management buttons');
      return _buildAlreadySubscribedView();
    }

    // PRIORITY 2: If no IAP products, fall back to PayStack - but NEVER on
    // iOS. Apple Guideline 3.1.1 requires digital subscriptions to go
    // through In-App Purchase exclusively on iOS; offering Paystack there
    // (even only as a fallback when StoreKit briefly fails to load
    // products) is a real rejection/removal risk. iOS instead gets a
    // retry-only error state - no alternate payment path.
    final isIOS = !kIsWeb && Platform.isIOS;
    if (_products.isEmpty) {
      if (isIOS) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load subscription plans',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your connection and try again.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _isLoading = true;
                        _initialize();
                      }),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      return FutureBuilder<List<SubscriptionPlan>>(
        future: _loadPayStackPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            // Only show error if both IAP and PayStack fail
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load subscription plans',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your connection and try again.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isLoading = true;
                          _initialize();
                        }),
                        child: const Text('Retry'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Show PayStack subscriptions
          return _buildPayStackPlansUI(snapshot.data!);
        },
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get access to premium features',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Success message
            if (_successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product list
            ..._products.map((product) => _buildProductCard(product)),

            const SizedBox(height: 24),

            // Terms
            const Text(
              'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Restore Purchases - required by App Store Review Guideline 3.1.2.
            // Restore only ever runs here, on explicit user tap.
            Center(
              child: TextButton(
                onPressed: _isPurchasing ? null : _restorePurchases,
                child: const Text('Restore Purchases'),
              ),
            ),
          ],
        ),

        // Loading overlay
        if (_isPurchasing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing purchase...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    final isPopular = product.id == '1month';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Card(
            elevation: isPopular ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPopular
                  ? const BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: _isPurchasing ? null : () => _purchaseProduct(product),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title.split('(').first.trim(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      children: [
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPeriodText(product.id),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPurchasing ? null : () => _purchaseProduct(product),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isPopular ? Colors.blue : null,
                        ),
                        child: const Text(
                          'Subscribe Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPeriodText(String productId) {
    switch (productId) {
      case '7day':
        return '/ week';
      case '1month':
        return '/ month';
      case '3SUB':
        return '/ 3 months';
      case '365day':
        return '/ year';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    // Clear callbacks
    _iapService.onPurchaseSuccess = null;
    _iapService.onPurchaseError = null;
    _iapService.onPurchaseCancelled = null;
    super.dispose();
  }
}
