import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';

class PointsCelebrationDialog extends StatelessWidget {
  final int points;
  final VoidCallback onClose;

  const PointsCelebrationDialog({
    super.key,
    required this.points,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: 300,
        height: 415,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.5),
          ],
        ),
        child: Stack(
          children: [
            // Close button
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(
                  FontAwesomeIcons.xmark,
                  color: Colors.white70,
                  size: 20,
                ),
              ).animate()
                .scale(delay: 500.ms)
                .fadeIn(duration: 300.ms),
            ),
            
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Celebration animation
                SizedBox(
                  height: 120,
                  child: Lottie.network(
                    'https://assets5.lottiefiles.com/packages/lf20_touohxv0.json',
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 20),
                // Hurray text
                Text(
                  '🎉 Hurray! 🎊',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 300.ms),
                const SizedBox(height: 16),
                // Points text
                Text(
                  'You\'ve earned',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.coins,
                      color: Color(0xFFFFD700),
                      size: 24,
                    ).animate()
                      .scale(delay: 600.ms)
                      .shimmer(duration: 1200.ms),
                    const SizedBox(width: 8),
                    Text(
                      '₦$points',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ).animate()
                      .slideY(begin: 0.3, end: 0)
                      .scale(delay: 600.ms)
                      .shimmer(duration: 1200.ms),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Keep going! 🚀',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 900.ms),
                const SizedBox(height: 20),
                // Progress to next tier
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '300 points to next tier',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: points / 1000,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 1, end: 0)
              ],
            ),
          ],
        ),
      ),
    );
  }
} 