import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/arcade_center_model.dart';

class ArcadeCenterService {
  final supabase = Supabase.instance.client;

  Future<List<ArcadeCenter>> getArcadeCenters({
    String? sortBy,
    bool ascending = true,
  }) async {
    final response = await supabase
        .from('arcade_centers')
        .select()
        .order(sortBy ?? 'name', ascending: ascending);

    return response.map((json) => ArcadeCenter.fromJson(json)).toList();
  }

  Future<ArcadeCenter?> getArcadeCenterById(String id) async {
    final response = await supabase
        .from('arcade_centers')
        .select()
        .eq('id', id)
        .single();
    return ArcadeCenter.fromJson(response);
  }

  Future<List<ArcadeCenter>> getFeaturedArcadeCenters() async {
    final response = await supabase
        .from('arcade_centers')
        .select()
        .eq('is_featured', true)
        .order('average_rating', ascending: false)
        .limit(8);

    return response.map((json) => ArcadeCenter.fromJson(json)).toList();
  }

  Future<List<ArcadeCenter>> getPopularArcadeCenters() async {
    final response = await supabase
        .from('arcade_centers')
        .select()
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => ArcadeCenter.fromJson(json)).toList();
  }

  Future<List<ArcadeCenter>> getVrArcadeCenters() async {
    final response = await supabase
        .from('arcade_centers')
        .select()
        .eq('has_vr_games', true)
        .order('average_rating', ascending: false)
        .limit(10);

    return response.map((json) => ArcadeCenter.fromJson(json)).toList();
  }
}