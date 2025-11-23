import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? phone,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'is_organizer') @Default(false) bool isOrganizer,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
}
