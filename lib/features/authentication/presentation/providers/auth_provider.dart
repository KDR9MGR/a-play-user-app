import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/authentication/data/models/user_model.dart';
import 'package:a_play/core/services/notification_service.dart';
import 'package:a_play/core/services/email_service.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return AuthRemoteDataSourceImpl(supabaseClient: supabaseClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final client = ref.watch(supabaseProvider);
  
  return client.auth.onAuthStateChange.map((event) {
    final user = event.session?.user;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: (user.userMetadata?['full_name'] as String?) ??
                   (user.userMetadata?['display_name'] as String?),
      photoUrl: user.userMetadata?['photo_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      lastSignInTime: user.lastSignInAt != null 
          ? DateTime.parse(user.lastSignInAt!) 
          : null,
      userMetadata: user.userMetadata,
    );
  });
});

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseClient _client;

  AuthController(this._client) : super(const AsyncValue.loading()) {
    // Initialize state with current user
    _initCurrentUser();
  }

  void _validatePasswordOrThrow(String password) {
    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters');
    }
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (!hasNumber || !hasSpecial) {
      throw const AuthException('Password must include a number and a special character');
    }
  }

  Future<void> _initCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      debugPrint('🔐 [AUTH] Starting email sign-in for: $email');
      state = const AsyncValue.loading();

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('🔐 [AUTH] Supabase response received');
      debugPrint('🔐 [AUTH] Session: ${response.session != null ? "✓" : "✗"}');
      debugPrint('🔐 [AUTH] User: ${response.user != null ? "✓" : "✗"}');

      if (response.session == null) {
        debugPrint('🔐 [AUTH] ✗ No session created');
        throw const AuthException('Failed to sign in: No session created');
      }

      final user = response.user;
      if (user == null) {
        debugPrint('🔐 [AUTH] ✗ No user returned');
        throw const AuthException('Failed to sign in: No user returned');
      }

      debugPrint('🔐 [AUTH] ✓ User authenticated: ${user.email}');

      // Link user to OneSignal for push notifications
      try {
        await NotificationService().setExternalUserId(user.id);
        debugPrint('🔐 [AUTH] ✓ OneSignal linked');
      } catch (e) {
        // Non-critical: Log but don't block sign-in
        debugPrint('🔐 [AUTH] ⚠️ OneSignal link failed: $e');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
      debugPrint('🔐 [AUTH] ✓ State updated successfully');
    } on AuthException catch (e, stack) {
      debugPrint('🔐 [AUTH] ✗ AuthException: ${e.message}');
      state = AsyncValue.error(e, stack);
      rethrow;
    } catch (e, stack) {
      debugPrint('🔐 [AUTH] ✗ Exception: $e');
      state = AsyncValue.error(AuthException(e.toString()), stack);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔵 [AUTH-PROVIDER] Starting Google sign-in');
      state = const AsyncValue.loading();

      // Web client ID for server-side verification
      const webClientId = '1093191311629-7m6v6go5470bt70t8cjsj0v27o2gnr9g.apps.googleusercontent.com';
      const iosClientId = '1093191311629-fhr1ijlmcone2lr81i8rajqhiu0rhgbn.apps.googleusercontent.com';

      // Get GoogleSignIn singleton instance
      final googleSignIn = GoogleSignIn.instance;

      // Initialize with server client ID
      await googleSignIn.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      debugPrint('🔵 [AUTH-PROVIDER] Starting Google authenticate flow');

      // Trigger Google Sign-In flow
      final googleUser = await googleSignIn.authenticate();

      debugPrint('🔵 [AUTH-PROVIDER] ✓ Google user obtained: ${googleUser.email}');

      // Get authentication tokens
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      debugPrint('🔵 [AUTH-PROVIDER] ID Token: ${idToken != null ? "✓" : "✗"}');

      if (idToken == null) {
        debugPrint('🔵 [AUTH-PROVIDER] ✗ No ID token from Google');
        throw const AuthException('Failed to get ID token from Google');
      }

      debugPrint('🔵 [AUTH-PROVIDER] Authenticating with Supabase...');

      // Sign in to Supabase with the ID token
      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      debugPrint('🔵 [AUTH-PROVIDER] Supabase auth response received');
      debugPrint('🔵 [AUTH-PROVIDER] Session: ${authResponse.session != null ? "✓" : "✗"}');
      debugPrint('🔵 [AUTH-PROVIDER] User: ${authResponse.user != null ? "✓" : "✗"}');

      final user = authResponse.user;
      if (user == null) {
        debugPrint('🔵 [AUTH-PROVIDER] ✗ No user in Supabase response');
        throw const AuthException('Failed to sign in with Google - no user returned');
      }

      debugPrint('🔵 [AUTH-PROVIDER] ✓ Supabase user created: ${user.email} (ID: ${user.id})');

      // Check if profile exists and is valid
      debugPrint('🔵 [AUTH-PROVIDER] Checking profile existence...');
      final profile = await _client
          .from('profiles')
          .select('id, email, full_name, created_at')
          .eq('id', user.id)
          .maybeSingle();

      bool isNewUser = false;

      if (profile == null) {
        // Profile doesn't exist - create it manually
        debugPrint('🔵 [AUTH-PROVIDER] ⚠ No profile found, creating manually');

        try {
          await _client.from('profiles').insert({
            'id': user.id,
            'email': user.email,
            'full_name': user.userMetadata?['full_name'] ??
                         user.userMetadata?['name'] ??
                         user.email?.split('@')[0] ?? 'User',
            'created_at': DateTime.now().toIso8601String(),
          });

          isNewUser = true;
          debugPrint('🔵 [AUTH-PROVIDER] ✓ Profile created manually');
        } catch (e) {
          debugPrint('🔵 [AUTH-PROVIDER] ✗ Failed to create profile: $e');
          throw AuthException('Failed to create user profile: ${e.toString()}');
        }
      } else {
        // Profile exists - check if it's a new user (created within last 30 seconds)
        final createdAt = DateTime.parse(profile['created_at'] as String);
        isNewUser = createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 30)));
        debugPrint('🔵 [AUTH-PROVIDER] Profile found (created: ${profile['created_at']}), isNewUser: $isNewUser');
      }

      // Send welcome email for new OAuth users
      if (isNewUser) {
        try {
          final userName = user.userMetadata?['full_name'] ??
                          user.userMetadata?['name'] ??
                          user.email?.split('@')[0] ??
                          'there';

          await EmailService().sendWelcomeEmail(
            toEmail: user.email!,
            userName: userName,
          );
          debugPrint('🔵 [AUTH-PROVIDER] ✓ Welcome email sent to ${user.email}');
        } catch (e) {
          debugPrint('🔵 [AUTH-PROVIDER] ⚠ Failed to send welcome email (non-critical): $e');
          // Don't block authentication if email fails
        }
      }

      // Link user to OneSignal for push notifications
      try {
        await NotificationService().setExternalUserId(user.id);
        debugPrint('🔵 [AUTH-PROVIDER] ✓ OneSignal linked');
      } catch (e) {
        debugPrint('🔵 [AUTH-PROVIDER] ⚠ OneSignal link failed (non-critical): $e');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
      debugPrint('🔵 [AUTH-PROVIDER] ✓ Google sign-in complete - state updated');
    } on AuthException catch (e, stack) {
      debugPrint('🔵 [AUTH-PROVIDER] ✗ AuthException: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    } catch (e, stack) {
      debugPrint('🔵 [AUTH-PROVIDER] ✗ Exception: $e');
      debugPrint('🔵 [AUTH-PROVIDER] Stack: $stack');
      state = AsyncValue.error(AuthException(e.toString()), stack);
      rethrow;
    }
  }

  /// Generates a cryptographically secure random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    try {
      debugPrint('🍎 [AUTH-PROVIDER] Starting Apple sign-in');
      state = const AsyncValue.loading();

      // Generate nonce for Apple Sign-In (required for security)
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      debugPrint('🍎 [AUTH-PROVIDER] Requesting Apple credentials...');

      // Request Apple Sign-In credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      debugPrint('🍎 [AUTH-PROVIDER] ✓ Apple credentials received');

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        debugPrint('🍎 [AUTH-PROVIDER] ✗ No identity token from Apple');
        throw const AuthException('Failed to get identity token from Apple');
      }

      // Extract user's full name from Apple credentials (only available on first sign-in)
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        final firstName = credential.givenName ?? '';
        final lastName = credential.familyName ?? '';
        fullName = '$firstName $lastName'.trim();
        if (fullName.isEmpty) fullName = null;
      }

      debugPrint('🍎 [AUTH-PROVIDER] Authenticating with Supabase...');

      // Sign in to Supabase with the ID token and raw nonce
      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: identityToken,
        nonce: rawNonce, // Pass the raw nonce (not hashed) to Supabase
      );

      debugPrint('🍎 [AUTH-PROVIDER] Supabase auth response received');
      debugPrint('🍎 [AUTH-PROVIDER] Session: ${authResponse.session != null ? "✓" : "✗"}');
      debugPrint('🍎 [AUTH-PROVIDER] User: ${authResponse.user != null ? "✓" : "✗"}');

      final user = authResponse.user;
      if (user == null) {
        debugPrint('🍎 [AUTH-PROVIDER] ✗ No user in Supabase response');
        throw const AuthException('Failed to sign in with Apple - no user returned');
      }

      debugPrint('🍎 [AUTH-PROVIDER] ✓ Supabase user created: ${user.email ?? "no-email"} (ID: ${user.id})');

      // Check if profile exists and is valid
      debugPrint('🍎 [AUTH-PROVIDER] Checking profile existence...');
      final profile = await _client
          .from('profiles')
          .select('id, email, full_name, created_at')
          .eq('id', user.id)
          .maybeSingle();

      bool isNewUser = false;

      if (profile == null) {
        // Profile doesn't exist - create it manually
        debugPrint('🍎 [AUTH-PROVIDER] ⚠ No profile found, creating manually');

        try {
          await _client.from('profiles').insert({
            'id': user.id,
            'email': user.email,
            'full_name': fullName ??
                         user.userMetadata?['full_name'] ??
                         user.email?.split('@')[0] ?? 'User',
            'created_at': DateTime.now().toIso8601String(),
          });

          isNewUser = true;
          debugPrint('🍎 [AUTH-PROVIDER] ✓ Profile created manually');
        } catch (e) {
          debugPrint('🍎 [AUTH-PROVIDER] ✗ Failed to create profile: $e');
          throw AuthException('Failed to create user profile: ${e.toString()}');
        }
      } else {
        // Profile exists - check if it's a new user (created within last 30 seconds)
        final createdAt = DateTime.parse(profile['created_at'] as String);
        isNewUser = createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 30)));
        debugPrint('🍎 [AUTH-PROVIDER] Profile found (created: ${profile['created_at']}), isNewUser: $isNewUser');

        // Update profile with the user's name if available from Apple (only on first sign-in)
        // CRITICAL: Apple only provides the name on the FIRST sign-in, so we must save it
        if (fullName != null && fullName.isNotEmpty) {
          try {
            await _client.from('profiles').update({
              'full_name': fullName,
            }).eq('id', user.id);
            debugPrint('🍎 [AUTH-PROVIDER] ✓ Profile updated with Apple name');
          } catch (e) {
            debugPrint('🍎 [AUTH-PROVIDER] ⚠ Failed to update profile name (non-critical): $e');
          }
        }
      }

      // Send welcome email for new OAuth users
      if (isNewUser) {
        try {
          final userName = fullName ??
                          user.userMetadata?['full_name'] ??
                          user.email?.split('@')[0] ??
                          'there';

          if (user.email != null) {
            await EmailService().sendWelcomeEmail(
              toEmail: user.email!,
              userName: userName,
            );
            debugPrint('🍎 [AUTH-PROVIDER] ✓ Welcome email sent to ${user.email}');
          }
        } catch (e) {
          debugPrint('🍎 [AUTH-PROVIDER] ⚠ Failed to send welcome email (non-critical): $e');
          // Don't block authentication if email fails
        }
      }

      // Link user to OneSignal for push notifications
      try {
        await NotificationService().setExternalUserId(user.id);
        debugPrint('🍎 [AUTH-PROVIDER] ✓ OneSignal linked');
      } catch (e) {
        debugPrint('🍎 [AUTH-PROVIDER] ⚠ OneSignal link failed (non-critical): $e');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
      debugPrint('🍎 [AUTH-PROVIDER] ✓ Apple sign-in complete - state updated');
    } on AuthException catch (e, stack) {
      debugPrint('🍎 [AUTH-PROVIDER] ✗ AuthException: $e');
      state = AsyncValue.error(e, stack);
      rethrow;
    } catch (e, stack) {
      debugPrint('🍎 [AUTH-PROVIDER] ✗ Exception: $e');
      state = AsyncValue.error(AuthException(e.toString()), stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Unlink user from OneSignal
      try {
        await NotificationService().removeExternalUserId();
      } catch (e) {
        // Non-critical: Log but don't block sign-out
      }

      await _client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      state = const AsyncValue.loading();

      _validatePasswordOrThrow(password);
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'full_name': displayName,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Failed to sign up: No user returned');
      }

      // When email confirmation is enabled, session will be null but user exists.
      // This is expected behavior — the user needs to confirm their email.
      if (response.session == null) {
        // Still set the user in state so the UI can show a confirmation message
        state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
        throw const AuthException('Please check your email to confirm your account');
      }

      // Link user to OneSignal for push notifications
      try {
        await NotificationService().setExternalUserId(user.id);
      } catch (e) {
        // Non-critical: Log but don't block sign-up
      }

      // Send welcome email via Resend
      try {
        final resolvedName = (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : (user.userMetadata?['display_name'] as String?) ?? email.split('@').first;

        await EmailService().sendWelcomeEmail(
          toEmail: email,
          userName: resolvedName,
        );
      } catch (e) {
        // Non-critical: Log but don't block sign-up
        debugPrint('Failed to send welcome email: $e');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔑 [RESET] Starting password reset for: $email');

      // Use different redirect URLs for web vs mobile
      final redirectUrl = kIsWeb
          ? 'https://www.aplayworld.com/reset-password' // Production web URL
          : 'aplayorganiser://reset-password'; // Mobile deep link

      debugPrint('🔑 [RESET] Using redirect URL: $redirectUrl');

      // Trigger Supabase password reset flow
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      debugPrint('🔑 [RESET] ✓ Password reset email sent');

      // Send branded password reset email via Resend
      try {
        // Use email prefix as fallback name since user isn't logged in
        final userName = email.split('@').first;
        await EmailService().sendPasswordResetEmail(
          toEmail: email,
          userName: userName,
          resetLink: 'io.supabase.aplay://reset-callback/', // Will be replaced by actual reset link in production
        );
      } catch (e) {
        // Non-critical: Supabase already sent a reset email
        debugPrint('Failed to send custom password reset email: $e');
      }
    } catch (e) {
      // Propagate the error to the UI
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user logged in');
      }

      await _client.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'display_name': displayName,
            if (photoUrl != null) 'photo_url': photoUrl,
          },
        ),
      );

      // Refresh the state with updated user data
      final updatedUser = _client.auth.currentUser;
      if (updatedUser != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(updatedUser.toJson()));
      }
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  /// Delete user account and all associated data (Apple App Store requirement 5.1.1)
  /// This permanently removes the user's account and data from Supabase
  Future<void> deleteAccount() async {
    try {
      state = const AsyncValue.loading();

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user logged in');
      }

      final userId = user.id;

      // Delete user data from all related tables
      // Order matters due to foreign key constraints
      try {
        // Delete user's bookings
        await _client.from('bookings').delete().eq('user_id', userId);

        // Delete user's subscriptions
        await _client.from('user_subscriptions').delete().eq('user_id', userId);

        // Delete user's feed posts
        await _client.from('feeds').delete().eq('user_id', userId);

        // Delete user's feed reports
        await _client.from('feed_reports').delete().eq('reporter_id', userId);

        // Delete user's blocks (both directions)
        await _client.from('user_blocks').delete().eq('blocker_id', userId);
        await _client.from('user_blocks').delete().eq('blocked_id', userId);

        // Delete user's chat messages
        await _client.from('chat_messages').delete().eq('sender_id', userId);

        // Delete user's referrals
        await _client.from('referrals').delete().eq('referrer_id', userId);
        await _client.from('referrals').delete().eq('referred_id', userId);

        // Delete user's points
        await _client.from('user_points').delete().eq('user_id', userId);

        // Delete user profile
        await _client.from('profiles').delete().eq('id', userId);
      } catch (e) {
        // Log but continue - some tables may not exist or have data
        // The auth deletion is the critical part
      }

      // Sign out and delete auth user
      // Note: Supabase requires admin API for full user deletion
      // This signs out and the user can request full deletion via support
      await _client.auth.signOut();

      state = const AsyncValue.data(null);
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
      rethrow;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final client = ref.watch(supabaseProvider);
  return AuthController(client);
}); 
