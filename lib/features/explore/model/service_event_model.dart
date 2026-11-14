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
    // Organiser event creation explicitly marks cover image as optional, so
    // this must tolerate null - the generated fromJson previously did a
    // non-null `as String` cast here, which threw for any event without one
    // and (since the list is mapped eagerly) took down the entire Explore
    // category list for every user, not just that event's card.
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'club_id') String? clubId,
    @JsonKey(name: 'category_name') String? category,
  }) = _ServiceEventModel;

  factory ServiceEventModel.fromJson(Map<String, dynamic> json) => _$ServiceEventModelFromJson(json);
}


