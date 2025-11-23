import 'package:a_play/features/explore/model/event_by_category_model.dart';
import 'package:a_play/features/explore/model/service_event_model.dart';
import 'package:a_play/features/explore/model/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Category Provider
final categoryProvider = Provider<EventSupabaseService>((ref) {
  return EventSupabaseService();
});

// Event by category Provider
final eventByCategoryProvider = Provider.family<EventByCategoryService, String>((ref, categoryName) {
  return EventByCategoryService(categoryName);
});

class EventByCategoryService {
  final supabase = Supabase.instance.client;
  final String categoryName;  

  EventByCategoryService(this.categoryName);

  Future<List<EventByCategoryModel>> getEventsByCategory() async {
    final response = await supabase
        .from('events_with_categories')
        .select('*')
        .eq('category_name', categoryName);
    return response.map((json) => EventByCategoryModel.fromJson(json)).toList();
  }
}

class EventSupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<ServiceEventModel>> getEvents() async {
    final now = DateTime.now().toIso8601String();
    final response = await supabase
        .from('events')
        .select('*')
        .gt('end_date', now)
        .order('start_date');
    return response.map((json) => ServiceEventModel.fromJson(json)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select('*')
        .order('name');
    return response.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<List<ServiceEventModel>> getEventsByCategory(String categoryName) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      if (categoryName.toLowerCase() == 'all') {
        // Get all active events
        final eventsResponse = await supabase
            .from('events')
            .select('*')
            .gt('end_date', now)
            .order('start_date');
        
        // Convert to ServiceEventModel with category_name as null
        return eventsResponse.map((json) {
          final eventJson = Map<String, dynamic>.from(json);
          eventJson['category_name'] = null; // No specific category for "All"
          return ServiceEventModel.fromJson(eventJson);
        }).toList();
      }
      
      // For specific categories, use a direct SQL approach through RPC or create a view
      // First, get the category ID
      final categoryResponse = await supabase
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .single();
      
      final categoryId = categoryResponse['id'];
      
      // Get event IDs for this category
      final eventCategoryResponse = await supabase
          .from('event_categories')
          .select('event_id')
          .eq('category_id', categoryId);
      
      final eventIds = eventCategoryResponse.map((item) => item['event_id']).toList();
      
      if (eventIds.isEmpty) {
        return [];
      }
      
      // Get active events with these IDs
      final eventsResponse = await supabase
          .from('events')
          .select('*')
          .inFilter('id', eventIds)
          .gt('end_date', now)
          .order('start_date');
      
      // Convert to ServiceEventModel with category_name
      return eventsResponse.map((json) {
        final eventJson = Map<String, dynamic>.from(json);
        eventJson['category_name'] = categoryName;
        return ServiceEventModel.fromJson(eventJson);
      }).toList();
      
    } catch (error) {
      // Return empty list instead of crashing the UI (fixes iPad Air content loading issue)
      // This ensures the app remains usable even if one category fails to load
      if (kDebugMode) {
        print('Error fetching events by category: $error');
      }
      return [];
    }
  }
}
