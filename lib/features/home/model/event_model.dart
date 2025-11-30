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

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.clubId,
    required this.coverImage,
    required this.createdAt,
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
    );
  }

  //To Json 
  Map<String, dynamic> toJson() {
    return {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'start_time': startDate,
        'end_time': endDate,
        'club_id': clubId,
        'cover_image': coverImage,
        'created_at': createdAt,
    };
  }

  //From Json
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_time'],
      endDate: json['end_time'],
      clubId: json['club_id'],
      coverImage: json['cover_image'],
      createdAt: json['created_at'],
    );
  }

  @override
  // TODO: implement props
    List<Object?> get props => [id, title, description, location, startDate, endDate, clubId, coverImage, createdAt];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventModel) return false;
    return id == other.id;
  }
  
}