import 'package:a_play/features/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:a_play/core/theme/app_colors.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/home/services/user_stats_service.dart';
import 'package:a_play/features/home/providers/home_event_provider.dart';
import 'package:a_play/data/models/event_model.dart';

// Provider for user stats
final userStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final statsService = UserStatsService();
  return await statsService.getUserStats(userId);
});

// Provider for upcoming events (random 4 events)
final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventsAsync = await ref.watch(homeEventProvider.future);
  final events = eventsAsync.take(4).toList();
  return events;
});

class WelcomeOverlay extends ConsumerStatefulWidget {
  final VoidCallback onDismiss;

  const WelcomeOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  ConsumerState<WelcomeOverlay> createState() => _WelcomeOverlayState();
}

class _WelcomeOverlayState extends ConsumerState<WelcomeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _dismissSlideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _dismissSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInBack,
    ));

    _animationController.forward();

    // For testing - reset the welcome dismissed flag
    _resetWelcomeFlag();
  }

  Future<void> _resetWelcomeFlag() async {
    // No longer needed since we always show the overlay
  }

  Future<void> _dismissWelcome() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getEncouragementMessage(Map<String, dynamic>? userStats) {
    final eventsAttended = userStats?['eventsAttended'] ?? 0;
    final membershipTier = userStats?['membershipTier'] ?? 'Bronze';

    if (eventsAttended == 0) {
      return "Ready to book your first amazing event?";
    } else if (eventsAttended < 3) {
      return "You're on a roll! Keep exploring more events.";
    } else if (eventsAttended < 7) {
      return "Wow! You're becoming a regular event-goer!";
    } else if (membershipTier == 'Platinum') {
      return "You're a Platinum member! Thanks for being amazing!";
    } else {
      return "You're an event superstar! Keep it up!";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: SlideTransition(
          position: _animationController.status == AnimationStatus.reverse
              ? _dismissSlideAnimation
              : _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
              child: Column(
                children: [
                  // Header with logo and skip button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Logo
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/app_logo.svg',
                            height: 32,
                            width: 32,
                          ),
                        ],
                      ),
                      // Skip button
                      GestureDetector(
                        onTap: _dismissWelcome,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: authState.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (error, stack) => const Center(
                        child: Text(
                          'Error loading user data',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      data: (user) {
                        if (user == null) {
                          return const Center(
                            child: Text(
                              'Please log in to view your stats',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return Consumer(
                          builder: (context, ref, child) {
                            final userStatsAsync =
                                ref.watch(userStatsProvider(user.id));

                            return userStatsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                              error: (error, stack) => SlideTransition(
                                position: _slideAnimation,
                                child: _buildContent(null),
                              ),
                              data: (userStats) => SlideTransition(
                                position: _slideAnimation,
                                child: _buildContent(userStats),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
      
    );
  }

  Widget _buildContent(Map<String, dynamic>? userStats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 59,
                  height: 59,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: userStats?['avatarUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            userStats!['avatarUrl'],
                            fit: BoxFit.cover,
                            width: 59,
                            height: 59,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 32, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 32, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userStats?['fullName'] ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _tierProgressBar(
            tier: userStats?['membershipTier'] ?? 'Bronze',
            pointsToNext: userStats?['pointsToNextTier'] ?? 1000,
            progress: userStats?['tierProgress'] ?? 0.0,
            nextTierName: userStats?['nextTierName'] ?? 'Silver',
          ),
          const SizedBox(height: 16),
          // Encouragement message
          Text(
            _getEncouragementMessage(userStats),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
              
            ),
          ),
         
          const SizedBox(height: 24),
          // Stats Cards
          _statCard(
            iconData: '🏆',
            label: 'Total Reward points',
            value: userStats?['rewardPoints']?.toString() ?? '0',
            iconColor: const Color(0xFFF44A07),
            showCoinIcon: true,
          ),
          const SizedBox(height: 16),
          _statCard(
            iconData: '🎉',
            label: 'Events Attended',
            value: userStats?['eventsAttended']?.toString() ?? '0',
            iconColor: const Color(0xFFF44A07),
            showTrophyIcon: true,
          ),
          const SizedBox(height: 16),
          _statCard(
            iconData: '🎫',
            label: 'Total Bookings',
            value: userStats?['totalBookings']?.toString() ?? '0',
            iconColor: const Color(0xFFF44A07),
          ),
          const SizedBox(height: 24),
          // Tier Progress Bar
       
          // Upcoming Events Section
          _buildUpcomingEventsSection(),

          const SizedBox(height: 40),

          const SizedBox(height: 40),
          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _dismissWelcome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _statCard({
    required String iconData,
    required String label,
    required String value,
    required Color iconColor,
    bool showCoinIcon = false,
    bool showTrophyIcon = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF484848),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFFFF8960),
                width: 6,
              ),
            ),
            child: Center(
                child: _getIconWidget(iconData, showCoinIcon, showTrophyIcon)),
          ),
          const SizedBox(width: 21),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF969696),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (showCoinIcon) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: _buildCoinIcon(),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (showTrophyIcon) ...[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: _buildTrophyIcon(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconWidget(
      String iconData, bool showCoinIcon, bool showTrophyIcon) {
    if (showCoinIcon) {
      return _buildCrownIcon();
    } else if (showTrophyIcon) {
      return _buildPartyPopperIcon();
    } else if (iconData == '🎫') {
      return _buildTicketIcon();
    } else {
      return _buildPartyPopperIcon();
    }
  }

  Widget _buildCrownIcon() {
    return const Center(
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildPartyPopperIcon() {
    return const Icon(
      Icons.celebration,
      color: Colors.white,
      size: 24,
    );
  }

  Widget _buildCoinIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFFF4CC0C),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD49007), width: 1),
      ),
      child: const Center(
        child: Text(
          '¢',
          style: TextStyle(
            color: Color(0xFFD49007),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyIcon() {
    return const Icon(
      Icons.emoji_events,
      color: Color(0xFFFFD983),
      size: 24,
    );
  }

  Widget _buildTicketIcon() {
    return const Icon(
      Icons.confirmation_number,
      color: Colors.white,
      size: 24,
    );
  }

  Widget _tierProgressBar({
    required String tier,
    required int pointsToNext,
    required double progress, // 0.0 to 1.0
    required String nextTierName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'You are on ${tier.toUpperCase()} TIER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              pointsToNext > 0
                  ? '+$pointsToNext pt to $nextTierName'
                  : (nextTierName == 'Max Level' ? 'Max Level Reached!' : '+0 pt to next'),
              style: const TextStyle(
                color: Color(0xFF13C90A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Background progress bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44A07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Floating icon at progress position
                Positioned(

                  left: (constraints.maxWidth - 26) * progress.clamp(0.0, 1.0),
                  top: -6,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44A07),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(-2, -1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SectionTitle(title: 'What\'s The Play Today'),
            const SizedBox(height: 16),
            upcomingEventsAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, stack) => const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Failed to load events',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              data: (events) => _buildEventsGrid(events),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventsGrid(List<EventModel> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: events.length > 4 ? 4 : events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Event Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1F1F1F),
              ),
              child: event.coverImage.isNotEmpty
                  ? Image.network(
                      event.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1F1F1F),
                          child: const Icon(
                            Icons.event,
                            color: Colors.white54,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF1F1F1F),
                      child: const Icon(
                        Icons.event,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
            ),
            // Bottom to top gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Event name
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}