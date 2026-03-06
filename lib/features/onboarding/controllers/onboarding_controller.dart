
import 'package:a_play/features/profile/models/profile_model.dart';
import 'package:a_play/features/profile/providers/profile_provider.dart';
import 'package:a_play/features/profile/services/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingController extends StateNotifier<ProfileModel> {
  OnboardingController(this._profileService) : super(ProfileModel(id: '', createdAt: DateTime.now()));

  final ProfileService _profileService;

  void updateProfile(ProfileModel profile) {
    state = profile;
  }

  Future<void> saveProfile() async {
    await _profileService.updateProfile(state.copyWith(isOnboardingComplete: true));
  }
}

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, ProfileModel>((ref) {
  final profileService = ref.watch(profileProvider);
  return OnboardingController(profileService);
});
