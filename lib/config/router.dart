
import 'package:a_play/features/booking/screens/booking_confirmation_screen.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';
import 'package:a_play/features/club_booking/screens/club_booking_confirmation_screen.dart';
import 'package:a_play/features/club_booking/screens/club_booking_screen.dart';
import 'package:a_play/features/concierge/screens/concierge_request_confirmation_screen.dart';
import 'package:a_play/features/feed/screen/instagram_feed_page.dart';
import 'package:a_play/features/navbar.dart';
import 'package:a_play/features/onboarding/screens/onboarding_screen.dart';
import 'package:a_play/features/podcast/screens/podcast_screen.dart';
import 'package:a_play/features/profile/providers/profile_provider.dart';
import 'package:a_play/features/profile/screens/profile_screen.dart';
import 'package:a_play/features/restaurant/screens/restaurant_details_screen.dart';
import 'package:a_play/features/splash/splash_screen.dart';
import 'package:a_play/features/subscription/screens/subscription_history_screen.dart';
import 'package:a_play/features/subscription/screens/subscription_plans_screen.dart';
import 'package:a_play/features/authentication/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/authentication/presentation/screens/password_reset_screen.dart';
import '../features/authentication/presentation/screens/sign_in_screen.dart';
import '../features/authentication/presentation/screens/sign_up_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool isAuth;

  RouterNotifier(this._ref) : isAuth = _ref.read(authProvider).currentUser != null {
    _ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      final user = next.value;
      isAuth = user != null;
      notifyListeners();
    });
  }

  Future<String?> call(BuildContext context, GoRouterState state) async {
    final isLoggingIn = state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/sign-up' ||
        state.matchedLocation == '/auth/callback';
    if (state.matchedLocation == '/splash') return null;

    // Routes that guests can access without authentication (Apple App Store requirement 5.1.1)
    final guestAllowedRoutes = [
      '/home',
      '/podcast',
      '/explore',
      '/feed',
      '/location',
      '/subscription', // Allow guests to view subscription plans (auth required to purchase)
    ];

    final isGuestAllowedRoute = guestAllowedRoutes.any(
      (route) => state.matchedLocation == route || state.matchedLocation.startsWith('$route/'),
    );

    if (!isAuth) {
      // Allow guest access to browse-only features
      if (isGuestAllowedRoute || isLoggingIn) return null;
      return '/sign-in';
    }

    final profile = await _ref.read(profileFutureProvider.future);
    if (!profile.isOnboardingComplete) {
      return '/onboarding';
    }

    if (isLoggingIn) {
      if (profile.isOnboardingComplete) {
        return '/home';
      }
      return '/onboarding';
    }
    return null;
  }

  List<RouteBase> get routes => [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const PasswordResetScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const BottomNavigation(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const InstagramFeedPage(),
        ),
        GoRoute(
          path: '/location',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/podcast',
          builder: (context, state) => const PodcastScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/booking-confirmation/:id',
          builder: (context, state) =>
              BookingConfirmationScreen(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/my-tickets',
          builder: (context, state) => const MyTicketsScreen(),
        ),
        // Club booking routes
        GoRoute(
          path: '/club-booking',
          name: 'club_booking',
          builder: (context, state) => const BottomNavigation(),
          routes: [
            GoRoute(
              path: ':clubId',
              builder: (context, state) => ClubBookingScreen(
                clubId: state.pathParameters['clubId'] ?? '',
              ),
            ),
            GoRoute(
              path: ':clubId/confirmation',
              builder: (context, state) => const ClubBookingConfirmationScreen(),
            ),
          ],
        ),
        // Restaurant routes
        GoRoute(
          path: '/restaurant/:restaurantId',
          name: 'restaurant_details',
          builder: (context, state) => RestaurantDetailsScreen(
            restaurantId: state.pathParameters['restaurantId'] ?? '',
          ),
        ),
        // Subscription routes
        GoRoute(
          path: '/subscription',
          name: 'subscription',
          builder: (context, state) => const BottomNavigation(),
          routes: [
            GoRoute(
              path: 'plans',
              name: 'subscription_plans',
              builder: (context, state) => const SubscriptionPlansScreen(),
            ),
            GoRoute(
              path: 'history',
              name: 'subscription_history',
              builder: (context, state) => const SubscriptionHistoryScreen(),
            ),
          ],
        ),
        // Concierge routes
        GoRoute(
          path: '/concierge/confirmation',
          builder: (context, state) => const ConciergeRequestConfirmationScreen(),
        ),
      ];
}

// Router provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.call,
    routes: notifier.routes,
  );
});
