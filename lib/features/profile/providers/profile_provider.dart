import 'package:a_play/features/profile/models/profile_model.dart';
import 'package:a_play/features/profile/services/profile_service.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = Provider<ProfileService>((ref) => ProfileService());

final profileFutureProvider = FutureProvider<ProfileModel>((ref) async {
  final profileService = ref.read(profileProvider);
  return profileService.getProfile();
});

final updateProfileFutureProvider = FutureProvider.family<void, ProfileModel>((ref, profile) async {
  final profileService = ref.read(profileProvider);
  return profileService.updateProfile(profile);
});




