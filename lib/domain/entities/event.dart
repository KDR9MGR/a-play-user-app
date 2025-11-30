class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime endDate;
  final String location;
  final double price;
  final String imageUrl;
  final String category;
  final int capacity;
  final int registeredCount;
  final bool isFeatured;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.endDate,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.capacity,
    required this.registeredCount,
    this.isFeatured = false,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
} 