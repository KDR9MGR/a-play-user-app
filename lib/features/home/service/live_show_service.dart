import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/live_show_model.dart';

class LiveShowService {
  final supabase = Supabase.instance.client;

  Future<List<LiveShow>> getLiveShows({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('live_shows')
        .select()
        .order(sortBy ?? 'show_date', ascending: ascending);

    return response.map((json) => LiveShow.fromJson(json)).toList();
  }

  Future<LiveShow?> getLiveShowById(String id) async {
    final response = await supabase
        .from('live_shows')
        .select()
        .eq('id', id)
        .single();
    return LiveShow.fromJson(response);
  }

  Future<List<LiveShow>> getFeaturedLiveShows() async {
    final response = await supabase
        .from('live_shows')
        .select()
        .eq('is_featured', true)
        .order('show_date', ascending: true)
        .limit(8);

    return response.map((json) => LiveShow.fromJson(json)).toList();
  }

  Future<List<LiveShow>> getUpcomingLiveShows() async {
    final response = await supabase
        .from('live_shows')
        .select()
        .gte('show_date', DateTime.now().toIso8601String().split('T')[0])
        .order('show_date', ascending: true)
        .limit(10);

    return response.map((json) => LiveShow.fromJson(json)).toList();
  }

  Future<List<LiveShow>> getLiveShowsByType(String showType) async {
    final response = await supabase
        .from('live_shows')
        .select()
        .eq('show_type', showType)
        .order('show_date', ascending: true)
        .limit(10);

    return response.map((json) => LiveShow.fromJson(json)).toList();
  }
}