import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/domain/entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
}

class FirebaseEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() async {
    // TODO: Implement actual Firebase fetching
    // Returning mock data for now
    final now = DateTime.now();
    return [
      Event(
        id: '1',
        title: 'Law of Attraction',
        description: 'Learn the secrets of manifesting your dreams into reality',
        date: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 6)),
        location: 'Oberio Hotel',
        price: 49.99,
        imageUrl: 'assets/images/law_of_attraction.jpg',
        category: 'Self Development',
        capacity: 100,
        registeredCount: 75,
        isFeatured: true,
      ),
      Event(
        id: '2',
        title: 'Tech Conference 2024',
        description: 'Latest in technology and innovation',
        date: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 12)),
        location: 'Convention Center',
        price: 199.99,
        imageUrl: 'assets/images/tech_conf.jpg',
        category: 'Technology',
        capacity: 500,
        registeredCount: 300,
        isFeatured: true,
      ),
      Event(
        id: '3',
        title: 'Music Festival',
        description: 'A day of amazing music and fun!',
        date: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 2, hours: 8)),
        location: 'Central Park',
        price: 79.99,
        imageUrl: 'assets/images/music_fest.jpg',
        category: 'Music',
        capacity: 1000,
        registeredCount: 750,
        isFeatured: true,
      ),
    ];
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return FirebaseEventRepository();
}); 