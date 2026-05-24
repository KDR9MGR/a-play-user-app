// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantBookingImpl _$$RestaurantBookingImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantBookingImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      tableId: json['table_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      partySize: (json['party_size'] as num).toInt(),
      status: $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
          BookingStatus.pending,
      specialRequests: json['special_requests'] as String?,
      contactPhone: json['contact_phone'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transactionId: json['transaction_id'] as String?,
      paymentStatus:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['payment_status']) ??
              PaymentStatus.pending,
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'GHS',
      table: json['table'] == null
          ? null
          : RestaurantTable.fromJson(json['table'] as Map<String, dynamic>),
      restaurantName: json['restaurantName'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$RestaurantBookingImplToJson(
        _$RestaurantBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'restaurant_id': instance.restaurantId,
      'table_id': instance.tableId,
      'booking_date': instance.bookingDate.toIso8601String(),
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'party_size': instance.partySize,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'special_requests': instance.specialRequests,
      'contact_phone': instance.contactPhone,
      'total_amount': instance.totalAmount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'transaction_id': instance.transactionId,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'payment_method': instance.paymentMethod,
      'payment_reference': instance.paymentReference,
      'amount_paid': instance.amountPaid,
      'currency': instance.currency,
      'table': instance.table,
      'restaurantName': instance.restaurantName,
      'userName': instance.userName,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};
