import 'package:a_play/features/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<ProfileModel> getProfile() async {
    return await AuthService.withAuthRetry(() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        return ProfileModel(id: '', createdAt: DateTime.now());
      }

      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return ProfileModel(id: userId, createdAt: DateTime.now());
      }

      return ProfileModel.fromJson((response as Map).cast<String, dynamic>());
    });
  }

  Future<void> updateProfile(ProfileModel profile) async {
    return await AuthService.withAuthRetry(() async {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', userId);
    });
  }
}
