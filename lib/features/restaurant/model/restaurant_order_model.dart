import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_order_model.freezed.dart';
part 'restaurant_order_model.g.dart';

@freezed
class RestaurantOrder with _$RestaurantOrder {
  const factory RestaurantOrder({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'restaurant_id') required String restaurantId,
    @JsonKey(name: 'order_number') required String orderNumber,
    @Default('pending') String status,
    @JsonKey(name: 'order_type') @Default('delivery') String orderType,
    required double subtotal,
    @JsonKey(name: 'delivery_fee') @Default(0.0) double deliveryFee,
    @JsonKey(name: 'tax_amount') @Default(0.0) double taxAmount,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'payment_method') @Default('card') String paymentMethod,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_status') @Default('pending') String paymentStatus,
    @JsonKey(name: 'delivery_address') Map<String, dynamic>? deliveryAddress,
    @JsonKey(name: 'delivery_phone') String? deliveryPhone,
    @JsonKey(name: 'estimated_delivery_time') String? estimatedDeliveryTime,
    @JsonKey(name: 'actual_delivery_time') String? actualDeliveryTime,
    @JsonKey(name: 'special_instructions') String? specialInstructions,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _RestaurantOrder;

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOrderFromJson(json);
}