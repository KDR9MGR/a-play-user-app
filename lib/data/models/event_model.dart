import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
    final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String clubId;
  final String coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double price;
  final int capacity;
  final String status;
  final bool isFeatured;

  const EventModel({
      required this.id,
      required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.clubId = '',
    required this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.capacity,
    required this.status,
    this.isFeatured = false,
  });
  

  //Write a copyWith method
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? clubId,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? price,
    int? capacity,
    String? status,
    bool? isFeatured,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      clubId: clubId ?? this.clubId,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  //To Json 
  Map<String, dynamic> toJson() {
    return {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'club_id': clubId,
        'cover_image': coverImage,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'price': price,
        'capacity': capacity,
        'status': status,
        'is_featured': isFeatured,
    };
  }

  //From Json
  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
        return fallback;
      } catch (e) {
        return fallback;
      }
    }

    final now = DateTime.now();

    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Event',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: parseDate(json['start_date'], now),
      endDate: parseDate(json['end_date'], now.add(const Duration(hours: 3))),
      clubId: json['club_id'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      createdAt: parseDate(json['created_at'], now),
      updatedAt: parseDate(json['updated_at'], parseDate(json['created_at'], now)),
      price: (json['price'] as num? ?? 0).toDouble(),
      capacity: json['capacity'] as int? ?? 100, // Default capacity
      status: json['status'] as String? ?? 'active', // Default to active
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  @override
  // TODO: implement props
    List<Object?> get props => [id, title, description, location, startDate, endDate, clubId, coverImage, createdAt, updatedAt, price, capacity, status, isFeatured];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventModel) return false;
    return id == other.id;
  }
  
}