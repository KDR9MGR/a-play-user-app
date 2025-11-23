import 'package:freezed_annotation/freezed_annotation.dart';

part 'concierge_model.freezed.dart';
part 'concierge_model.g.dart';

enum RequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress, 
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled
}

@freezed
class ConciergeRequest with _$ConciergeRequest {
  const factory ConciergeRequest({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String category,
    @JsonKey(name: 'service_name') required String serviceName,
    required String description,
    @Default(RequestStatus.pending) RequestStatus status,
    @JsonKey(name: 'is_urgent') @Default(false) bool isUrgent,
    @JsonKey(name: 'requested_at') DateTime? requestedAt, 
    @JsonKey(name: 'additional_details') Map<String, dynamic>? additionalDetails,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ConciergeRequest;

  factory ConciergeRequest.fromJson(Map<String, dynamic> json) =>
      _$ConciergeRequestFromJson(json);
}   