import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Coming Soon Widget for features under development
/// Used to indicate features that are not part of MVP but will be available soon
class ComingSoonWidget extends StatelessWidget {
  final String featureName;
  final String? description;
  final IconData? icon;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const ComingSoonWidget({
    super.key,
    required this.featureName,
    this.description,
    this.icon,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (showBackButton)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 2),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon ?? Icons.watch_later_outlined,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Coming Soon text
                      Text(
                        'Coming Soon',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Feature name
                      Text(
                        featureName,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Description
                      if (description != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            description!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 48),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'We\'re working hard to bring you this feature!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stay tuned for updates.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coming Soon Screen - Full screen version
class ComingSoonScreen extends StatelessWidget {
  final String featureName;
  final String? description;
  final IconData? icon;

  const ComingSoonScreen({
    super.key,
    required this.featureName,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComingSoonWidget(
        featureName: featureName,
        description: description,
        icon: icon,
        showBackButton: true,
      ),
    );
  }
}

/// Coming Soon Banner - For inline use
class ComingSoonBanner extends StatelessWidget {
  final String message;
  final bool compact;

  const ComingSoonBanner({
    super.key,
    this.message = 'Coming Soon',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.watch_later_outlined,
            size: compact ? 16 : 20,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: compact ? 8 : 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
