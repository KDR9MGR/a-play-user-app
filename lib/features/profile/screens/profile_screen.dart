import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/referral/provider/referral_provider.dart';
import '../../../features/referral/controller/referral_controller.dart';
import '../../../features/subscription/provider/subscription_provider.dart';
import '../../../features/home/services/user_stats_service.dart';
import 'package:intl/intl.dart';

// Provider for user stats
final userStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final statsService = UserStatsService();
  return await statsService.getUserStats(userId);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileFutureProvider);
    final userPointsAsync = ref.watch(userPointsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMiddle,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to settings
            },
            icon: const Icon(
              Iconsax.setting_2,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
      body: profileState.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              _buildProfileHeader(profile, userPointsAsync, user, context),
              const SizedBox(height: 24),
              
              // Stats Section
              user != null
                  ? Consumer(
                      builder: (context, ref, child) {
                        final userStatsAsync = ref.watch(userStatsProvider(user.id));
                        return userStatsAsync.when(
                          data: (userStats) => _buildStatsSection(userStats, userPointsAsync),
                          loading: () => SizedBox(
                            height: 100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          error: (_, __) => _buildStatsSection(null, userPointsAsync),
                        );
                      },
                    )
                  : _buildStatsSection(null, userPointsAsync),
              const SizedBox(height: 24),
              
              // Bookings Section
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BookingCard(
                      icon: Iconsax.reserve,
                      title: 'Table Bookings',
                      subtitle: 'View reservations',
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BookingCard(
                      icon: Iconsax.ticket,
                      title: 'Event Tickets',
                      subtitle: 'Manage tickets',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/my-tickets');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Premium Section
              const Text(
                'Premium Membership',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final hasSubscriptionAsync = ref.watch(hasActiveSubscriptionProvider);
                  final activeSubscriptionAsync = ref.watch(activeSubscriptionProvider);
                  
                  return hasSubscriptionAsync.when(
                    data: (hasSubscription) {
                      if (hasSubscription) {
                        return activeSubscriptionAsync.when(
                          data: (subscription) => subscription != null 
                              ? _PremiumCard(
                                  icon: Iconsax.crown_1,
                                  title: 'Premium Active',
                                  subtitle: 'Expires: ${DateFormat('MMM dd, yyyy').format(subscription.endDate)}',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/subscription/history');
                                  },
                                  isPremium: true,
                                )
                              : _PremiumCard(
                                  icon: Iconsax.card,
                                  title: 'Get Premium',
                                  subtitle: 'Unlock exclusive features and benefits',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/subscription/plans');
                                  },
                                  isPremium: false,
                                ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          error: (_, __) => _PremiumCard(
                            icon: Iconsax.card,
                            title: 'Get Premium',
                            subtitle: 'Unlock exclusive features and benefits',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/subscription/plans');
                            },
                            isPremium: false,
                          ),
                        );
                      } else {
                        return _PremiumCard(
                          icon: Iconsax.card,
                          title: 'Get Premium',
                          subtitle: 'Unlock exclusive features and benefits',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/subscription/plans');
                          },
                          isPremium: false,
                        );
                      }
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    error: (_, __) => _PremiumCard(
                      icon: Iconsax.card,
                      title: 'Get Premium',
                      subtitle: 'Unlock exclusive features and benefits',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/subscription/plans');
                      },
                      isPremium: false,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Settings Section
              const Text(
                'Settings & Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                icon: Iconsax.star_1,
                title: 'Points & Referrals',
                subtitle: 'Earn rewards',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/referral');
                },
              ),
              _SettingsCard(
                icon: Iconsax.edit_2,
                title: 'Edit Profile',
                subtitle: 'Update your information',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/profile/edit');
                },
              ),
              _SettingsCard(
                icon: Iconsax.shield_tick,
                title: 'Privacy Policy',
                subtitle: 'Read our policies',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/privacy-policy');
                },
              ),
              _SettingsCard(
                icon: Iconsax.document_text,
                title: 'Legal & Policies',
                subtitle: 'Terms, EULA, refunds, FAQ, contact',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/legal');
                },
              ),
              _SettingsCard(
                icon: Iconsax.info_circle,
                title: 'About',
                subtitle: 'App information',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/about');
                },
              ),
              const SizedBox(height: 24),
              
              // Sign Out Button
              _buildSignOutButton(ref, context),

              // Delete Account Button (Apple App Store requirement 5.1.1)
              _buildDeleteAccountButton(ref, context),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile, AsyncValue userPointsAsync, dynamic user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.2),
                  AppTheme.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Iconsax.profile_circle,
                        size: 40,
                        color: Colors.white54,
                      ),
                    )
                  : const Icon(
                      Iconsax.profile_circle,
                      size: 40,
                      color: Colors.white54,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (profile.fullName == null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Tap edit to add name',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.phone ?? user?.email ?? 'No contact info',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                // Points Display
                userPointsAsync.when(
                  data: (points) => points != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.star_1,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${points.availablePoints} Points',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          
          // Edit Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/profile/edit');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.edit_2,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  Widget _buildStatsSection(Map<String, dynamic>? userStats, AsyncValue? userPointsAsync) {
    // Extract real data or use defaults
    final totalBookings = userStats?['totalBookings']?.toString() ?? '0';
    final availablePointsRaw = userStats?['availablePoints'] ?? 0;
    final availablePoints = _formatNumber(availablePointsRaw is int ? availablePointsRaw : int.tryParse(availablePointsRaw.toString()) ?? 0);
    final membershipTier = userStats?['membershipTier'] ?? 'Bronze';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(totalBookings, 'Bookings', Iconsax.ticket),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(availablePoints, 'Points', Iconsax.star_1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(membershipTier, 'Tier', Iconsax.crown_1),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(WidgetRef ref, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showSignOutDialog(ref, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.logout_1,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3, end: 0);
  }

  void _showSignOutDialog(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showDeleteAccountDialog(ref, context);
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.red.shade300,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1100.ms);
  }

  void _showDeleteAccountDialog(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Iconsax.warning_2, color: Colors.red.shade400, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete your account?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action will permanently delete:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Your profile and personal data', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• All your bookings and tickets', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Your subscription history', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Your posts and messages', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Your points and rewards', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red.shade300,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _confirmDeleteAccount(ref, context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(WidgetRef ref, BuildContext context) {
    // Show a second confirmation for extra safety
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Final Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Type "DELETE" to confirm account deletion.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );

              try {
                await ref.read(authControllerProvider.notifier).deleteAccount();
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/sign-in');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BookingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: const Icon(
          Iconsax.arrow_right_3,
          color: Colors.white54,
          size: 20,
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: 0.3, end: 0);
  }
}

class _PremiumCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremium;

  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isPremium
              ? LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPremium ? null : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPremium 
                ? AppTheme.primary.withOpacity(0.3)
                : AppTheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPremium 
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.3, end: 0);
  }
}