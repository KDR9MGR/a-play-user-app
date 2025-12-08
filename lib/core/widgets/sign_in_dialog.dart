import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_play/core/theme/app_colors.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';

/// Reusable Sign-In Dialog for Guest Users
///
/// This dialog is shown when unauthenticated users try to access protected features
/// like event booking, club reservations, or subscriptions.
///
/// Complies with App Store Guidelines 5.1.1 (Guest Access)
class SignInDialog {
  /// Show as a modal dialog
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
    String? featureName,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _SignInDialogContent(
        title: title,
        message: message,
        featureName: featureName,
      ),
    );
    return result ?? false;
  }

  /// Show as a bottom sheet (recommended for mobile UX)
  static Future<bool> showBottomSheet(
    BuildContext context, {
    String? title,
    String? message,
    String? featureName,
    bool isDismissible = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SignInBottomSheetContent(
        title: title,
        message: message,
        featureName: featureName,
      ),
    );
    return result ?? false;
  }
}

/// Dialog content widget
class _SignInDialogContent extends StatelessWidget {
  final String? title;
  final String? message;
  final String? featureName;

  const _SignInDialogContent({
    this.title,
    this.message,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGradient[0].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 32,
                color: AppColors.primaryGradient[0],
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title ?? 'Sign In Required',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message ??
              (featureName != null
                  ? 'Please sign in to access $featureName'
                  : 'Please sign in to continue'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/sign-in');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGradient[0],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/register');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primaryGradient[0]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGradient[0],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Continue as Guest Button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Continue as Guest',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet content widget (better for mobile UX)
class _SignInBottomSheetContent extends StatelessWidget {
  final String? title;
  final String? message;
  final String? featureName;

  const _SignInBottomSheetContent({
    this.title,
    this.message,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Lock Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryGradient[0].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 32,
              color: AppColors.primaryGradient[0],
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title ?? 'Sign In Required',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Message
          Text(
            message ??
            (featureName != null
                ? 'Please sign in to access $featureName'
                : 'Please sign in to continue'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/sign-in');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGradient[0],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Create Account Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/register');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primaryGradient[0]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGradient[0],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Continue as Guest Button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Continue as Guest',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility class for authentication helpers
class AuthUtils {
  /// Check if user is authenticated, show dialog if not
  /// Returns true if user is authenticated or successfully signs in
  static Future<bool> requireAuth(
    BuildContext context,
    WidgetRef ref, {
    String? featureName,
    String? message,
    bool useBottomSheet = false,
  }) async {
    final user = ref.watch(authStateProvider).value;
    if (user != null) return true;

    // Show dialog or bottom sheet
    if (useBottomSheet) {
      await SignInDialog.showBottomSheet(
        context,
        featureName: featureName,
        message: message,
      );
    } else {
      await SignInDialog.show(
        context,
        featureName: featureName,
        message: message,
      );
    }

    // Check if user signed in after dialog closed
    final userAfter = ref.read(authStateProvider).value;
    return userAfter != null;
  }
}
