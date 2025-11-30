import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';
import 'package:a_play/features/concierge/screens/concierge_page.dart';
import 'package:a_play/features/explore/screens/explore_page.dart';
import 'package:a_play/features/feed/screen/feed_page.dart';
import 'package:a_play/features/home/screens/home_screen2.dart';
import 'package:a_play/features/home/widgets/welcome_overlay.dart';
import 'package:a_play/features/home/providers/welcome_provider.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
    const FeedPage(),
  ];

  bool _showWelcomeOverlay = false;

  @override
  void initState() {
    super.initState();
    _checkWelcomeStatus();
  }

  Future<void> _checkWelcomeStatus() async {
    // Always show welcome overlay on app start/hot restart
    if (mounted) {
      setState(() {
        _showWelcomeOverlay = true;
      });
    }
  }

  void _dismissWelcomeOverlay() {
    setState(() {
      _showWelcomeOverlay = false;
    });
    
    // Trigger tutorial in home screen after welcome overlay is dismissed
    ref.read(welcomeOverlayDismissedProvider.notifier).state = true;
  }

  // Check if user is authenticated and show login prompt if needed for protected tabs
  void _handleTabTap(int index) {
    // Tabs that require authentication: Bookings (2), Concierge (3), Feed (4)
    final protectedTabs = [2, 3, 4];
    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.value != null;

    if (protectedTabs.contains(index) && !isAuthenticated) {
      _showLoginPrompt(context, index);
    } else {
      ref.read(navigationIndexProvider.notifier).state = index;
    }
  }

  void _showLoginPrompt(BuildContext context, int requestedTab) {
    final tabNames = {2: 'Bookings', 3: 'Concierge', 4: 'Feed'};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Iconsax.lock_1,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access ${tabNames[requestedTab]} and unlock all features.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/sign-in');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continue Browsing',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
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
      floatingActionButton: _showWelcomeOverlay ? null : Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            currentIndex == 0 ? Iconsax.home_25 : Iconsax.home_2,
            size: 28,
            color: Colors.white,
          ),
          onPressed: () => ref.read(navigationIndexProvider.notifier).state = 0,
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
          height: 60 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          notchMargin: 8,
          color: AppTheme.surfaceDark,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              const SizedBox(width: 80), // Space for FAB
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}