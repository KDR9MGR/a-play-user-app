import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/subscription_provider.dart';
import '../model/subscription_model.dart';
import '../widgets/paystack_webview.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final activeSubscriptionAsync = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subscriptionPlansProvider);
          ref.invalidate(activeSubscriptionProvider);
        },
        child: Column(
          children: [
            // Active subscription section
            activeSubscriptionAsync.when(
              data: (subscription) {
                if (subscription != null) {
                  return _buildActiveSubscriptionCard(subscription);
                } else {
                  return const SizedBox.shrink();
                }
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (error, stack) {
                if (error.toString().contains('not initialized') || error.toString().contains('not ready')) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Loading subscription data...'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(activeSubscriptionProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Error loading subscription: $error'),
                );
              },
            ),
            
            // Available plans section
            Expanded(
              child: plansAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return const Center(
                      child: Text('No subscription plans available.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) => _buildPlanCard(plans[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  if (error.toString().contains('not initialized') || error.toString().contains('not ready')) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Loading subscription plans...'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(subscriptionPlansProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading plans: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(subscriptionPlansProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(UserSubscription subscription) {
    final formatter = DateFormat('MMM dd, yyyy');
    final endDate = formatter.format(subscription.endDate);
    final planName = subscription.subscriptionType ?? 'Premium Plan';
    final currency = subscription.currency ?? 'GHS';
    final amount = subscription.amount ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Active Subscription',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            planName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Valid until $endDate',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currency ${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showCancelDialog(subscription.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple.shade800,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final hasActiveSubscription = ref.watch(activeSubscriptionProvider).valueOrNull != null;
    
    // Extract features from the plan
    final features = plan.features ?? {};
    final featuresList = features.entries
        .map((e) => e.value is bool && e.value
            ? e.key.replaceAll('_', ' ').toUpperCase()
            : e.value is String
                ? '${e.key.replaceAll('_', ' ').toUpperCase()}: ${e.value}'
                : null)
        .where((e) => e != null)
        .cast<String>()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${plan.durationDays} days',
                    style: TextStyle(
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (plan.description != null) ...[
              const SizedBox(height: 8),
              Text(
                plan.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            ...featuresList.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${plan.currency} ${_getPlanPrice(plan).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton(
                  onPressed: hasActiveSubscription
                      ? null // Disable button if user already has an active subscription
                      : () => _handleSubscription(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelSubscription(subscriptionId);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    try {
      await ref.read(activeSubscriptionProvider.notifier).cancelSubscription(subscriptionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel subscription: $e')),
        );
      }
    }
  }

  double _getPlanPrice(SubscriptionPlan plan) {
    if (plan.price != null) {
      return plan.price!;
    }
    if (plan.priceMonthly != null) {
      return plan.priceMonthly!;
    }
    if (plan.priceYearly != null) {
      return plan.priceYearly!;
    }
    return 0;
  }

  Future<void> _handleSubscription(SubscriptionPlan plan) async {
    try {
      setState(() {
        _isProcessingPayment = true;
      });

      // Check if user has already applied a referral code
      final hasAppliedReferral = await ref.read(paymentProvider.notifier).hasAppliedReferralCode();
      
      if (!hasAppliedReferral) {
        // Show referral code dialog
        final shouldProceed = await _showReferralCodeDialog();
        if (!shouldProceed) {
          setState(() {
            _isProcessingPayment = false;
          });
          return;
        }
      }

      // Get current user email
      final email = ref.read(subscriptionServiceProvider).getUserEmail() ?? 'user@example.com';

      // Initialize payment with Paystack
      final paymentData = await ref.read(paymentProvider.notifier).initializePayment(
            email,
            _getPlanPrice(plan),
            plan.id,
          );

      if (!mounted) return;

      // Show Paystack WebView
      final reference = paymentData['reference'] as String;
      final authUrl = paymentData['authorization_url'] as String;
      
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: PaystackWebView(
            authorizationUrl: authUrl,
            reference: reference,
            secretKey: ref.read(subscriptionServiceProvider).getPaystackSecretKey(),
            onSuccess: () {
              Navigator.of(context).pop(true);
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              Navigator.of(context).pop(false);
            },
          ),
        ),
      );

      setState(() {
        _isProcessingPayment = false;
      });

      // Handle payment result
      if (result == true) {
        // Verify and create subscription
        await _verifyAndCreateSubscription(plan.id, reference);
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize payment: $e')),
        );
      }
    }
  }

  Future<bool> _showReferralCodeDialog() async {
    final TextEditingController referralController = TextEditingController();
    bool isApplying = false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Referral Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do you have a referral code? Enter it below to earn bonus points!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: referralController,
                decoration: const InputDecoration(
                  labelText: 'Referral Code (Optional)',
                  hintText: 'Enter referral code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              if (isApplying) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Applying referral code...'),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isApplying ? null : () => Navigator.of(context).pop(true),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: isApplying ? null : () async {
                final code = referralController.text.trim();
                if (code.isEmpty) {
                  Navigator.of(context).pop(true);
                  return;
                }

                setState(() {
                  isApplying = true;
                });

                try {
                  await ref.read(paymentProvider.notifier).applyReferralCode(code);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code applied successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  setState(() {
                    isApplying = false;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Apply & Continue'),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  Future<void> _verifyAndCreateSubscription(String planId, String reference) async {
    try {
      // Verify payment
      final verification = await ref.read(paymentProvider.notifier).verifyPayment(reference);
      
      if (verification.status) {
        // Create subscription
        await ref.read(subscriptionServiceProvider).createSubscription(planId, reference);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription activated successfully!')),
          );
          // Refresh subscription status
          ref.invalidate(activeSubscriptionProvider);
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify payment: $e')),
        );
      }
    }
  }
} 
