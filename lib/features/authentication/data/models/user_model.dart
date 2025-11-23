class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final Map<String, dynamic>? userMetadata;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastSignInTime,
    this.userMetadata,
  });

  factory UserModel.fromSupabaseUser(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['user_metadata']?['display_name'] as String?,
      photoUrl: json['user_metadata']?['photo_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      lastSignInTime: json['last_sign_in_at'] != null ? DateTime.parse(json['last_sign_in_at'] as String) : null,
      userMetadata: json['user_metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        'display_name': displayName,
        'photo_url': photoUrl,
      },
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInTime?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    Map<String, dynamic>? userMetadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      userMetadata: userMetadata ?? this.userMetadata,
    );
  }
} 