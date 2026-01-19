// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RestaurantOrder _$RestaurantOrderFromJson(Map<String, dynamic> json) {
  return _RestaurantOrder.fromJson(json);
}

/// @nodoc
mixin _$RestaurantOrder {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'restaurant_id')
  String get restaurantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_number')
  String get orderNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_type')
  String get orderType => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_amount')
  double get taxAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  double get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_reference')
  String? get paymentReference => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_address')
  Map<String, dynamic>? get deliveryAddress =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_phone')
  String? get deliveryPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_delivery_time')
  String? get estimatedDeliveryTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_delivery_time')
  String? get actualDeliveryTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'special_instructions')
  String? get specialInstructions => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RestaurantOrderCopyWith<RestaurantOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantOrderCopyWith<$Res> {
  factory $RestaurantOrderCopyWith(
          RestaurantOrder value, $Res Function(RestaurantOrder) then) =
      _$RestaurantOrderCopyWithImpl<$Res, RestaurantOrder>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'order_number') String orderNumber,
      String status,
      @JsonKey(name: 'order_type') String orderType,
      double subtotal,
      @JsonKey(name: 'delivery_fee') double deliveryFee,
      @JsonKey(name: 'tax_amount') double taxAmount,
      @JsonKey(name: 'total_amount') double totalAmount,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_reference') String? paymentReference,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'delivery_address') Map<String, dynamic>? deliveryAddress,
      @JsonKey(name: 'delivery_phone') String? deliveryPhone,
      @JsonKey(name: 'estimated_delivery_time') String? estimatedDeliveryTime,
      @JsonKey(name: 'actual_delivery_time') String? actualDeliveryTime,
      @JsonKey(name: 'special_instructions') String? specialInstructions,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$RestaurantOrderCopyWithImpl<$Res, $Val extends RestaurantOrder>
    implements $RestaurantOrderCopyWith<$Res> {
  _$RestaurantOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? restaurantId = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? orderType = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? taxAmount = null,
    Object? totalAmount = null,
    Object? paymentMethod = null,
    Object? paymentReference = freezed,
    Object? paymentStatus = null,
    Object? deliveryAddress = freezed,
    Object? deliveryPhone = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? actualDeliveryTime = freezed,
    Object? specialInstructions = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      orderType: null == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deliveryPhone: freezed == deliveryPhone
          ? _value.deliveryPhone
          : deliveryPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      actualDeliveryTime: freezed == actualDeliveryTime
          ? _value.actualDeliveryTime
          : actualDeliveryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestaurantOrderImplCopyWith<$Res>
    implements $RestaurantOrderCopyWith<$Res> {
  factory _$$RestaurantOrderImplCopyWith(_$RestaurantOrderImpl value,
          $Res Function(_$RestaurantOrderImpl) then) =
      __$$RestaurantOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'order_number') String orderNumber,
      String status,
      @JsonKey(name: 'order_type') String orderType,
      double subtotal,
      @JsonKey(name: 'delivery_fee') double deliveryFee,
      @JsonKey(name: 'tax_amount') double taxAmount,
      @JsonKey(name: 'total_amount') double totalAmount,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_reference') String? paymentReference,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'delivery_address') Map<String, dynamic>? deliveryAddress,
      @JsonKey(name: 'delivery_phone') String? deliveryPhone,
      @JsonKey(name: 'estimated_delivery_time') String? estimatedDeliveryTime,
      @JsonKey(name: 'actual_delivery_time') String? actualDeliveryTime,
      @JsonKey(name: 'special_instructions') String? specialInstructions,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$RestaurantOrderImplCopyWithImpl<$Res>
    extends _$RestaurantOrderCopyWithImpl<$Res, _$RestaurantOrderImpl>
    implements _$$RestaurantOrderImplCopyWith<$Res> {
  __$$RestaurantOrderImplCopyWithImpl(
      _$RestaurantOrderImpl _value, $Res Function(_$RestaurantOrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? restaurantId = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? orderType = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? taxAmount = null,
    Object? totalAmount = null,
    Object? paymentMethod = null,
    Object? paymentReference = freezed,
    Object? paymentStatus = null,
    Object? deliveryAddress = freezed,
    Object? deliveryPhone = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? actualDeliveryTime = freezed,
    Object? specialInstructions = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RestaurantOrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      orderType: null == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryFee: null == deliveryFee
          ? _value.deliveryFee
          : deliveryFee // ignore: cast_nullable_to_non_nullable
              as double,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _value._deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deliveryPhone: freezed == deliveryPhone
          ? _value.deliveryPhone
          : deliveryPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      actualDeliveryTime: freezed == actualDeliveryTime
          ? _value.actualDeliveryTime
          : actualDeliveryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantOrderImpl implements _RestaurantOrder {
  const _$RestaurantOrderImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'restaurant_id') required this.restaurantId,
      @JsonKey(name: 'order_number') required this.orderNumber,
      this.status = 'pending',
      @JsonKey(name: 'order_type') this.orderType = 'delivery',
      required this.subtotal,
      @JsonKey(name: 'delivery_fee') this.deliveryFee = 0.0,
      @JsonKey(name: 'tax_amount') this.taxAmount = 0.0,
      @JsonKey(name: 'total_amount') required this.totalAmount,
      @JsonKey(name: 'payment_method') this.paymentMethod = 'card',
      @JsonKey(name: 'payment_reference') this.paymentReference,
      @JsonKey(name: 'payment_status') this.paymentStatus = 'pending',
      @JsonKey(name: 'delivery_address')
      final Map<String, dynamic>? deliveryAddress,
      @JsonKey(name: 'delivery_phone') this.deliveryPhone,
      @JsonKey(name: 'estimated_delivery_time') this.estimatedDeliveryTime,
      @JsonKey(name: 'actual_delivery_time') this.actualDeliveryTime,
      @JsonKey(name: 'special_instructions') this.specialInstructions,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _deliveryAddress = deliveryAddress;

  factory _$RestaurantOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantOrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  @override
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'order_type')
  final String orderType;
  @override
  final double subtotal;
  @override
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @override
  @JsonKey(name: 'tax_amount')
  final double taxAmount;
  @override
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  final Map<String, dynamic>? _deliveryAddress;
  @override
  @JsonKey(name: 'delivery_address')
  Map<String, dynamic>? get deliveryAddress {
    final value = _deliveryAddress;
    if (value == null) return null;
    if (_deliveryAddress is EqualUnmodifiableMapView) return _deliveryAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'delivery_phone')
  final String? deliveryPhone;
  @override
  @JsonKey(name: 'estimated_delivery_time')
  final String? estimatedDeliveryTime;
  @override
  @JsonKey(name: 'actual_delivery_time')
  final String? actualDeliveryTime;
  @override
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'RestaurantOrder(id: $id, userId: $userId, restaurantId: $restaurantId, orderNumber: $orderNumber, status: $status, orderType: $orderType, subtotal: $subtotal, deliveryFee: $deliveryFee, taxAmount: $taxAmount, totalAmount: $totalAmount, paymentMethod: $paymentMethod, paymentReference: $paymentReference, paymentStatus: $paymentStatus, deliveryAddress: $deliveryAddress, deliveryPhone: $deliveryPhone, estimatedDeliveryTime: $estimatedDeliveryTime, actualDeliveryTime: $actualDeliveryTime, specialInstructions: $specialInstructions, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentReference, paymentReference) ||
                other.paymentReference == paymentReference) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            const DeepCollectionEquality()
                .equals(other._deliveryAddress, _deliveryAddress) &&
            (identical(other.deliveryPhone, deliveryPhone) ||
                other.deliveryPhone == deliveryPhone) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            (identical(other.actualDeliveryTime, actualDeliveryTime) ||
                other.actualDeliveryTime == actualDeliveryTime) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        restaurantId,
        orderNumber,
        status,
        orderType,
        subtotal,
        deliveryFee,
        taxAmount,
        totalAmount,
        paymentMethod,
        paymentReference,
        paymentStatus,
        const DeepCollectionEquality().hash(_deliveryAddress),
        deliveryPhone,
        estimatedDeliveryTime,
        actualDeliveryTime,
        specialInstructions,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantOrderImplCopyWith<_$RestaurantOrderImpl> get copyWith =>
      __$$RestaurantOrderImplCopyWithImpl<_$RestaurantOrderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantOrderImplToJson(
      this,
    );
  }
}

