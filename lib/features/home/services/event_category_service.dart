import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_category.dart';

class EventCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Simple test method to check connectivity
  Future<void> testConnection() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('count')
          .limit(1);
      print('Connection test successful: $response');
    } catch (e) {
      print('Connection test failed: $e');
    }
  }

  // Get all active event categories
  Future<List<EventCategory>> getEventCategories() async {
    try {
      print('Fetching event categories...'); // Debug
      
      final response = await _supabase
          .from('categories')
          .select('id, name, display_name, icon, color, sort_order, is_active, created_at, updated_at')
          .like('name', '%_events')
          .eq('is_active', true)
          .order('sort_order');

      print('Raw response: $response');

      List<Map<String, dynamic>> responseList;
      responseList = List<Map<String, dynamic>>.from(response);
    
      if (responseList.isEmpty) {
        print('Response is empty');
        return _getFallbackCategories();
      }

      print('Processing ${responseList.length} categories'); // Debug

      return responseList.map((item) {
        print('Processing item: $item'); // Debug
        return EventCategory.fromJson({
          'id': item['id']?.toString() ?? '',
          'name': item['name']?.toString() ?? '',
          'displayName': item['display_name']?.toString() ?? '',
          'icon': item['icon']?.toString(),
          'color': item['color']?.toString(),
          'sortOrder': item['sort_order'] ?? 0,
          'isActive': item['is_active'] ?? true,
          'createdAt': _formatDateTimeForJson(item['created_at']),
          'updatedAt': _formatDateTimeForJson(item['updated_at']),
        });
      }).toList();
    } catch (e) {
      print('EventCategoryService Error: $e'); // Debug print
      print('Falling back to default categories');
      return _getFallbackCategories();
    }
  }

  // Fallback categories in case database fails
  List<EventCategory> _getFallbackCategories() {
    return [
      EventCategory(
        id: 'fallback_all',
        name: 'all_events',
        displayName: 'All Events',
        icon: 'calendar',
        color: '#FF6B6B',
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      EventCategory(
        id: 'fallback_music',
        name: 'music_events',
        displayName: 'Music Events',
        icon: 'music',
        color: '#4ECDC4',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      EventCategory(
        id: 'fallback_nightlife',
        name: 'nightlife_events',
        displayName: 'Nightlife',
        icon: 'moon',
        color: '#45B7D1',
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // Get events by category
  Future<List<Map<String, dynamic>>> getEventsByCategory(String categoryId) async {
    try {
      print('Fetching events for category: $categoryId'); // Debug

      // If "all_events" category, return all events
      if (categoryId == 'all' || categoryId == 'fallback_all') {
        final response = await _supabase
            .from('events')
            .select('*')
            .order('start_date');
        return List<Map<String, dynamic>>.from(response);
      }

      // Use a simpler approach: get event IDs from junction table first
      final eventCategoriesResponse = await _supabase
          .from('event_categories')
          .select('event_id')
          .eq('category_id', categoryId);

      final eventIds = List<Map<String, dynamic>>.from(eventCategoriesResponse)
          .map((item) => item['event_id'])
          .toList();

      if (eventIds.isEmpty) {
        print('No events found for category: $categoryId');
        return [];
      }

      // Get events by IDs
      final response = await _supabase
          .from('events')
          .select('*')
          .inFilter('id', eventIds)
          .order('start_date');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events by category: $e'); // Debug
      throw Exception('Failed to fetch events by category: $e');
    }
  }

  // Get category by name
  Future<EventCategory?> getCategoryByName(String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name, display_name, icon, color, sort_order, is_active, created_at, updated_at')
          .eq('name', name)
          .maybeSingle();

      if (response == null) {
        // Check if it's a fallback category
        final fallbackCategories = _getFallbackCategories();
        try {
          return fallbackCategories.firstWhere((cat) => cat.name == name);
        } catch (e) {
          return null;
        }
      }

      return EventCategory.fromJson({
        'id': response['id']?.toString() ?? '',
        'name': response['name']?.toString() ?? '',
        'displayName': response['display_name']?.toString() ?? '',
        'icon': response['icon']?.toString(),
        'color': response['color']?.toString(),
        'sortOrder': response['sort_order'] ?? 0,
        'isActive': response['is_active'] ?? true,
        'createdAt': _formatDateTimeForJson(response['created_at']),
        'updatedAt': _formatDateTimeForJson(response['updated_at']),
      });
    } catch (e) {
      print('Error fetching category by name: $e'); // Debug
      return null;
    }
  }

  // Add event to category
  Future<void> addEventToCategory(String eventId, String categoryId) async {
    try {
      await _supabase.from('event_categories').insert({
        'event_id': eventId,
        'category_id': categoryId,
      });
    } catch (e) {
      throw Exception('Failed to add event to category: $e');
    }
  }

  // Remove event from category
  Future<void> removeEventFromCategory(String eventId, String categoryId) async {
    try {
      await _supabase
          .from('event_categories')
          .delete()
          .eq('event_id', eventId)
          .eq('category_id', categoryId);
    } catch (e) {
      throw Exception('Failed to remove event from category: $e');
    }
  }

  String _formatDateTimeForJson(dynamic dateTime) {
    if (dateTime == null) return DateTime.now().toIso8601String();
    if (dateTime is String) return dateTime;
    if (dateTime is DateTime) return dateTime.toIso8601String();
    return DateTime.now().toIso8601String();
  }
} 