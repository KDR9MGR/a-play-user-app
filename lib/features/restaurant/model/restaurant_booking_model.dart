import 'package:freezed_annotation/freezed_annotation.dart';
import 'restaurant_table_model.dart';

part 'restaurant_booking_model.freezed.dart';
part 'restaurant_booking_model.g.dart';

@freezed
class RestaurantBooking with _$RestaurantBooking {
  const factory RestaurantBooking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'restaurant_id') required String restaurantId,
    @JsonKey(name: 'table_id') required String tableId,
    @JsonKey(name: 'booking_date') required DateTime bookingDate,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'party_size') required int partySize,
    @Default(BookingStatus.pending) BookingStatus status,
    @JsonKey(name: 'special_requests') String? specialRequests,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'total_amount') @Default(0.0) double totalAmount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Payment fields (added 2026-03-21)
    @JsonKey(name: 'transaction_id') String? transactionId,
    @JsonKey(name: 'payment_status') @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'amount_paid') double? amountPaid,
    @Default('GHS') String? currency,

    // Additional fields for UI (not stored in DB)
    RestaurantTable? table,
    String? restaurantName,
    String? userName,
  }) = _RestaurantBooking;

  factory RestaurantBooking.fromJson(Map<String, dynamic> json) =>
      _$RestaurantBookingFromJson(json);
}

enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

extension BookingStatusExtension on String {
  BookingStatus get toBookingStatus {
    switch (toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }
}

extension BookingStatusDisplayExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
  
  String get dbValue {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  T when<T>({
    required T Function() pending,
    required T Function() confirmed,
    required T Function() cancelled,
    required T Function() completed,
  }) {
    switch (this) {
      case BookingStatus.pending:
        return pending();
      case BookingStatus.confirmed:
        return confirmed();
      case BookingStatus.cancelled:
        return cancelled();
      case BookingStatus.completed:
        return completed();
    }
  }
}

@freezed
class BookingTimeSlot with _$BookingTimeSlot {
  const factory BookingTimeSlot({
    required DateTime startTime,
    required DateTime endTime,
    required bool isAvailable,
    String? unavailableReason,
  }) = _BookingTimeSlot;
}

@freezed
class TableAvailability with _$TableAvailability {
  const factory TableAvailability({
    required RestaurantTable table,
    required List<BookingTimeSlot> timeSlots,
    required bool isAvailableToday,
  }) = _TableAvailability;
}