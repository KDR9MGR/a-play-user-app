import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_booking_history_model.freezed.dart';

/// Read model for a user's past/upcoming club table bookings, joined with
/// club/table names for display. Deliberately separate from the existing
/// club_booking/model/booking_model.dart (BookingModel), whose generated
/// fromJson expects camelCase keys that never matched the real snake_case
/// club_bookings table - that model was never actually exercised by a real
/// fetch, only used client-side by the booking-creation flow (which builds
/// its own snake_case insert map directly, bypassing toJson entirely).
@freezed
class ClubBookingHistory with _$ClubBookingHistory {
  const factory ClubBookingHistory({
    required String id,
    @JsonKey(name: 'club_id') required String clubId,
    @JsonKey(name: 'table_id') required String tableId,
    @JsonKey(name: 'booking_date') required DateTime bookingDate,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'total_price') required double totalPrice,
    @Default('pending') String status,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    String? clubName,
    String? clubLogoUrl,
    String? tableName,
  }) = _ClubBookingHistory;

  factory ClubBookingHistory.fromJson(Map<String, dynamic> json) {
    final club = json['clubs'] as Map<String, dynamic>?;
    final table = json['club_tables'] as Map<String, dynamic>?;
    return ClubBookingHistory(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      tableId: json['table_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String?,
      clubName: club?['name'] as String?,
      clubLogoUrl: club?['logo_url'] as String?,
      tableName: table?['name'] as String?,
    );
  }
}
