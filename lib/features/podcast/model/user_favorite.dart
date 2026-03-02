import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_favorite.freezed.dart';
part 'user_favorite.g.dart';

@freezed
class UserFavorite with _$UserFavorite {
  const factory UserFavorite({
    required String id,
    required String userId,
    required String contentId,
    required String createdAt,
    required String updatedAt,
  }) = _UserFavorite;

  factory UserFavorite.fromJson(Map<String, dynamic> json) =>
      _$UserFavoriteFromJson(json);
} 