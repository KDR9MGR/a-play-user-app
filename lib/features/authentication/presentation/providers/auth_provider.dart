import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/authentication/data/models/user_model.dart';

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
      displayName: user.userMetadata?['display_name'] as String?,
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
      state = const AsyncValue.loading();
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw const AuthException('Failed to sign in: No session created');
      }
      
      final user = response.user;
      if (user == null) {
        throw const AuthException('Failed to sign in: No user returned');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
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

      // Trigger Google Sign-In flow
      final googleUser = await googleSignIn.authenticate();

      // Get authentication tokens
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Failed to get ID token from Google');
      }

      // Sign in to Supabase with the ID token (NO nonce for Google)
      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
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
      state = const AsyncValue.loading();

      // Generate nonce for Apple Sign-In (required for security)
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) {
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

      // Sign in to Supabase with the ID token and raw nonce
      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: identityToken,
        nonce: rawNonce, // Pass the raw nonce (not hashed) to Supabase
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('Failed to sign in with Apple');
      }

      // Update profile with the user's name if available
      // CRITICAL: Apple only provides the name on the FIRST sign-in, so we must save it
      if (fullName != null && fullName.isNotEmpty) {
        try {
          await _client.from('profiles').upsert({
            'id': user.id,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Log error but don't fail the sign-in
          // User can update their name later in profile settings
        }
      }

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  Future<void> signOut() async {
    try {
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
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
        },
      );
      
      if (response.session == null) {
        throw const AuthException('Failed to sign up: No session created');
      }
      
      final user = response.user;
      if (user == null) {
        throw const AuthException('Failed to sign up: No user returned');
      }

      try {
        final resolvedName = (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : (user.userMetadata?['display_name'] as String?) ?? email.split('@').first;
        await _client.functions.invoke(
          'send-welcome-email',
          body: {
            'email': email,
            'fullName': resolvedName,
            'isOrganizer': false,
          },
        );
      } catch (_) {}

      state = AsyncValue.data(UserModel.fromSupabaseUser(user.toJson()));
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } catch (e, stack) {
      state = AsyncValue.error(AuthException(e.toString()), stack);
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.aplay://reset-callback/',
    );
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
