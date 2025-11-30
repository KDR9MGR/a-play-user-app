import 'package:a_play/data/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchService {
  final SupabaseClient _client;

  SearchService(this._client);

  Future<List<EventModel>> searchEvents(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await _client
          .from('events')
          .select()
          .ilike('title', '%$query%')
          .order('start_date', ascending: true)
          .limit(20);

      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error searching events: $e');
      return [];
    }
  }
} 