import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../provider/subscription_provider.dart';
import '../model/subscription_model.dart';
import '../widgets/paystack_webview.dart';
import '../service/platform_subscription_service.dart';
import '../service/apple_iap_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  bool _isProcessingPayment = false;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  late PlatformSubscriptionService _platformService;
  Timer? _purchaseTimeout;

  @override
  void initState() {
    super.initState();
    _platformService = PlatformSubscriptionService();
    _initializePlatformService();
  }

  Future<void> _initializePlatformService() async {
    await _platformService.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _purchaseTimeout?.cancel();
    // Don't dispose platform service as it's a singleton
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final activeSubscriptionAsync = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Premium Plans',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: Platform.isIOS ? [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white),
            onPressed: _restorePurchases,
            tooltip: 'Restore Purchases',
          ),
        ] : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subscriptionPlansProvider);
          ref.invalidate(activeSubscriptionProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the perfect plan for your entertainment needs',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: activeSubscriptionAsync.when(
                data: (subscription) {
                  if (subscription != null) {
                    return _buildActiveSubscriptionCard(subscription);
                  } else {
                    return const SizedBox(height: 24);
                  }
                },
                loading: () => const ActiveSubscriptionShimmer(),
                error: (error, stack) => const SizedBox(height: 24),
              ),
            ),
            SliverToBoxAdapter(
              child: plansAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Text(
                          'No plans available',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 620,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            return _buildPlanCard(plans[index], index == _currentPage);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          plans.length,
                          (index) => _buildPageIndicator(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
                loading: () => SizedBox(
                  height: 620,
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: PageController(viewportFraction: 0.85),
                    itemCount: 3,
                    itemBuilder: (context, index) => const SubscriptionPlanShimmer(),
                  ),
                ),
                error: (error, stack) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.info_circle, color: AppTheme.primary, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load plans',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(subscriptionPlansProvider),
                            icon: const Icon(Iconsax.refresh),
                            label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4707), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.crown_1, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Active Plan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            planName,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Valid until $endDate',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency ${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _showCancelDialog(subscription.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel Plan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isActive) {
    final hasActiveSubscription = ref.watch(activeSubscriptionProvider).valueOrNull != null;
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

    final isPopular = plan.name.toLowerCase().contains('gold') ||
                      plan.name.toLowerCase().contains('premium');

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isActive ? AppTheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.05), Colors.transparent],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
                if (isPopular)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primary, Color(0xFFFF6B35)]),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.star_1, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'POPULAR',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isPopular ? 28 : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
                            ),
                            child: Icon(_getPlanIcon(plan.name), color: AppTheme.primary, size: 28),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
                            ),
                            child: Text(
                              '${plan.durationDays} Days',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        plan.name,
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (plan.description != null)
                        Text(
                          plan.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: isPopular ? 24 : 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.currency,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _getPlanPrice(plan).toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_getPlanPrice(plan) % 1 != 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '.${(_getPlanPrice(plan) % 1 * 100).toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isPopular ? 20 : 24),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'WHAT\'S INCLUDED',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...featuresList.take(3).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.tick_circle5, color: AppTheme.primary, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: hasActiveSubscription ? null : () => _handleSubscription(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppTheme.textMuted.withOpacity(0.2),
                            disabledForegroundColor: AppTheme.textMuted,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isProcessingPayment
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : Text(
                                  hasActiveSubscription ? 'Already Subscribed' : 'Get Started',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPlanIcon(String planName) {
    final name = planName.toLowerCase();
    if (name.contains('bronze')) return Iconsax.medal;
    if (name.contains('silver')) return Iconsax.medal_star;
    if (name.contains('gold')) return Iconsax.crown;
    if (name.contains('platinum')) return Iconsax.crown_1;
    return Iconsax.award;
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

  void _showCancelDialog(String subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Subscription', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features immediately.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Keep Plan', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelSubscription(subscriptionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Yes, Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
          SnackBar(
            content: Text('Subscription cancelled successfully', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel subscription: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubscription(SubscriptionPlan plan) async {
    try {
      setState(() => _isProcessingPayment = true);

      // Debug logging
      debugPrint('=== SUBSCRIPTION FLOW DEBUG ===');
      debugPrint('Platform.isIOS: ${Platform.isIOS}');
      debugPrint('shouldUseNativeIAP: ${_platformService.shouldUseNativeIAP()}');
      debugPrint('Apple IAP Service available: ${_platformService.appleIAPService != null}');

      // Check if we should use Apple IAP on iOS
      if (Platform.isIOS && _platformService.shouldUseNativeIAP()) {
        debugPrint('Using Apple IAP for subscription: ${plan.id}');
        await _handleAppleIAPPurchase(plan);
        return;
      }

      debugPrint('Using Paystack for subscription: ${plan.id}');

      final hasAppliedReferral = await ref.read(paymentProvider.notifier).hasAppliedReferralCode();
      
      if (!hasAppliedReferral) {
        final shouldProceed = await _showReferralCodeDialog();
        if (!shouldProceed) {
          setState(() => _isProcessingPayment = false);
          return;
        }
      }

      final email = ref.read(subscriptionServiceProvider).getUserEmail() ?? 'user@example.com';
      final paymentData = await ref
          .read(paymentProvider.notifier)
          .initializePayment(email, _getPlanPrice(plan), plan.id);

      if (!mounted) return;

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
            onSuccess: () => Navigator.of(context).pop(true),
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error, style: GoogleFonts.poppins()), backgroundColor: Colors.red),
              );
              Navigator.of(context).pop(false);
            },
          ),
        ),
      );

      setState(() => _isProcessingPayment = false);

      if (result == true) {
        await _verifyAndCreateSubscription(plan.id, reference);
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize payment: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
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
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Referral Code', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do you have a referral code? Enter it below to earn bonus points!',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referralController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Referral Code (Optional)',
                    labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary),
                    hintText: 'Enter referral code',
                    hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                if (isApplying) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text('Applying referral code...', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isApplying ? null : () => Navigator.of(context).pop(true),
              child: Text('Skip', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: isApplying ? null : () async {
                final code = referralController.text.trim();
                if (code.isEmpty) {
                  Navigator.of(context).pop(true);
                  return;
                }

                setState(() => isApplying = true);

                try {
                  await ref.read(paymentProvider.notifier).applyReferralCode(code);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Referral code applied successfully!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  setState(() => isApplying = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Apply & Continue', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  Future<void> _handleAppleIAPPurchase(SubscriptionPlan plan) async {
    try {
      // Set up callbacks for this specific purchase
       _platformService.appleIAPService?.onPurchaseSuccess = (planId, transactionId, receiptData) async {
        // Clear timeout and stop processing immediately
        _purchaseTimeout?.cancel();
        if (mounted) {
          setState(() => _isProcessingPayment = false);
        }
        try {
          // Handle the backend verification and subscription creation
          await _platformService.handleSuccessfulPurchase(planId, transactionId, 'apple_iap', receiptData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Subscription activated successfully!', style: GoogleFonts.poppins()),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh subscription data
            ref.invalidate(activeSubscriptionProvider);
            ref.invalidate(subscriptionPlansProvider);
          }
        } catch (e) {
          debugPrint('Backend verification failed: $e');
          // Already stopped processing above; just notify user
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Purchase completed but verification failed: $e', style: GoogleFonts.poppins()),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      };

      _platformService.appleIAPService?.onPurchaseError = (AppleIAPError error) {
        _purchaseTimeout?.cancel();
        setState(() => _isProcessingPayment = false);
        if (mounted) {
          Color snackBarColor;
          
          switch (error.type) {
            case AppleIAPErrorType.userCancelled:
              snackBarColor = Colors.orange;
              break;
            case AppleIAPErrorType.networkError:
            case AppleIAPErrorType.storeNotAvailable:
              snackBarColor = Colors.red;
              break;
            default:
              snackBarColor = Colors.red;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.userFriendlyMessage ?? 'Purchase failed', style: GoogleFonts.poppins()),
              backgroundColor: snackBarColor,
            ),
          );
        }
      };

      _platformService.appleIAPService?.onPurchaseCancelled = () {
        _purchaseTimeout?.cancel();
        setState(() => _isProcessingPayment = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase cancelled', style: GoogleFonts.poppins()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      };

      // Check if IAP is available
      final isAvailable = await _platformService.isInAppPurchaseAvailable();
      if (!isAvailable) {
        throw Exception('In-App Purchase is not available on this device');
      }

      // Initiate the purchase
      // Start a safety timeout so the UI won't stay stuck in processing
      _purchaseTimeout?.cancel();
      _purchaseTimeout = Timer(const Duration(seconds: 30), () {
        if (!mounted) return;
        if (_isProcessingPayment) {
          setState(() => _isProcessingPayment = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase is taking longer than expected. We\'ll finalize in the background.', style: GoogleFonts.poppins()),
              backgroundColor: Colors.orange,
            ),
          );
          // Attempt to refresh subscription status
          ref.invalidate(activeSubscriptionProvider);
        }
      });
      final success = await _platformService.purchaseSubscription(plan);
      if (!success) {
        throw Exception('Failed to initiate purchase');
      }
    } catch (e) {
      _purchaseTimeout?.cancel();
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple IAP Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
   }

   Future<void> _restorePurchases() async {
     if (!Platform.isIOS) return;
     
     try {
       // Show loading indicator
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Row(
               children: [
                 SizedBox(
                   width: 20,
                   height: 20,
                   child: CircularProgressIndicator(
                     strokeWidth: 2,
                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                   ),
                 ),
                 SizedBox(width: 16),
                 Text('Restoring purchases...', style: GoogleFonts.poppins()),
               ],
             ),
             backgroundColor: Colors.blue,
             duration: Duration(seconds: 30), // Long duration for restore process
           ),
         );
       }

       final restoredSubscriptions = await _platformService.restorePurchases();
       
       if (mounted) {
         // Clear any existing snackbars
         ScaffoldMessenger.of(context).clearSnackBars();
         
         if (restoredSubscriptions.isNotEmpty) {
           final activeSubscriptions = restoredSubscriptions.where((s) => s.status == 'active').length;
           final message = activeSubscriptions > 0 
               ? 'Successfully restored $activeSubscriptions active subscription${activeSubscriptions == 1 ? '' : 's'}'
               : 'Found ${restoredSubscriptions.length} previous subscription${restoredSubscriptions.length == 1 ? '' : 's'}, but none are currently active';
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(message, style: GoogleFonts.poppins()),
               backgroundColor: activeSubscriptions > 0 ? Colors.green : Colors.orange,
               duration: Duration(seconds: 4),
             ),
           );
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('No previous purchases found to restore', style: GoogleFonts.poppins()),
               backgroundColor: Colors.orange,
               duration: Duration(seconds: 3),
             ),
           );
         }
         
         // Refresh subscription data
         ref.invalidate(activeSubscriptionProvider);
         ref.invalidate(subscriptionPlansProvider);
       }
     } catch (e) {
       if (mounted) {
         // Clear any existing snackbars
         ScaffoldMessenger.of(context).clearSnackBars();
         
         String errorMessage = 'Failed to restore purchases';
         if (e.toString().contains('not supported')) {
           errorMessage = 'Restore purchases not supported on this platform';
         } else if (e.toString().contains('timed out')) {
           errorMessage = 'Restore purchases timed out. Please try again.';
         } else if (e.toString().contains('not available')) {
           errorMessage = 'App Store not available. Please check your connection.';
         }
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage, style: GoogleFonts.poppins()),
             backgroundColor: Colors.red,
             duration: Duration(seconds: 4),
             action: SnackBarAction(
               label: 'Retry',
               textColor: Colors.white,
               onPressed: () => _restorePurchases(),
             ),
           ),
         );
       }
     }
   }
 
    Future<void> _verifyAndCreateSubscription(String planId, String reference) async {
    try {
      final verification = await ref.read(paymentProvider.notifier).verifyPayment(reference);
      
      if (verification.status) {
        await ref.read(subscriptionServiceProvider).createSubscription(planId, reference);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription activated successfully!', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(activeSubscriptionProvider);
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify payment: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
