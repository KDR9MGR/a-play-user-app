import 'package:a_play/data/models/event_model.dart';
import 'package:a_play/features/search/service/search_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  final client = Supabase.instance.client;
  return SearchService(client);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<EventModel>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  if (searchQuery.isEmpty) {
    return [];
  }
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchEvents(searchQuery);
}); 