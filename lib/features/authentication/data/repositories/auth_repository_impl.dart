import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  UserEntity? _mapUserModelToEntity(UserModel? model) {
    if (model == null) return null;
    return UserEntity(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      photoUrl: model.photoUrl,
      createdAt: model.createdAt,
      lastSignInTime: model.lastSignInTime,
      isEmailVerified: model.userMetadata?['email_verified'] as bool? ?? false,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _remoteDataSource.getCurrentUser();
    return _mapUserModelToEntity(userModel);
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.signInWithEmail(email, password);
    return _mapUserModelToEntity(userModel)!;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final userModel = await _remoteDataSource.signUpWithEmail(
      email,
      password,
      displayName,
    );
    return _mapUserModelToEntity(userModel)!;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final userModel = await _remoteDataSource.signInWithGoogle();
    return _mapUserModelToEntity(userModel)!;
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _remoteDataSource.resetPassword(email);
  }

  @override
  Stream<UserEntity?> get authStateChanges => 
    _remoteDataSource.authStateChanges.map(_mapUserModelToEntity);
}