import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a_play/core/theme/app_colors.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/home/services/user_stats_service.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? userStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _loadUserStats();
    _animationController.forward();
  }

  Future<void> _checkWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final welcomeDismissed = prefs.getBool('welcome_dismissed') ?? false;
    
    if (welcomeDismissed && mounted) {
      context.go('/home');
    }
  }

  Future<void> _loadUserStats() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final statsService = UserStatsService();
      final stats = await statsService.getUserStats(user.id);
      setState(() {
        userStats = stats;
        isLoading = false;
      });
    }
  }

  Future<void> _dismissWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcome_dismissed', true);
    if (mounted) {
      context.go('/home');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getEncouragementMessage() {
    final bookings = userStats?['totalBookings'] ?? 0;
    if (bookings == 0) {
      return "Ready to book your first amazing event?";
    } else if (bookings < 5) {
      return "You're on a roll! Keep exploring more events.";
    } else if (bookings < 10) {
      return "Wow! You're becoming a regular event-goer!";
    } else {
      return "You're an event superstar! Thanks for being amazing!";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
            color: AppColors.background,
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _dismissWelcome,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome content
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Greeting
                                  Text(
                                    '${_getGreeting()},',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // User name
                                  Text(
                                    userStats?['fullName'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Stats container
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Stats row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildStatItem(
                                              'Events Booked',
                                              '${userStats?['totalBookings'] ?? 0}',
                                              Icons.event,
                                            ),
                                            _buildStatItem(
                                              'Total Spent',
                                              '₦${(userStats?['totalSpent'] ?? 0.0).toStringAsFixed(0)}',
                                              Icons.attach_money,
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 24),
                                        
                                        // Membership tier
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: AppColors.primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${userStats?['membershipTier'] ?? 'Basic'} Member',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Encouragement message
                                  Text(
                                    _getEncouragementMessage(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _dismissWelcome,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Explore Events',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.background,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}