abstract class _RestaurantOrder implements RestaurantOrder {
  const factory _RestaurantOrder(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'restaurant_id') required final String restaurantId,
      @JsonKey(name: 'order_number') required final String orderNumber,
      final String status,
      @JsonKey(name: 'order_type') final String orderType,
      required final double subtotal,
      @JsonKey(name: 'delivery_fee') final double deliveryFee,
      @JsonKey(name: 'tax_amount') final double taxAmount,
      @JsonKey(name: 'total_amount') required final double totalAmount,
      @JsonKey(name: 'payment_method') final String paymentMethod,
      @JsonKey(name: 'payment_reference') final String? paymentReference,
      @JsonKey(name: 'payment_status') final String paymentStatus,
      @JsonKey(name: 'delivery_address')
      final Map<String, dynamic>? deliveryAddress,
      @JsonKey(name: 'delivery_phone') final String? deliveryPhone,
      @JsonKey(name: 'estimated_delivery_time')
      final String? estimatedDeliveryTime,
      @JsonKey(name: 'actual_delivery_time') final String? actualDeliveryTime,
      @JsonKey(name: 'special_instructions') final String? specialInstructions,
      @JsonKey(name: 'created_at') required final String createdAt,
      @JsonKey(name: 'updated_at')
      required final String updatedAt}) = _$RestaurantOrderImpl;

  factory _RestaurantOrder.fromJson(Map<String, dynamic> json) =
      _$RestaurantOrderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'restaurant_id')
  String get restaurantId;
  @override
  @JsonKey(name: 'order_number')
  String get orderNumber;
  @override
  String get status;
  @override
  @JsonKey(name: 'order_type')
  String get orderType;
  @override
  double get subtotal;
  @override
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee;
  @override
  @JsonKey(name: 'tax_amount')
  double get taxAmount;
  @override
  @JsonKey(name: 'total_amount')
  double get totalAmount;
  @override
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'payment_reference')
  String? get paymentReference;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'delivery_address')
  Map<String, dynamic>? get deliveryAddress;
  @override
  @JsonKey(name: 'delivery_phone')
  String? get deliveryPhone;
  @override
  @JsonKey(name: 'estimated_delivery_time')
  String? get estimatedDeliveryTime;
  @override
  @JsonKey(name: 'actual_delivery_time')
  String? get actualDeliveryTime;
  @override
  @JsonKey(name: 'special_instructions')
  String? get specialInstructions;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RestaurantOrderImplCopyWith<_$RestaurantOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
