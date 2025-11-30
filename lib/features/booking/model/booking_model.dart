import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'booking_date') required String bookingDate,
    required int quantity,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
    required String amount,
    @JsonKey(name: 'event_date') required String eventDate,
    @JsonKey(name: 'cover_image') required String coverImage,
    @JsonKey(name: 'zone_name') required String zoneName,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
}
