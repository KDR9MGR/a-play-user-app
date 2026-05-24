// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantOrderImpl _$$RestaurantOrderImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantOrderImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String? ?? 'pending',
      orderType: json['order_type'] as String? ?? 'delivery',
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'card',
      paymentReference: json['payment_reference'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      deliveryAddress: json['delivery_address'] as Map<String, dynamic>?,
      deliveryPhone: json['delivery_phone'] as String?,
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      actualDeliveryTime: json['actual_delivery_time'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$RestaurantOrderImplToJson(
        _$RestaurantOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'restaurant_id': instance.restaurantId,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'order_type': instance.orderType,
      'subtotal': instance.subtotal,
      'delivery_fee': instance.deliveryFee,
      'tax_amount': instance.taxAmount,
      'total_amount': instance.totalAmount,
      'payment_method': instance.paymentMethod,
      'payment_reference': instance.paymentReference,
      'payment_status': instance.paymentStatus,
      'delivery_address': instance.deliveryAddress,
      'delivery_phone': instance.deliveryPhone,
      'estimated_delivery_time': instance.estimatedDeliveryTime,
      'actual_delivery_time': instance.actualDeliveryTime,
      'special_instructions': instance.specialInstructions,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
