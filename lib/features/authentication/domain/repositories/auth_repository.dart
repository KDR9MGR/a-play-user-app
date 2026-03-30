import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserEntity> signInWithGoogle();
  
  Future<void> signOut();
  
  Future<void> resetPassword(String email);
  
  Stream<UserEntity?> get authStateChanges;
} 