import 'package:flutter/foundation.dart';

@immutable
class Club {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;

  const Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.createdAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Club &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      logoUrl,
      createdAt,
    );
  }
} 