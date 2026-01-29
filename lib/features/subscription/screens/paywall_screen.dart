import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/theme/app_theme.dart';
import 'package:lottie/lottie.dart';
import '../provider/subscription_provider.dart';
import 'subscription_flow_screen.dart';

class PaywallScreen extends ConsumerWidget {
  final String? featureName;
  final VoidCallback? onSkip;
  final bool showSkipButton;

  const PaywallScreen({
    super.key,
    this.featureName,
    this.onSkip,
    this.showSkipButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubscription = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundStart,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const SizedBox(width: 40), // Spacer for centering
                  Row(
                  children: [
                    SizedBox(width: 50, child: Lottie.asset('assets/lotties/diamond.json')),

                    const Text(
                    'Premium Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  ],
                 ),
                  if (showSkipButton)
                    IconButton(
                      onPressed: onSkip ?? () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Lock icon with animation
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.2),
                              AppTheme.primary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 60,
                          color: AppTheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Main message
                      Text(
                        featureName != null 
                            ? 'Unlock $featureName'
                            : 'Unlock Premium Features',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Get access to exclusive content, ad-free experience, and premium features with our subscription plans.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                
                      
                      const SizedBox(height: 40),
                      
                      // Feature highlights
                      _buildFeatureHighlights(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  // Check trial eligibility
                  FutureBuilder<bool>(
                    future: ref.read(activeSubscriptionProvider.notifier).isEligibleForTrial(),
                    builder: (context, snapshot) {
                      final isEligibleForTrial = snapshot.data ?? false;
                      
                      if (isEligibleForTrial) {
                        return Column(
                          children: [
                            // Free trial button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _startFreeTrial(context, ref),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(56),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.diamond, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Start 3-Day Free Trial',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToSubscription(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.backgroundMiddle,
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56),
                        
                        ),
                      ),
                      child: const Text(
                        'View Subscription Plans',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  if (showSkipButton) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: onSkip ?? () => Navigator.of(context).pop(),
                      child: const Text(
                        'Continue with Limited Access',
                        style: TextStyle(
                          color: AppTheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primary,
                          decorationStyle: TextDecorationStyle.dashed,
                          decorationThickness: 1,
                          letterSpacing: 1
                        
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFeatureHighlights() {
    const features = [
      {
        'icon': Icons.star,
        'title': 'Premium Events',
        'description': 'Access exclusive events and VIP experiences',
      },
      {
        'icon': Icons.block,
        'title': 'Ad-Free',
        'description': 'Enjoy uninterrupted browsing experience',
      },
      {
        'icon': Icons.high_quality,
        'title': 'HD Quality',
        'description': 'Stream content in high definition',
      },
    ];

    return Column(
      children: features.map((feature) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundMiddle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
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
                feature['icon'] as IconData,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
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
      )).toList(),
    );
  }

  Future<void> _startFreeTrial(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(activeSubscriptionProvider.notifier).startFreeTrial();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free trial started! Enjoy premium features for 3 days.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start trial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubscriptionFlowScreen(),
      ),
    );
  }
}

// Helper widget for showing paywall as modal
class PaywallModal extends StatelessWidget {
  final String? featureName;
  final VoidCallback? onSkip;

  const PaywallModal({
    super.key,
    this.featureName,
    this.onSkip,
  });

  static Future<void> show(
    BuildContext context, {
    String? featureName,
    VoidCallback? onSkip,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundStart,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: PaywallScreen(
          featureName: featureName,
          onSkip: onSkip ?? () => Navigator.of(context).pop(),
          showSkipButton: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaywallScreen(
      featureName: featureName,
      onSkip: onSkip,
      showSkipButton: true,
    );
  }
}