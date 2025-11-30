import 'package:flutter/foundation.dart';

@immutable
class Zone {
  final String id;
  final String eventId;
  final String name;
  final double price;
  final int capacity;
  final DateTime createdAt;

  const Zone({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.capacity,
    required this.createdAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      capacity: json['capacity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'price': price,
      'capacity': capacity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Zone copyWith({
    String? id,
    String? eventId,
    String? name,
    double? price,
    int? capacity,
    DateTime? createdAt,
  }) {
    return Zone(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Zone &&
        other.id == id &&
        other.eventId == eventId &&
        other.name == name &&
        other.price == price &&
        other.capacity == capacity &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      eventId,
      name,
      price,
      capacity,
      createdAt,
    );
  }
} 