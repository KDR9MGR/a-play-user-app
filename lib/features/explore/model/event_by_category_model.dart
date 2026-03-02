import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_by_category_model.freezed.dart';
part 'event_by_category_model.g.dart';

@freezed
class EventByCategoryModel with _$EventByCategoryModel {
  const factory EventByCategoryModel({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'cover_image') required String coverImage,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'club_id') required String clubId,
    required String location,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'category_name') required String categoryName,
  }) = _EventByCategoryModel;

  factory EventByCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$EventByCategoryModelFromJson(json);
}
