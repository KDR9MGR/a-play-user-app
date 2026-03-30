//Freezed calss of service event model

import 'package:freezed_annotation/freezed_annotation.dart';
part 'service_event_model.freezed.dart';
part 'service_event_model.g.dart';

@freezed
class ServiceEventModel with _$ServiceEventModel {
  const factory ServiceEventModel({
    required String id,
    required String title,
    required String description,
    required String location,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'cover_image') required String coverImage,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'club_id') String? clubId,
    @JsonKey(name: 'category_name') String? category,
  }) = _ServiceEventModel;

  factory ServiceEventModel.fromJson(Map<String, dynamic> json) => _$ServiceEventModelFromJson(json);
}


