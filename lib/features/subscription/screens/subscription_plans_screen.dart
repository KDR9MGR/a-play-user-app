import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';
import 'package:a_play/core/widgets/sign_in_dialog.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import '../provider/subscription_provider.dart';
import '../provider/backend_subscription_provider.dart';
import '../model/subscription_model.dart';
import '../widgets/paystack_webview.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../service/platform_subscription_service.dart';
import '../service/apple_iap_service.dart';
import '../utils/subscription_utils.dart';
import 'subscription_success_screen.dart';

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
    _initializePlatformService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _purchaseTimeout?.cancel();
    super.dispose();
  }

  Future<void> _initializePlatformService() async {
    _platformService = PlatformSubscriptionService();
    await _platformService.initialize();
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
                        height: MediaQuery.of(context).size.height * 0.65,
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
                      const SizedBox(height: 24),
                      // Apple App Store Guideline 3.1.2: Display Terms of Use for subscriptions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final url = Uri.parse('https://www.aplayworld.com/terms-and-conditions');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Text(
                                'Terms & Conditions',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final url = Uri.parse('https://www.aplayworld.com/privacy-policy');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Text(
                                'Privacy Policy',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
        color: isActive ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.3),
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

    // Check days until expiry
    final daysUntilExpiry = subscription.endDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 7 && daysUntilExpiry > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpiringSoon
              ? [const Color(0xFFFF9800), const Color(0xFFFFC107)]
              : [const Color(0xFFFF4707), const Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.crown_15, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Plan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isExpiringSoon)
                        Text(
                          'Expires in $daysUntilExpiry ${daysUntilExpiry == 1 ? 'day' : 'days'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.verify5,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 12),

          // Subscription info rows
          _buildSubscriptionInfoRow(
            icon: Iconsax.calendar_1,
            label: 'Valid until',
            value: endDate,
          ),
          const SizedBox(height: 8),
          _buildSubscriptionInfoRow(
            icon: Iconsax.wallet_3,
            label: 'Amount paid',
            value: '$currency ${amount.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to subscription history or details
                    Navigator.of(context).pushNamed('/subscription-history');
                  },
                  icon: const Icon(Iconsax.document_text, size: 18),
                  label: Text(
                    'View History',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCancelDialog(subscription.id),
                  icon: const Icon(Iconsax.close_circle, size: 18),
                  label: Text(
                    'Cancel Plan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
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
    final planPrice = _getPlanPrice(plan);
    final isTrialPlan =
        plan.planType == SubscriptionPlanType.trial ||
        plan.name.toLowerCase().contains('trial');
    final isFreePlan =
        planPrice <= 0 &&
        !isTrialPlan &&
        plan.name.toLowerCase().contains('free');

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
              color: isActive ? AppTheme.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15))]
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
                        colors: [AppTheme.primary.withValues(alpha: 0.05), Colors.transparent],
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
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 32 : 24),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      SizedBox(height: isPopular ? 40 : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Icon(_getPlanIcon(plan.name), color: AppTheme.primary, size: 28),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Text(
                              plan.durationDays != null && plan.durationDays! > 0
                                  ? '${plan.durationDays} Days'
                                  : 'Membership',
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
                      const SizedBox(height: 32),
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
                                  color: Colors.white.withValues(alpha: 0.7),
                                  height: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'WHAT\'S INCLUDED',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...featuresList.take(3).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
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
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (hasActiveSubscription || isFreePlan)
                              ? null
                              : () => _handleSubscription(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppTheme.textMuted.withValues(alpha: 0.2),
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
                                  hasActiveSubscription
                                      ? 'Already Subscribed'
                                      : (isFreePlan
                                          ? 'Current Plan'
                                          : (isTrialPlan ? 'Start Trial' : 'Get Started')),
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
      // CRITICAL: Check if user is authenticated before allowing subscription
      // This prevents crashes and shows dialog for guest users
      final user = ref.read(authStateProvider).value;

      if (user == null) {
        // Show sign-in dialog for guest users
        final signedIn = await SignInDialog.showBottomSheet(
          context,
          featureName: 'Premium Subscription',
          message: 'Sign in to subscribe to ${plan.name} and unlock exclusive features',
        );

        if (!signedIn) {
          return; // User dismissed dialog or didn't sign in
        }

        // Verify user actually signed in
        final userAfter = ref.read(authStateProvider).value;
        if (userAfter == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please sign in to continue', style: GoogleFonts.poppins()),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return; // User didn't complete sign-in
        }
      }

      setState(() => _isProcessingPayment = true);
      final planPrice = _getPlanPrice(plan);
      final isTrialPlan =
          plan.planType == SubscriptionPlanType.trial ||
          plan.name.toLowerCase().contains('trial');

      if (planPrice <= 0) {
        try {
          if (isTrialPlan) {
            await ref.read(subscriptionServiceProvider).startFreeTrial();
            ref.invalidate(activeSubscriptionProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trial activated successfully!', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Free plan is already available.', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.blueGrey,
                ),
              );
            }
          }
        } finally {
          if (mounted) {
            setState(() => _isProcessingPayment = false);
          }
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('=== SUBSCRIPTION PAYMENT METHOD SELECTION ===');
        debugPrint('Platform.isIOS: ${Platform.isIOS}');
        debugPrint('shouldUseNativeIAP: ${_platformService.shouldUseNativeIAP()}');
        debugPrint('appleIAPService available: ${_platformService.appleIAPService != null}');
      }

      // iOS MUST use Apple IAP only (Apple App Store guideline 3.1.1)
      // PayStack is NOT allowed for digital subscriptions on iOS
      if (Platform.isIOS) {
        if (kDebugMode) {
          debugPrint('iOS detected - Using Apple IAP ONLY (App Store requirement)');
        }
        await _handleAppleIAPPurchase(plan);
      } else {
        // Android and other platforms can use PayStack
        final hasAppliedReferral = await ref.read(paymentProvider.notifier).hasAppliedReferralCode();

        if (!hasAppliedReferral) {
          final shouldProceed = await _showReferralCodeDialog();
          if (!shouldProceed) {
            setState(() => _isProcessingPayment = false);
            return;
          }
        }

        if (kDebugMode) {
          debugPrint('Non-iOS platform - Using Paystack for subscription');
        }
        await _handlePaystackPurchase(plan);
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

  Future<void> _handleAppleIAPPurchase(SubscriptionPlan plan) async {
    try {
      if (kDebugMode) {
        debugPrint('Setting up Apple IAP callbacks...');
      }
      
      // Debug: Print PurchaseManager status
      if (_platformService.appleIAPService != null) {
        final debugInfo = _platformService.appleIAPService!.getDebugInfo();
        if (kDebugMode) {
          debugPrint('PurchaseManager Debug Info: $debugInfo');
        }
      }
      
      // Set up callbacks for purchase success, error, and cancellation
      if (_platformService.appleIAPService != null) {
        _platformService.appleIAPService!.onPurchaseSuccess = (planId, transactionId, receiptData) async {
          if (kDebugMode) {
            debugPrint('Apple IAP purchase successful: $planId, $transactionId');
          }
          // Stop timeout and immediately stop processing indicator
          _purchaseTimeout?.cancel();
          if (mounted) {
            setState(() => _isProcessingPayment = false);
          }
          
          try {
            // Handle the backend verification and subscription creation
            await _platformService.handleSuccessfulPurchase(planId, transactionId, 'apple_iap', receiptData);

            // Refresh subscription data from backend
            await SubscriptionUtils.refreshPremiumStatusAndWait(ref);

            // Get updated subscription status
            final subscriptionStatus = await ref.read(backendSubscriptionStatusProvider.future);

            if (mounted) {
              // Navigate to success screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SubscriptionSuccessScreen(
                    planName: plan.name,
                    transactionId: transactionId,
                    expiryDate: subscriptionStatus.expiry,
                  ),
                ),
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Backend verification failed: $e');
            }

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

        _platformService.appleIAPService!.onPurchaseError = (error) {
          if (kDebugMode) {
            debugPrint('Apple IAP purchase error: ${error.message}');
          }
          _purchaseTimeout?.cancel();
          setState(() => _isProcessingPayment = false);
          
          if (mounted) {
            Color snackBarColor = Colors.red;
            
            // Use different colors based on error type
            switch (error.type) {
              case AppleIAPErrorType.userCancelled:
                snackBarColor = Colors.orange;
                break;
              case AppleIAPErrorType.networkError:
                snackBarColor = Colors.blue;
                break;
              case AppleIAPErrorType.storeNotAvailable:
                snackBarColor = Colors.grey;
                break;
              default:
                snackBarColor = Colors.red;
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.displayMessage, style: GoogleFonts.poppins()),
                backgroundColor: snackBarColor,
                duration: const Duration(seconds: 4),
                action: error.type == AppleIAPErrorType.networkError || 
                        error.type == AppleIAPErrorType.storeNotAvailable
                    ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () => _handleAppleIAPPurchase(plan),
                      )
                    : null,
              ),
            );
          }
        };

        _platformService.appleIAPService!.onPurchaseCancelled = () {
          print('Apple IAP purchase cancelled');
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
      }

      // Check if IAP is available
      final isAvailable = await _platformService.isInAppPurchaseAvailable();
      if (!isAvailable) {
        throw Exception('In-app purchases are not available on this device');
      }

      print('Initiating Apple IAP purchase for plan: ${plan.id}');
      // Initiate the purchase
      // Start safety timeout to avoid stuck processing state
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
          ref.invalidate(activeSubscriptionProvider);
        }
      });
      await _platformService.purchaseSubscription(plan);
    } catch (e) {
      print('Apple IAP purchase error: $e');
      _purchaseTimeout?.cancel();
      setState(() => _isProcessingPayment = false);
      rethrow;
    }
  }

  Future<void> _handlePaystackPurchase(SubscriptionPlan plan) async {
    try {
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
      rethrow;
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
                      borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3)),
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
