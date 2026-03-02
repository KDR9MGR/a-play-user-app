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
