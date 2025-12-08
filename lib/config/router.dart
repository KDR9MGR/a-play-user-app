import 'package:a_play/features/booking/screens/booking_confirmation_screen.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';
import 'package:a_play/features/club_booking/screens/club_booking_screen.dart';
import 'package:a_play/features/navbar.dart';
import 'package:a_play/features/podcast/screens/podcast_screen.dart';
import 'package:a_play/features/profile/screens/about_screen.dart';
import 'package:a_play/features/profile/screens/edit_profile_page.dart';
import 'package:a_play/features/profile/screens/privacy_policy_screen.dart';
import 'package:a_play/presentation/pages/legal_links_page.dart';
import 'package:a_play/features/referral/view/referral_screen.dart';
import 'package:a_play/features/restaurant/screens/restaurant_details_screen.dart';
import 'package:a_play/features/splash/splash_screen.dart';
import 'package:a_play/features/subscription/screens/subscription_plans_screen.dart';
import 'package:a_play/features/subscription/screens/subscription_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/authentication/presentation/screens/sign_in_screen.dart';
import '../features/authentication/presentation/screens/sign_up_screen.dart';
import '../features/profile/screens/profile_screen.dart';

// Router notifier
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool isAuth = false;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, next) {
      final wasAuth = isAuth;
      isAuth = next.value != null;
      if (wasAuth != isAuth) {
        notifyListeners();
      }
    });
  }

  String? call(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/sign-up';
    if (state.matchedLocation == '/splash') return null;

    // Routes that guests can access without authentication (Apple App Store requirement 5.1.1)
    final guestAllowedRoutes = [
      '/home',
      '/podcast',
      '/explore',
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
    if (isLoggingIn) return '/home';
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
          path: '/home',
          builder: (context, state) => const BottomNavigation(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'edit_profile',
              builder: (context, state) => const EditProfilePage(),
            ),
            GoRoute(
              path: 'privacy-policy',
              name: 'privacy_policy',
              builder: (context, state) => const PrivacyPolicyScreen(),
            ),
            GoRoute(
              path: 'legal',
              name: 'legal_links',
              builder: (context, state) => const LegalLinksPage(),
            ),
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: 'referral',
              name: 'referral',
              builder: (context, state) => const ReferralScreen(),
            ),
          ],
        ),

        GoRoute(
          path: '/podcast',
          builder: (context, state) => const PodcastScreen(),
        ),
        GoRoute(
          path: '/booking-confirmation/:id',
          builder: (context, state) =>
              BookingConfirmationScreen(bookingId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/my-tickets',
          builder: (context, state) => const MyTicketsScreen(),
        ),
        // Club booking routes
        GoRoute(
          path: '/club-booking',
          name: 'club_booking',
          builder: (context, state) =>
              const Scaffold(), // Empty scaffold as parent
          routes: [
            GoRoute(
              path: ':clubId',
              builder: (context, state) => ClubBookingScreen(
                clubId: state.pathParameters['clubId'] ?? '',
              ),
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
          builder: (context, state) => const Scaffold(), // Empty scaffold as parent
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
