import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/beach_model.dart';

class BeachService {
  final supabase = Supabase.instance.client;

  Future<List<Beach>> getBeaches({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('beaches')
        .select()
        .order(sortBy ?? 'name', ascending: ascending);

    return response.map((json) => Beach.fromJson(json)).toList();
  }

  Future<Beach?> getBeachById(String id) async {
    final response = await supabase
        .from('beaches')
        .select()
        .eq('id', id)
        .single();
    return Beach.fromJson(response);
  }

  Future<List<Beach>> getFeaturedBeaches() async {
    final response = await supabase
        .from('beaches')
        .select()
        .eq('is_featured', true)
        .order('average_rating', ascending: false)
        .limit(8);

    return response.map((json) => Beach.fromJson(json)).toList();
  }

  Future<List<Beach>> getPopularBeaches() async {
    final response = await supabase
        .from('beaches')
        .select()
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => Beach.fromJson(json)).toList();
  }

  Future<List<Beach>> getWaterSportsBeaches() async {
    final response = await supabase
        .from('beaches')
        .select()
        .eq('has_water_sports', true)
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => Beach.fromJson(json)).toList();
  }
}