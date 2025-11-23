import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/pub_model.dart';

class PubService {
  final supabase = Supabase.instance.client;

  Future<List<Pub>> getPubs({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('pubs')
        .select()
        .order(sortBy ?? 'name', ascending: ascending);

    return response.map((json) => Pub.fromJson(json)).toList();
  }

  Future<Pub?> getPubById(String id) async {
    final response = await supabase
        .from('pubs')
        .select()
        .eq('id', id)
        .single();
    return Pub.fromJson(response);
  }

  Future<List<Pub>> getFeaturedPubs() async {
    final response = await supabase
        .from('pubs')
        .select()
        .eq('is_featured', true)
        .order('average_rating', ascending: false)
        .limit(8);

    return response.map((json) => Pub.fromJson(json)).toList();
  }

  Future<List<Pub>> getPopularPubs() async {
    final response = await supabase
        .from('pubs')
        .select()
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => Pub.fromJson(json)).toList();
  }

  Future<List<Pub>> getSportsViewingPubs() async {
    final response = await supabase
        .from('pubs')
        .select()
        .eq('has_sports_viewing', true)
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => Pub.fromJson(json)).toList();
  }
}