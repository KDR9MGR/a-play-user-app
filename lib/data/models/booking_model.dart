import 'package:flutter/foundation.dart';

@immutable
class BookingModel {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String eventEndDate;
  final String zoneId;
  final DateTime bookingDate;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final String? eventCoverImage;
  final String? zoneName;
  final double? amount;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventEndDate,
    required this.zoneId,
    required this.bookingDate,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.eventCoverImage,
    this.zoneName,
    this.amount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      eventTitle: json['events']?['title'] as String,
      eventEndDate: json['events']?['end_date'] as String,
      zoneId: json['zone_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      eventCoverImage: json['events']?['cover_image'] as String?,
      zoneName: json['zones']?['name'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'zone_id': zoneId,
      'booking_date': bookingDate.toIso8601String(),
      'quantity': quantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'amount': amount,
      'events': {
        'cover_image': eventCoverImage,
        'title': eventTitle,
        'end_date': eventEndDate,
      },
      'zones': {
        'name': zoneName,
      },
    };
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, userId: $userId, eventId: $eventId, zoneId: $zoneId, quantity: $quantity, status: $status, zoneName: $zoneName, eventEndDate: $eventEndDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel &&
        other.id == id &&
        other.userId == userId &&
        other.eventId == eventId &&
        other.zoneId == zoneId &&
        other.quantity == quantity &&
        other.bookingDate == bookingDate &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.eventCoverImage == eventCoverImage &&
        other.zoneName == zoneName &&
        other.amount == amount &&
        other.eventTitle == eventTitle &&
        other.eventEndDate == eventEndDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      eventId,
      zoneId,
      quantity,
      bookingDate,
      status,
      createdAt,
      eventCoverImage,
      zoneName,
      amount,
      eventTitle,
      eventEndDate,
    );
  }
} 