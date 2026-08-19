import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:confetti/confetti.dart';
import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/subscription/provider/backend_subscription_provider.dart';

class SubscriptionSuccessScreen extends ConsumerStatefulWidget {
  final String planName;
  final String transactionId;
  final DateTime? expiryDate;

  const SubscriptionSuccessScreen({
    super.key,
    required this.planName,
    required this.transactionId,
    this.expiryDate,
  });

  @override
  ConsumerState<SubscriptionSuccessScreen> createState() =>
      _SubscriptionSuccessScreenState();
}

// Mirrors the productId -> tier mapping in verify-apple-receipt/index.ts and
// confirm-purchase/index.ts (the actual trust boundary that sets the tier) -
// this is display-only, purely to theme the success screen to match what the
// user actually bought instead of a flat generic orange for every tier.
const Map<String, ({String label, Color color})> _tierByProductId = {
  '7day': (label: 'Gold', color: Color(0xFFFFD700)),
  '1month': (label: 'Platinum', color: Color(0xFFE5E4E2)),
  '3SUB': (label: 'Platinum', color: Color(0xFFE5E4E2)),
  '365day': (label: 'Black', color: Color(0xFF2A2A2A)),
};

const Map<String, List<String>> _tierFeatures = {
  'Gold': ['Priority Booking', 'Exclusive Events', 'Special Discounts'],
  'Platinum': ['Priority Booking', 'Exclusive Events', 'VIP Support', 'Special Discounts'],
  'Black': ['Unlimited Access', 'Personal Concierge', 'VIP Support', 'Backstage Passes'],
};

class _SubscriptionSuccessScreenState
    extends ConsumerState<SubscriptionSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    // Initialize confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  ({String label, Color color}) _resolveTier(String? productId) {
    return _tierByProductId[productId] ?? (label: 'Premium', color: AppTheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(backendSubscriptionStatusProvider);
    final tier = _resolveTier(subscriptionStatus.value?.productId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundStart,
        body: Stack(
          children: [
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Color(0xFFFF4707),
                  Color(0xFFFF6B35),
                  Colors.white,
                  Colors.amber,
                  Colors.purple,
                ],
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Success icon with animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [tier.color, tier.color.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tier.color.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Iconsax.crown_15,
                          size: 60,
                          color: tier.label == 'Platinum' ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Success message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome to ${tier.label}!',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: tier.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tier.color.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '${tier.label.toUpperCase()} TIER',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: tier.label == 'Platinum' ? Colors.black87 : tier.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your ${widget.planName} subscription is now active',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Subscription details card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: tier.color.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: subscriptionStatus.when(
                          data: (status) {
                            return Column(
                              children: [
                                _buildDetailRow(
                                  icon: Iconsax.crown_1,
                                  label: 'Tier',
                                  value: tier.label,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Iconsax.tag,
                                  label: 'Plan',
                                  value: widget.planName,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Iconsax.receipt_1,
                                  label: 'Transaction ID',
                                  value: _truncateTransactionId(
                                      widget.transactionId),
                                ),
                                if (status.expiry != null) ...[
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Iconsax.calendar,
                                    label: 'Valid Until',
                                    value: _formatDate(status.expiry!),
                                  ),
                                ],
                                if (status.autoRenewEnabled != null) ...[
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Iconsax.repeat,
                                    label: 'Auto-Renewal',
                                    value: status.autoRenewEnabled!
                                        ? 'Enabled'
                                        : 'Disabled',
                                  ),
                                ],
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          ),
                          error: (_, __) => Column(
                            children: [
                              _buildDetailRow(
                                icon: Iconsax.crown_1,
                                label: 'Tier',
                                value: tier.label,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Iconsax.tag,
                                label: 'Plan',
                                value: widget.planName,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Iconsax.receipt_1,
                                label: 'Transaction ID',
                                value:
                                    _truncateTransactionId(widget.transactionId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Premium features preview
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'You now have access to:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: (_tierFeatures[tier.label] ?? _tierFeatures['Gold']!)
                                .map((f) => _buildFeatureChip(f, tier.color))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _navigateToHome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start Exploring',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Iconsax.arrow_right_3,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Back to Plans',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.tick_circle5,
            size: 16,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateTransactionId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 6)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateToHome() {
    // Pop until we reach the home screen (root route)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
