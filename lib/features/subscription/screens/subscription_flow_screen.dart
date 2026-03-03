import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:a_play/core/theme/app_theme.dart';
import '../provider/subscription_provider.dart';
import '../model/subscription_model.dart';
import '../widgets/paystack_webview.dart';

class SubscriptionFlowScreen extends ConsumerStatefulWidget {
  const SubscriptionFlowScreen({super.key});

  @override
  ConsumerState<SubscriptionFlowScreen> createState() => _SubscriptionFlowScreenState();
}

class _SubscriptionFlowScreenState extends ConsumerState<SubscriptionFlowScreen> {
  bool _isProcessingPayment = false;
  bool _isStartingTrial = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final activeSubscriptionAsync = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: plansAsync.when(
        data: (plans) => _buildContent(plans, activeSubscriptionAsync.valueOrNull),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load subscription plans',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(subscriptionPlansProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<SubscriptionPlan> plans, UserSubscription? activeSubscription) {
    // Separate trial plan from other plans
    final trialPlan = plans.where((p) => p.planType == SubscriptionPlanType.trial).firstOrNull;
    final paidPlans = plans.where((p) => p.planType != SubscriptionPlanType.trial).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          _buildHeroSection(),
          const SizedBox(height: 32),

          // Free trial section (if eligible)
          if (trialPlan != null && activeSubscription == null)
            _buildTrialSection(trialPlan),
          
          if (trialPlan != null && activeSubscription == null)
            const SizedBox(height: 32),

          // Paid plans section
          if (paidPlans.isNotEmpty) ...[
            Text(
              activeSubscription?.isTrial == true 
                ? 'Continue with Premium'
                : 'Premium Plans',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...paidPlans.map((plan) => _buildPlanCard(plan, activeSubscription)),
          ],

          const SizedBox(height: 32),
          _buildBenefitsSection(),

          const SizedBox(height: 24),
          _buildLegalLinksSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.1),
            AppTheme.accentCyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Unlock Premium Features',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Get access to exclusive events, ad-free experience, and premium content',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal & Policies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: const [
            TextButton(
              onPressed: null,
              child: Text('Apple EULA'),
            ),
            TextButton(
              onPressed: null,
              child: Text('Terms & Conditions'),
            ),
            TextButton(
              onPressed: null,
              child: Text('Privacy Policy'),
            ),
            TextButton(
              onPressed: null,
              child: Text('Refund Policy'),
            ),
            TextButton(
              onPressed: null,
              child: Text('FAQ'),
            ),
            TextButton(
              onPressed: null,
              child: Text('Contact'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Auto-renewing subscription. Cancel at least 24 hours before renewal in Settings.',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrialSection(SubscriptionPlan trialPlan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIMITED TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '3-Day Free Trial',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience all premium features completely free',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isStartingTrial ? null : () => _startFreeTrial(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isStartingTrial
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    )
                  : const Text(
                      'Start Free Trial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '• No payment required\n• Cancel anytime\n• All premium features included',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, UserSubscription? activeSubscription) {
    final hasActiveSubscription = activeSubscription != null;
    final formatter = NumberFormat.currency(symbol: 'GH₵', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundMiddle,
        borderRadius: BorderRadius.circular(16),
        border: plan.isPopular
            ? Border.all(color: AppTheme.primary, width: 2)
            : Border.all(color: AppTheme.surfaceLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (plan.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(plan.price),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/${plan.durationDays} days',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (plan.discountPercentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Save ${plan.discountPercentage!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasActiveSubscription ? null : () => _handleSubscription(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isPopular ? AppTheme.primary : AppTheme.surfaceLight,
                foregroundColor: plan.isPopular ? Colors.white : AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      hasActiveSubscription ? 'Current Plan' : 'Subscribe',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    const benefits = [
      {
        'icon': Icons.block,
        'title': 'Ad-Free Experience',
        'description': 'Enjoy uninterrupted browsing without ads',
      },
      {
        'icon': Icons.star,
        'title': 'Exclusive Events',
        'description': 'Access to premium and VIP events',
      },
      {
        'icon': Icons.high_quality,
        'title': 'HD Streaming',
        'description': 'High-quality video and audio streaming',
      },
      {
        'icon': Icons.download,
        'title': 'Offline Download',
        'description': 'Download content for offline viewing',
      },
      {
        'icon': Icons.priority_high,
        'title': 'Priority Booking',
        'description': 'Get first access to event tickets',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Priority Support',
        'description': '24/7 premium customer support',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Benefits',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...benefits.map((benefit) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundMiddle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceLight, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit['description'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _startFreeTrial() async {
    try {
      setState(() {
        _isStartingTrial = true;
      });

      await ref.read(activeSubscriptionProvider.notifier).startFreeTrial();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free trial started! Enjoy premium features for 3 days.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isStartingTrial = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start trial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubscription(SubscriptionPlan plan) async {
    try {
      setState(() {
        _isProcessingPayment = true;
      });

      final planPrice = plan.price ??
          plan.priceMonthly ??
          plan.priceYearly ??
          0.0;

      if (planPrice <= 0) {
        setState(() {
          _isProcessingPayment = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Free plan is already available.'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        }
        return;
      }

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
        planPrice,
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
          backgroundColor: AppTheme.backgroundMiddle,
          title: const Text(
            'Referral Code',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do you have a referral code? Enter it below to earn bonus points!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: referralController,
                style: const TextStyle(color: AppTheme.textPrimary),
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
                    Text(
                      'Applying referral code...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
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
          Navigator.of(context).pop();
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
