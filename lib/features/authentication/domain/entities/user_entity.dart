import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastSignInTime,
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        lastSignInTime,
        isEmailVerified,
      ];

  bool get isAnonymous => email == null;
} 