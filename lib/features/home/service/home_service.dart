import 'package:a_play/data/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeService {
  final supabase = Supabase.instance.client;

  Future<List<EventModel>> getHomeEvents() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabase
          .from('events')
          .select()
          .gt('end_date', now)
          .order('start_date', ascending: true)
          .limit(20);

      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching home events: $e');
      }
      return [];
    }
  }

  Future<List<EventModel>> getFeaturedEvents() async {
    try {
      final now = DateTime.now().toIso8601String();
      if (kDebugMode) {
        print('Fetching featured events after: $now');
      }
      
      final response = await supabase
          .from('events')
          .select()
          .eq('is_featured', true)
          .gt('end_date', now)
          .order('start_date', ascending: true)
          .limit(10);
      
      if (kDebugMode) {
        print('Featured events response: ${response.length} events found');
        for (var event in response) {
          print('Event: ${event['title']} - End Date: ${event['end_date']}');
        }
      }
      
      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching featured events: $e');
      }
      return [];
    }
  }

  Future<List<EventModel>> getActiveEvents() async {
    return getHomeEvents();
  }

  Future<List<EventModel>> getWhatsHotTonightEvents() async {
    try {
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));
      
      final response = await supabase
          .from('events')
          .select()
          .gte('start_date', now.toIso8601String())
          .lte('start_date', threeDaysFromNow.toIso8601String())
          .order('start_date', ascending: true)
          .limit(4);

      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching what\'s hot tonight events: $e');
      }
      return [];
    }
  }

  Future<List<EventModel>> getCalendarEvents() async {
    try {
      final now = DateTime.now();
      final twoMonthsFromNow = now.add(const Duration(days: 60));
      
      final response = await supabase
          .from('events')
          .select()
          .gte('start_date', now.toIso8601String())
          .lte('start_date', twoMonthsFromNow.toIso8601String())
          .order('start_date', ascending: true);

      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching calendar events: $e');
      }
      return [];
    }
  }
}
