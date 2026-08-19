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

  /// Social auth intent enforcement. `signInWithIdToken` is Supabase's
  /// combined sign-in-or-sign-up: it silently CREATES an account when none
  /// exists. That caused two real bugs before the social buttons were pulled
  /// from the UI: tapping "sign in" without an account logged you straight
  /// into a brand-new empty account, and "sign up" with an existing account
  /// gave no indication it already existed. This restores the distinction:
  /// - sign-in intent + account didn't exist -> the accidentally created
  ///   account is deleted again (delete-account edge function), session is
  ///   dropped, and a clear "please sign up first" error is thrown.
  /// - sign-up intent + account already existed -> session is dropped and a
  ///   clear "already exists, please sign in" error is thrown.
  /// New-account detection compares the server-side created_at and
  /// last_sign_in_at timestamps (both set by Supabase, so no client clock
  /// skew): they only coincide on the very first sign-in.
  Future<bool> _enforceSocialAuthIntent({
    required User user,
    required bool isSignUp,
    required String providerLabel,
  }) async {
    final createdAt = DateTime.parse(user.createdAt);
    final lastSignIn =
        user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : createdAt;
    final isNewAccount = lastSignIn.difference(createdAt).inSeconds.abs() < 15;

    if (!isSignUp && isNewAccount) {
      debugPrint('[AUTH-PROVIDER] Sign-in intent but no pre-existing account - undoing implicit signup');
      try {
        await _client.functions.invoke('delete-account');
      } catch (e) {
        debugPrint('[AUTH-PROVIDER] Cleanup of implicit account failed (non-critical): $e');
      }
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
      throw AuthException(
        'No account found for this $providerLabel account. Please sign up first.',
      );
    }

    if (isSignUp && !isNewAccount) {
      debugPrint('[AUTH-PROVIDER] Sign-up intent but account already exists');
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
      throw AuthException(
        'An account with this $providerLabel account already exists. Please sign in instead.',
      );
    }

    return isNewAccount;
  }

  Future<void> signInWithGoogle({required bool isSignUp}) async {
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

      debugPrint('🔵 [AUTH-PROVIDER] ✓ Supabase user authenticated: ${user.email} (ID: ${user.id})');

      // Enforce sign-in vs sign-up intent (throws on mismatch)
      final isNewUser = await _enforceSocialAuthIntent(
        user: user,
        isSignUp: isSignUp,
        providerLabel: 'Google',
      );

      // Profile is normally created by the handle_new_user DB trigger;
      // create manually only as a fallback if it's somehow missing.
      final profile = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
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
          debugPrint('🔵 [AUTH-PROVIDER] ✓ Profile created manually');
        } catch (e) {
          debugPrint('🔵 [AUTH-PROVIDER] ✗ Failed to create profile: $e');
          throw AuthException('Failed to create user profile: ${e.toString()}');
        }
      }

      // Send welcome email for new OAuth users
      if (isNewUser && user.email != null && user.email!.isNotEmpty) {
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

  Future<void> signInWithApple({required bool isSignUp}) async {
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

      debugPrint('🍎 [AUTH-PROVIDER] ✓ Supabase user authenticated: ${user.email ?? "no-email"} (ID: ${user.id})');

      // Enforce sign-in vs sign-up intent (throws on mismatch)
      final isNewUser = await _enforceSocialAuthIntent(
        user: user,
        isSignUp: isSignUp,
        providerLabel: 'Apple',
      );

      // Profile is normally created by the handle_new_user DB trigger;
      // create manually only as a fallback if it's somehow missing.
      final profile = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
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
          debugPrint('🍎 [AUTH-PROVIDER] ✓ Profile created manually');
        } catch (e) {
          debugPrint('🍎 [AUTH-PROVIDER] ✗ Failed to create profile: $e');
          throw AuthException('Failed to create user profile: ${e.toString()}');
        }
      } else if (fullName != null && fullName.isNotEmpty) {
        // Apple only provides the name on the FIRST authorization, so persist
        // it whenever we do get one.
        try {
          await _client.from('profiles').update({
            'full_name': fullName,
          }).eq('id', user.id);
          debugPrint('🍎 [AUTH-PROVIDER] ✓ Profile updated with Apple name');
        } catch (e) {
          debugPrint('🍎 [AUTH-PROVIDER] ⚠ Failed to update profile name (non-critical): $e');
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
      
      // Same reasoning as resetPassword's redirectUrl below: a plain https
      // link always opens reliably, unlike the old io.supabase.aplay://
      // custom scheme (server-redirected links to a non-http(s) scheme are
      // unreliable in Safari/Mail). Without this, Supabase falls back to the
      // bare site_url - the user lands on the plain homepage with no
      // acknowledgment that their email was actually confirmed.
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://www.aplayworld.com/confirm-email',
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

      // Always use the web reset-password page, even from the mobile app.
      // The custom io.supabase.aplay:// scheme used to be used on mobile,
      // but Supabase's /verify endpoint does a server-side 303 redirect to
      // it, and Safari/Mail are unreliable about following a redirect to a
      // non-http(s) scheme (as opposed to a direct link tap, which works
      // fine) - in practice this meant the reset link would silently land
      // back on the site's homepage instead of opening the app. A plain
      // https:// link always opens reliably; the web page itself (already
      // built, aplayworld.com/reset-password) lets the user set their new
      // password right there in the browser, then they just return to the
      // app and log in - no deep link handoff required at all.
      final redirectUrl = 'https://www.aplayworld.com/reset-password';

      debugPrint('🔑 [RESET] Using redirect URL: $redirectUrl');

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      debugPrint('🔑 [RESET] ✓ Password reset email sent');
      // NOTE: no additional custom email here. Supabase's own reset email
      // carries the actual recovery token; a second branded email with a
      // tokenless link only confuses users into tapping the dead one.
    } catch (e) {
      // Propagate the error to the UI
      rethrow;
    }
  }

  /// Sets a new password for the current session. Used by the
  /// update-password screen after a passwordRecovery deep link established
  /// a recovery session.
  Future<void> updatePassword(String newPassword) async {
    _validatePasswordOrThrow(newPassword);
    await _client.auth.updateUser(UserAttributes(password: newPassword));
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
  /// This permanently removes the user's account and data from Supabase via
  /// the delete-account edge function: the caller is identified from their
  /// JWT server-side, user data is cleaned up with the service role, and the
  /// auth user itself is deleted (profiles + dependents cascade from it).
  /// Client-side table deletes were removed - they were silently blocked by
  /// RLS and never actually deleted anything.
  Future<void> deleteAccount() async {
    try {
      state = const AsyncValue.loading();

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user logged in');
      }

      final response = await _client.functions.invoke('delete-account');
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        final message = data is Map ? (data['error'] ?? 'Unknown error') : 'Unknown error';
        throw AuthException('Account deletion failed: $message');
      }

      // The server already deleted the auth user - just clear local session
      // state. signOut may fail since the user no longer exists; ignore it.
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}

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
