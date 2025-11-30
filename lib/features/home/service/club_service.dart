import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/club_model.dart';

class ClubService {
  final supabase = Supabase.instance.client;

  Future<List<Club>> getClubs({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('clubs')
        .select()
        .order('name', ascending: ascending);

    return response.map((json) => Club.fromJson(json)).toList();
  }

  Future<Club?> getClubById(String id) async {
    final response = await supabase
        .from('clubs')
        .select()
        .eq('id', id)
        .single();
    return Club.fromJson(response);
  }

  Future<List<Club>> getPopularClubs() async {
    final response = await supabase
        .from('clubs')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    return response.map((json) => Club.fromJson(json)).toList();
  }

  Future<List<Club>> getFeaturedClubs() async {
    final response = await supabase
        .from('clubs')
        .select()
        .order('name', ascending: true)
        .limit(8);

    return response.map((json) => Club.fromJson(json)).toList();
  }

  Future<List<Club>> getTopRatedClubs() async {
    final response = await supabase
        .from('clubs')
        .select()
        .order('name', ascending: true)
        .range(8, 15); // Skip first 8, get next 8

    return response.map((json) => Club.fromJson(json)).toList();
  }

  Future<List<Club>> getNewClubs() async {
    final response = await supabase
        .from('clubs')
        .select()
        .order('created_at', ascending: false)
        .range(10, 17); // Skip first 10, get next 8

    return response.map((json) => Club.fromJson(json)).toList();
  }
} 