// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      zoneId: json['zone_id'] as String,
      bookingDate: json['booking_date'] as String,
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      amount: json['amount'] as String,
      eventDate: json['event_date'] as String,
      coverImage: json['cover_image'] as String,
      zoneName: json['zone_name'] as String,
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'event_id': instance.eventId,
      'zone_id': instance.zoneId,
      'booking_date': instance.bookingDate,
      'quantity': instance.quantity,
      'status': instance.status,
      'created_at': instance.createdAt,
      'amount': instance.amount,
      'event_date': instance.eventDate,
      'cover_image': instance.coverImage,
      'zone_name': instance.zoneName,
    };
