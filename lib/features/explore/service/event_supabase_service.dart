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
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabase
          .from('events')
          .select('*')
          .gt('end_date', now)
          .order('start_date')
          .limit(50) // Limit results for better performance
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print('Timeout fetching events');
              }
              throw Exception('NETWORK_TIMEOUT');
            },
          );
      return response.map((json) => ServiceEventModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events: $e');
      }
      // Throw specific error types for better UI handling
      if (e.toString().contains('NETWORK_TIMEOUT') || e.toString().contains('SocketException')) {
        throw Exception('NETWORK_ERROR');
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select('*')
          .order('name')
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print('Timeout fetching categories');
              }
              throw Exception('NETWORK_TIMEOUT');
            },
          );
      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      // Throw specific error types for better UI handling
      if (e.toString().contains('NETWORK_TIMEOUT') || e.toString().contains('SocketException')) {
        throw Exception('NETWORK_ERROR');
      }
      rethrow;
    }
  }

  Future<List<ServiceEventModel>> getEventsByCategory(String categoryName) async {
    try {
      final now = DateTime.now().toIso8601String();

      if (kDebugMode) {
        print('Fetching events for category: $categoryName');
      }

      if (categoryName.toLowerCase() == 'all') {
        // Get all active events - NO authentication required (Apple Guideline 5.1.1)
        final eventsResponse = await supabase
            .from('events')
            .select('*')
            .gt('end_date', now)
            .order('start_date')
            .limit(50) // Limit results to improve performance on iPad
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                if (kDebugMode) {
                  print('Timeout fetching events');
                }
                throw Exception('NETWORK_TIMEOUT');
              },
            );

        if (kDebugMode) {
          print('Fetched ${eventsResponse.length} events');
        }

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
          .maybeSingle() // Use maybeSingle to handle missing categories gracefully
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print('Timeout fetching category');
              }
              throw Exception('NETWORK_TIMEOUT');
            },
          );

      if (categoryResponse == null) {
        if (kDebugMode) {
          print('Category not found: $categoryName');
        }
        return []; // Empty result is valid for missing categories
      }

      final categoryId = categoryResponse['id'];

      // Get event IDs for this category
      final eventCategoryResponse = await supabase
          .from('event_categories')
          .select('event_id')
          .eq('category_id', categoryId)
          .limit(50) // Limit results
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print('Timeout fetching event categories');
              }
              throw Exception('NETWORK_TIMEOUT');
            },
          );

      final eventIds = eventCategoryResponse.map((item) => item['event_id']).toList();

      if (eventIds.isEmpty) {
        if (kDebugMode) {
          print('No events found for category: $categoryName');
        }
        return []; // Empty result is valid
      }

      // Get active events with these IDs
      final eventsResponse = await supabase
          .from('events')
          .select('*')
          .inFilter('id', eventIds)
          .gt('end_date', now)
          .order('start_date')
          .limit(50) // Limit results
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                print('Timeout fetching events');
              }
              throw Exception('NETWORK_TIMEOUT');
            },
          );

      if (kDebugMode) {
        print('Fetched ${eventsResponse.length} events for category $categoryName');
      }

      // Convert to ServiceEventModel with category_name
      return eventsResponse.map((json) {
        final eventJson = Map<String, dynamic>.from(json);
        eventJson['category_name'] = categoryName;
        return ServiceEventModel.fromJson(eventJson);
      }).toList();

    } catch (error) {
      // Throw specific errors instead of silently returning empty list
      // This allows UI to show proper error messages (fixes iPad Air error display)
      if (kDebugMode) {
        print('Error fetching events by category $categoryName: $error');
      }
      // Check for network-related errors
      if (error.toString().contains('NETWORK_TIMEOUT') ||
          error.toString().contains('SocketException') ||
          error.toString().contains('Connection reset')) {
        throw Exception('NETWORK_ERROR');
      }
      rethrow;
    }
  }
}
