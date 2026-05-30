
import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';
import 'package:a_play/features/concierge/screens/concierge_page.dart';
import 'package:a_play/features/explore/screens/explore_page.dart';
import 'package:a_play/features/feed/screen/instagram_feed_page.dart';
import 'package:a_play/features/home/screens/home_screen2.dart';
import 'package:a_play/features/home/widgets/welcome_overlay.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({super.key});

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  final List<Widget> _pages = [
    const HomeScreen2(),
    const ExplorePage(),
    const MyTicketsScreen(),
    const ConciergePage(),
    const InstagramFeedPage(),
  ];

  bool _showWelcomeOverlay = false;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
  }

  Future<void> _checkWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

    if (hasCompletedOnboarding && !hasSeenWelcome) {
      if (mounted) {
        setState(() {
          _showWelcomeOverlay = true;
        });
        await prefs.setBool('has_seen_welcome', true);
      }
    }
  }

  void _dismissWelcomeOverlay() {
    setState(() {
      _showWelcomeOverlay = false;
    });
  }

  void _handleTabTap(int index) {
    final isAuth = ref.read(authStateProvider).value != null;
    if (!isAuth && (index == 2 || index == 3)) {
      // Guest users can only access Home and Explore
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text('You need to be signed in to access this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to sign-in screen
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    } else {
      ref.read(navigationIndexProvider.notifier).state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          if (_showWelcomeOverlay)
            WelcomeOverlay(
              onDismiss: _dismissWelcomeOverlay,
            ),
        ],
      ),
      floatingActionButton: _showWelcomeOverlay ? null : SizedBox(
        height: 64,
        width: 64,
        child: FittedBox(
          child: FloatingActionButton(
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              currentIndex == 0 ? Iconsax.home_25 : Iconsax.home_2,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () => ref.read(navigationIndexProvider.notifier).state = 0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _showWelcomeOverlay ? null : Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          height: 68 + bottomPadding,
          padding: EdgeInsets.only(
            bottom: bottomPadding > 0 ? bottomPadding : 8,
            left: 4,
            right: 4,
            top: 4,
          ),
          notchMargin: 6,
          color: AppTheme.surfaceDark,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavBarItem(
                icon: Iconsax.discover_1,
                selectedIcon: Iconsax.discover5,
                label: 'Explore',
                isSelected: currentIndex == 1,
                onTap: () => _handleTabTap(1),
              ),
              _NavBarItem(
                icon: Iconsax.ticket,
                selectedIcon: Iconsax.ticket_star5,
                label: 'Bookings',
                isSelected: currentIndex == 2,
                onTap: () => _handleTabTap(2),
              ),
              const SizedBox(width: 56), // Space for FAB
              _NavBarItem(
                icon: Iconsax.crown,
                selectedIcon: Iconsax.crown5,
                label: 'Concierge',
                isSelected: currentIndex == 3,
                onTap: () => _handleTabTap(3),
              ),
              _NavBarItem(
                icon: Iconsax.bookmark,
                selectedIcon: Iconsax.bookmark5,
                label: 'Feeds',
                isSelected: currentIndex == 4,
                onTap: () => _handleTabTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppTheme.primary : Colors.grey.shade600,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
