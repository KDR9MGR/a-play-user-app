
import 'package:a_play/config/feature_flags.dart';
import 'package:a_play/core/widgets/coming_soon_widget.dart';
import 'package:a_play/features/booking/screens/booking_confirmation_screen.dart';
import 'package:a_play/features/booking/screens/my_tickets_screen.dart';
import 'package:a_play/features/club_booking/screens/club_booking_screen.dart';
import 'package:a_play/features/club/screens/club_booking_confirmation_screen.dart';
import 'package:a_play/features/concierge/screens/concierge_request_confirmation_screen.dart';
import 'package:a_play/features/feed/screen/instagram_feed_page.dart';
import 'package:a_play/features/chat/screens/chat_list_screen.dart';
import 'package:a_play/features/navbar.dart';
import 'package:a_play/features/onboarding/screens/onboarding_screen.dart';
import 'package:a_play/features/podcast/screens/podcast_screen.dart';
import 'package:a_play/features/authentication/data/models/user_model.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/authentication/presentation/screens/auth_callback_screen.dart';
import 'package:a_play/features/profile/screens/profile_screen.dart';
import 'package:a_play/features/profile/screens/edit_profile_page.dart';
import 'package:a_play/features/restaurant/screens/restaurant_details_screen.dart';
import 'package:a_play/features/restaurant/screens/restaurant_payment_screen.dart';
import 'package:a_play/features/splash/splash_screen.dart';
import 'package:a_play/features/subscription/screens/subscription_history_screen.dart';
import 'package:a_play/features/subscription/screens/trial_offer_screen.dart';
import 'package:a_play/features/subscription/view/subscription_screen_new.dart';
import 'package:a_play/features/subscription/provider/subscription_provider.dart';
import 'package:a_play/features/subscription/provider/subscription_status_provider.dart';
import 'package:a_play/features/booking/providers/bookin_history_provider.dart';
import 'package:a_play/features/profile/providers/profile_provider.dart';
import 'package:a_play/features/referral/controller/referral_controller.dart';
import 'package:a_play/features/referral/view/referral_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/authentication/presentation/screens/password_reset_screen.dart';
import '../features/authentication/presentation/screens/update_password_screen.dart';
import '../features/authentication/presentation/screens/sign_in_screen.dart';
import '../features/authentication/presentation/screens/sign_up_screen.dart';
import '../features/profile/screens/help_support_page.dart';
import '../features/profile/screens/blocked_users_screen.dart';
import '../features/profile/screens/notification_settings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool isAuth;
  String? _lastUserId;

  RouterNotifier(this._ref) : isAuth = Supabase.instance.client.auth.currentUser != null {
    _lastUserId = Supabase.instance.client.auth.currentUser?.id;
    _ref.listen<AsyncValue<UserModel?>>(authStateProvider, (_, next) {
      final newUserId = next.value?.id;
      // Whenever the signed-in user changes (sign-out, sign-in, or switching
      // accounts without restarting the app), drop every per-user cached
      // provider so no previous user's bookings/subscription/profile/points
      // data can leak into the next session on this device.
      if (newUserId != _lastUserId) {
        _lastUserId = newUserId;
        _invalidateUserScopedProviders();
      }
      isAuth = next.value != null;
      notifyListeners();
    });
  }

  void _invalidateUserScopedProviders() {
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(profileFutureProvider);
    _ref.invalidate(myBookingsProvider);
    _ref.invalidate(bookingHistoryProvider);
    _ref.invalidate(subscriptionStatusProvider);
    _ref.invalidate(activeSubscriptionProvider);
    _ref.invalidate(subscriptionHistoryProvider);
    _ref.invalidate(paymentHistoryProvider);
    _ref.invalidate(pointTransactionsProvider);
    _ref.invalidate(referralProvider);
  }

  String? call(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/sign-up' ||
        state.matchedLocation == '/reset-password' ||
        state.matchedLocation == '/auth/callback';
    if (state.matchedLocation == '/splash') return null;

    if (state.matchedLocation == '/auth/callback') return null;

    // Allow guest browsing of these routes without authentication
    // Required by App Store Guideline 5.1.1(v) - Users must browse without login
    final guestAllowedRoutes = [
      '/home',
      '/explore',
      '/feed',
      '/podcast',
      '/help-support',
      RegExp(r'^/event/[^/]+$'),        // Event details (App Store requirement)
      RegExp(r'^/events$'),              // Events list (App Store requirement)
      RegExp(r'^/club-booking/[^/]+$'), // Club details
      RegExp(r'^/club/[^/]+$'),          // Club details (alt route)
      RegExp(r'^/restaurant/[^/]+$'),   // Restaurant details
    ];

    // Check if current route is guest-allowed
    final isGuestAllowed = guestAllowedRoutes.any((route) {
      if (route is String) {
        return state.matchedLocation == route;
      } else if (route is RegExp) {
        return route.hasMatch(state.matchedLocation);
      }
      return false;
    });

    if (!isAuth) {
      if (isLoggingIn || isGuestAllowed) return null;
      // For protected routes, redirect to sign-in
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
          path: '/chat',
          builder: (context, state) => const ChatListScreen(),
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
          path: '/update-password',
          builder: (context, state) => const UpdatePasswordScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/trial-offer',
          builder: (context, state) => const TrialOfferScreen(),
        ),
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => const AuthCallbackScreen(),
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
          builder: (context, state) {
            // MVP: Podcasts feature hidden - Coming in v2.1
            if (!FeatureFlags.enablePodcasts) {
              return const ComingSoonScreen(
                featureName: 'Podcasts & Entertainment',
                description: 'Stream exclusive podcast content and entertainment shows from top creators in Ghana.',
                icon: Iconsax.video_play,
              );
            }
            return const PodcastScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: '/profile/referral',
          builder: (context, state) => const ReferralScreen(),
        ),
        GoRoute(
          path: '/profile/change-password',
          builder: (context, state) => const UpdatePasswordScreen(fromSettings: true),
        ),
        GoRoute(
          path: '/profile/blocked-users',
          builder: (context, state) => const BlockedUsersScreen(),
        ),
        GoRoute(
          path: '/profile/notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/help-support',
          builder: (context, state) => const HelpSupportPage(),
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
        // Club booking routes - MVP: Hidden - Coming in v2.1
        GoRoute(
          path: '/club-booking',
          name: 'club_booking',
          builder: (context, state) {
            if (!FeatureFlags.enableClubs) {
              return const ComingSoonScreen(
                featureName: 'Club Bookings',
                description: 'Reserve VIP tables and bottle service at exclusive clubs and lounges across Ghana.',
                icon: Iconsax.crown,
              );
            }
            return const BottomNavigation();
          },
          routes: [
            GoRoute(
              path: ':clubId',
              builder: (context, state) {
                if (!FeatureFlags.enableClubs) {
                  return const ComingSoonScreen(
                    featureName: 'Club Bookings',
                    description: 'Reserve VIP tables and bottle service at exclusive clubs and lounges across Ghana.',
                    icon: Iconsax.crown,
                  );
                }
                return ClubBookingScreen(
                  clubId: state.pathParameters['clubId'] ?? '',
                );
              },
            ),
            GoRoute(
              path: ':clubId/confirmation',
              builder: (context, state) {
                if (!FeatureFlags.enableClubs) {
                  return const ComingSoonScreen(
                    featureName: 'Club Bookings',
                    description: 'Reserve VIP tables and bottle service at exclusive clubs and lounges across Ghana.',
                    icon: Iconsax.crown,
                  );
                }
                return const ClubBookingConfirmationScreen();
              },
            ),
          ],
        ),
        // Restaurant routes - MVP: Hidden - Coming in v2.1
        GoRoute(
          path: '/restaurant/:restaurantId',
          name: 'restaurant_details',
          builder: (context, state) {
            if (!FeatureFlags.enableRestaurants) {
              return const ComingSoonScreen(
                featureName: 'Restaurant Bookings',
                description: 'Book tables and order delicious food from top restaurants across Ghana.',
                icon: Iconsax.shop,
              );
            }
            return RestaurantDetailsScreen(
              restaurantId: state.pathParameters['restaurantId'] ?? '',
            );
          },
        ),
        GoRoute(
          path: '/restaurant/:restaurantId/payment',
          name: 'restaurant_payment',
          builder: (context, state) {
            if (!FeatureFlags.enableRestaurants) {
              return const ComingSoonScreen(
                featureName: 'Restaurant Bookings',
                description: 'Book tables and order delicious food from top restaurants across Ghana.',
                icon: Iconsax.shop,
              );
            }
            final extra = state.extra as Map<String, dynamic>;
            return RestaurantPaymentScreen(
              restaurantId: state.pathParameters['restaurantId']!,
              restaurantName: extra['restaurantName'],
              tableId: extra['tableId'],
              tableName: extra['tableName'],
              bookingDate: extra['bookingDate'],
              startTime: extra['startTime'],
              endTime: extra['endTime'],
              partySize: extra['partySize'],
              specialRequests: extra['specialRequests'],
              contactPhone: extra['contactPhone'],
              amount: extra['amount'],
            );
          },
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
              builder: (context, state) => const SubscriptionScreenNew(),
            ),
            GoRoute(
              path: 'history',
              name: 'subscription_history',
              builder: (context, state) => const SubscriptionHistoryScreen(),
            ),
            GoRoute(
              path: 'new',
              name: 'subscription_new',
              builder: (context, state) => const SubscriptionScreenNew(),
            ),
          ],
        ),
        GoRoute(
          path: '/subscription-new',
          name: 'subscription_screen_new',
          builder: (context, state) => const SubscriptionScreenNew(),
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
  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.call,
    routes: notifier.routes,
  );

  // When the user opens the password-reset link from their email,
  // supabase_flutter consumes the deep link, establishes a recovery session,
  // and fires this event - take them straight to the set-new-password screen.
  final recoverySub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      router.go('/update-password');
    }
  });
  ref.onDispose(recoverySub.cancel);

  return router;
});
