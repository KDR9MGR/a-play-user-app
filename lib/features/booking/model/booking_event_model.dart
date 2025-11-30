import 'package:equatable/equatable.dart';

class BookingEventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String clubId;
  final String coverImage;
  final DateTime createdAt;

  const BookingEventModel({
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
  
  @override
  List<Object?> get props => [id, title, description, location, startDate, endDate, clubId, coverImage, createdAt];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookingEventModel) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
  