import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String clubId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    @Default('pending') String status,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
} 