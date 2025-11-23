import 'package:a_play/features/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<ProfileModel> getProfile() async {
    return await AuthService.withAuthRetry(() async {
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', supabase.auth.currentUser?.id ?? '')
          .single();
      return ProfileModel.fromJson(response);
    });
  }

  Future<void> updateProfile(ProfileModel profile) async {
    return await AuthService.withAuthRetry(() async {
      await supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', supabase.auth.currentUser?.id ?? '');
    });
  }
}
