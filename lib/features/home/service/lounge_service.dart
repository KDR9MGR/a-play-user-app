import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/lounge_model.dart';

class LoungeService {
  final supabase = Supabase.instance.client;

  Future<List<Lounge>> getLounges({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('lounges')
        .select()
        .order(sortBy ?? 'name', ascending: ascending);

    return response.map((json) => Lounge.fromJson(json)).toList();
  }

  Future<Lounge?> getLoungeById(String id) async {
    final response = await supabase
        .from('lounges')
        .select()
        .eq('id', id)
        .single();
    return Lounge.fromJson(response);
  }

  Future<List<Lounge>> getFeaturedLounges() async {
    final response = await supabase
        .from('lounges')
        .select()
        .eq('is_featured', true)
        .order('average_rating', ascending: false)
        .limit(8);

    return response.map((json) => Lounge.fromJson(json)).toList();
  }

  Future<List<Lounge>> getPopularLounges() async {
    final response = await supabase
        .from('lounges')
        .select()
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => Lounge.fromJson(json)).toList();
  }
}