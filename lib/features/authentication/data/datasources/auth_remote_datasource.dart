import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String? displayName);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user.toJson());
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Failed to sign in');
    }
    
    return UserModel.fromSupabaseUser(response.user!.toJson());
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'full_name': displayName} : null,
    );
    
    if (response.user == null) {
      throw Exception('Failed to sign up');
    }
    
    return UserModel.fromSupabaseUser(response.user!.toJson());
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final response = await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.aplay://login-callback/',
    );
    
    if (!response) {
      throw Exception('Failed to sign in with Google');
    }
    
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Failed to get user after Google sign in');
    }
    
    return UserModel.fromSupabaseUser(user.toJson());
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.aplay://reset-callback/',
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user.toJson());
    });
  }
} 