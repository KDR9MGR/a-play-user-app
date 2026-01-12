import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget shown when user tries to access chat without subscription
class SubscriptionRequiredWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onSubscribePressed;

  const SubscriptionRequiredWidget({
    super.key,
    this.message,
    this.onSubscribePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade600,
                    Colors.orange.shade600,
                  ],
                ),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Subscription Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Message
            Text(
              message ??
                  'Chat is available for subscribed members only.\n\n'
                      'Subscribe to connect with other members and enjoy exclusive features!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Benefits list
            _buildBenefitItem(
              context,
              icon: Icons.chat_bubble_outline,
              text: 'Chat with other members',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              context,
              icon: Icons.group_outlined,
              text: 'Join group conversations',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              context,
              icon: Icons.star_outline,
              text: 'Access exclusive features',
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              context,
              icon: Icons.trending_up,
              text: 'Connect and network',
            ),

            const SizedBox(height: 32),

            // Subscribe button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSubscribePressed ??
                    () {
                      // Navigate to subscription screen
                      context.push('/subscription');
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text(
                      'Subscribe Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildBenefitItem(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.amber,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Small prompt widget for inline subscription requirements
class InlineSubscriptionPrompt extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const InlineSubscriptionPrompt({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => context.push('/subscription'),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Required',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.amber,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for subscription prompt
class SubscriptionPromptBottomSheet extends StatelessWidget {
  final String title;
  final String message;

  const SubscriptionPromptBottomSheet({
    super.key,
    this.title = 'Subscription Required',
    this.message = 'You need an active subscription to access this feature.',
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionPromptBottomSheet(
        title: title ?? 'Subscription Required',
        message: message ?? 'You need an active subscription to access this feature.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade600,
                      Colors.orange.shade600,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8),
                      Text(
                        'View Plans',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
