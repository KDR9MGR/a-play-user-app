// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RestaurantBooking _$RestaurantBookingFromJson(Map<String, dynamic> json) {
  return _RestaurantBooking.fromJson(json);
}

/// @nodoc
mixin _$RestaurantBooking {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'restaurant_id')
  String get restaurantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'table_id')
  String get tableId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_date')
  DateTime get bookingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'party_size')
  int get partySize => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'special_requests')
  String? get specialRequests => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  double get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI (not stored in DB)
  RestaurantTable? get table => throw _privateConstructorUsedError;
  String? get restaurantName => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RestaurantBookingCopyWith<RestaurantBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantBookingCopyWith<$Res> {
  factory $RestaurantBookingCopyWith(
          RestaurantBooking value, $Res Function(RestaurantBooking) then) =
      _$RestaurantBookingCopyWithImpl<$Res, RestaurantBooking>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'table_id') String tableId,
      @JsonKey(name: 'booking_date') DateTime bookingDate,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      @JsonKey(name: 'party_size') int partySize,
      BookingStatus status,
      @JsonKey(name: 'special_requests') String? specialRequests,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'total_amount') double totalAmount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      RestaurantTable? table,
      String? restaurantName,
      String? userName});

  $RestaurantTableCopyWith<$Res>? get table;
}

/// @nodoc
class _$RestaurantBookingCopyWithImpl<$Res, $Val extends RestaurantBooking>
    implements $RestaurantBookingCopyWith<$Res> {
  _$RestaurantBookingCopyWithImpl(this._value, this._then);

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
    Object? tableId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? partySize = null,
    Object? status = null,
    Object? specialRequests = freezed,
    Object? contactPhone = freezed,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? table = freezed,
    Object? restaurantName = freezed,
    Object? userName = freezed,
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
      tableId: null == tableId
          ? _value.tableId
          : tableId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      partySize: null == partySize
          ? _value.partySize
          : partySize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      table: freezed == table
          ? _value.table
          : table // ignore: cast_nullable_to_non_nullable
              as RestaurantTable?,
      restaurantName: freezed == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RestaurantTableCopyWith<$Res>? get table {
    if (_value.table == null) {
      return null;
    }

    return $RestaurantTableCopyWith<$Res>(_value.table!, (value) {
      return _then(_value.copyWith(table: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RestaurantBookingImplCopyWith<$Res>
    implements $RestaurantBookingCopyWith<$Res> {
  factory _$$RestaurantBookingImplCopyWith(_$RestaurantBookingImpl value,
          $Res Function(_$RestaurantBookingImpl) then) =
      __$$RestaurantBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'table_id') String tableId,
      @JsonKey(name: 'booking_date') DateTime bookingDate,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      @JsonKey(name: 'party_size') int partySize,
      BookingStatus status,
      @JsonKey(name: 'special_requests') String? specialRequests,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'total_amount') double totalAmount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      RestaurantTable? table,
      String? restaurantName,
      String? userName});

  @override
  $RestaurantTableCopyWith<$Res>? get table;
}

/// @nodoc
class __$$RestaurantBookingImplCopyWithImpl<$Res>
    extends _$RestaurantBookingCopyWithImpl<$Res, _$RestaurantBookingImpl>
    implements _$$RestaurantBookingImplCopyWith<$Res> {
  __$$RestaurantBookingImplCopyWithImpl(_$RestaurantBookingImpl _value,
      $Res Function(_$RestaurantBookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? restaurantId = null,
    Object? tableId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? partySize = null,
    Object? status = null,
    Object? specialRequests = freezed,
    Object? contactPhone = freezed,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? table = freezed,
    Object? restaurantName = freezed,
    Object? userName = freezed,
  }) {
    return _then(_$RestaurantBookingImpl(
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
      tableId: null == tableId
          ? _value.tableId
          : tableId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      partySize: null == partySize
          ? _value.partySize
          : partySize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      table: freezed == table
          ? _value.table
          : table // ignore: cast_nullable_to_non_nullable
              as RestaurantTable?,
      restaurantName: freezed == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantBookingImpl implements _RestaurantBooking {
  const _$RestaurantBookingImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'restaurant_id') required this.restaurantId,
      @JsonKey(name: 'table_id') required this.tableId,
      @JsonKey(name: 'booking_date') required this.bookingDate,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'party_size') required this.partySize,
      this.status = BookingStatus.pending,
      @JsonKey(name: 'special_requests') this.specialRequests,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'total_amount') this.totalAmount = 0.0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      this.table,
      this.restaurantName,
      this.userName});

  factory _$RestaurantBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantBookingImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  @override
  @JsonKey(name: 'table_id')
  final String tableId;
  @override
  @JsonKey(name: 'booking_date')
  final DateTime bookingDate;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @override
  @JsonKey(name: 'party_size')
  final int partySize;
  @override
  @JsonKey()
  final BookingStatus status;
  @override
  @JsonKey(name: 'special_requests')
  final String? specialRequests;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// Additional fields for UI (not stored in DB)
  @override
  final RestaurantTable? table;
  @override
  final String? restaurantName;
  @override
  final String? userName;

  @override
  String toString() {
    return 'RestaurantBooking(id: $id, userId: $userId, restaurantId: $restaurantId, tableId: $tableId, bookingDate: $bookingDate, startTime: $startTime, endTime: $endTime, partySize: $partySize, status: $status, specialRequests: $specialRequests, contactPhone: $contactPhone, totalAmount: $totalAmount, createdAt: $createdAt, updatedAt: $updatedAt, table: $table, restaurantName: $restaurantName, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.partySize, partySize) ||
                other.partySize == partySize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.specialRequests, specialRequests) ||
                other.specialRequests == specialRequests) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.table, table) || other.table == table) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      restaurantId,
      tableId,
      bookingDate,
      startTime,
      endTime,
      partySize,
      status,
      specialRequests,
      contactPhone,
      totalAmount,
      createdAt,
      updatedAt,
      table,
      restaurantName,
      userName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantBookingImplCopyWith<_$RestaurantBookingImpl> get copyWith =>
      __$$RestaurantBookingImplCopyWithImpl<_$RestaurantBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantBookingImplToJson(
      this,
    );
  }
}

abstract class _RestaurantBooking implements RestaurantBooking {
  const factory _RestaurantBooking(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'restaurant_id') required final String restaurantId,
      @JsonKey(name: 'table_id') required final String tableId,
      @JsonKey(name: 'booking_date') required final DateTime bookingDate,
      @JsonKey(name: 'start_time') required final DateTime startTime,
      @JsonKey(name: 'end_time') required final DateTime endTime,
      @JsonKey(name: 'party_size') required final int partySize,
      final BookingStatus status,
      @JsonKey(name: 'special_requests') final String? specialRequests,
      @JsonKey(name: 'contact_phone') final String? contactPhone,
      @JsonKey(name: 'total_amount') final double totalAmount,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      final RestaurantTable? table,
      final String? restaurantName,
      final String? userName}) = _$RestaurantBookingImpl;

  factory _RestaurantBooking.fromJson(Map<String, dynamic> json) =
      _$RestaurantBookingImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'restaurant_id')
  String get restaurantId;
  @override
  @JsonKey(name: 'table_id')
  String get tableId;
  @override
  @JsonKey(name: 'booking_date')
  DateTime get bookingDate;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'end_time')
  DateTime get endTime;
  @override
  @JsonKey(name: 'party_size')
  int get partySize;
  @override
  BookingStatus get status;
  @override
  @JsonKey(name: 'special_requests')
  String? get specialRequests;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'total_amount')
  double get totalAmount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override // Additional fields for UI (not stored in DB)
  RestaurantTable? get table;
  @override
  String? get restaurantName;
  @override
  String? get userName;
  @override
  @JsonKey(ignore: true)
  _$$RestaurantBookingImplCopyWith<_$RestaurantBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BookingTimeSlot {
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  String? get unavailableReason => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BookingTimeSlotCopyWith<BookingTimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingTimeSlotCopyWith<$Res> {
  factory $BookingTimeSlotCopyWith(
          BookingTimeSlot value, $Res Function(BookingTimeSlot) then) =
      _$BookingTimeSlotCopyWithImpl<$Res, BookingTimeSlot>;
  @useResult
  $Res call(
      {DateTime startTime,
      DateTime endTime,
      bool isAvailable,
      String? unavailableReason});
}

/// @nodoc
class _$BookingTimeSlotCopyWithImpl<$Res, $Val extends BookingTimeSlot>
    implements $BookingTimeSlotCopyWith<$Res> {
  _$BookingTimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? unavailableReason = freezed,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      unavailableReason: freezed == unavailableReason
          ? _value.unavailableReason
          : unavailableReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingTimeSlotImplCopyWith<$Res>
    implements $BookingTimeSlotCopyWith<$Res> {
  factory _$$BookingTimeSlotImplCopyWith(_$BookingTimeSlotImpl value,
          $Res Function(_$BookingTimeSlotImpl) then) =
      __$$BookingTimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startTime,
      DateTime endTime,
      bool isAvailable,
      String? unavailableReason});
}

/// @nodoc
class __$$BookingTimeSlotImplCopyWithImpl<$Res>
    extends _$BookingTimeSlotCopyWithImpl<$Res, _$BookingTimeSlotImpl>
    implements _$$BookingTimeSlotImplCopyWith<$Res> {
  __$$BookingTimeSlotImplCopyWithImpl(
      _$BookingTimeSlotImpl _value, $Res Function(_$BookingTimeSlotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? unavailableReason = freezed,
  }) {
    return _then(_$BookingTimeSlotImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      unavailableReason: freezed == unavailableReason
          ? _value.unavailableReason
          : unavailableReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BookingTimeSlotImpl implements _BookingTimeSlot {
  const _$BookingTimeSlotImpl(
      {required this.startTime,
      required this.endTime,
      required this.isAvailable,
      this.unavailableReason});

  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final bool isAvailable;
  @override
  final String? unavailableReason;

  @override
  String toString() {
    return 'BookingTimeSlot(startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable, unavailableReason: $unavailableReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingTimeSlotImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.unavailableReason, unavailableReason) ||
                other.unavailableReason == unavailableReason));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, startTime, endTime, isAvailable, unavailableReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingTimeSlotImplCopyWith<_$BookingTimeSlotImpl> get copyWith =>
      __$$BookingTimeSlotImplCopyWithImpl<_$BookingTimeSlotImpl>(
          this, _$identity);
}

abstract class _BookingTimeSlot implements BookingTimeSlot {
  const factory _BookingTimeSlot(
      {required final DateTime startTime,
      required final DateTime endTime,
      required final bool isAvailable,
      final String? unavailableReason}) = _$BookingTimeSlotImpl;

  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  bool get isAvailable;
  @override
  String? get unavailableReason;
  @override
  @JsonKey(ignore: true)
  _$$BookingTimeSlotImplCopyWith<_$BookingTimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TableAvailability {
  RestaurantTable get table => throw _privateConstructorUsedError;
  List<BookingTimeSlot> get timeSlots => throw _privateConstructorUsedError;
  bool get isAvailableToday => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TableAvailabilityCopyWith<TableAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableAvailabilityCopyWith<$Res> {
  factory $TableAvailabilityCopyWith(
          TableAvailability value, $Res Function(TableAvailability) then) =
      _$TableAvailabilityCopyWithImpl<$Res, TableAvailability>;
  @useResult
  $Res call(
      {RestaurantTable table,
      List<BookingTimeSlot> timeSlots,
      bool isAvailableToday});

  $RestaurantTableCopyWith<$Res> get table;
}

/// @nodoc
class _$TableAvailabilityCopyWithImpl<$Res, $Val extends TableAvailability>
    implements $TableAvailabilityCopyWith<$Res> {
  _$TableAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? table = null,
    Object? timeSlots = null,
    Object? isAvailableToday = null,
  }) {
    return _then(_value.copyWith(
      table: null == table
          ? _value.table
          : table // ignore: cast_nullable_to_non_nullable
              as RestaurantTable,
      timeSlots: null == timeSlots
          ? _value.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<BookingTimeSlot>,
      isAvailableToday: null == isAvailableToday
          ? _value.isAvailableToday
          : isAvailableToday // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RestaurantTableCopyWith<$Res> get table {
    return $RestaurantTableCopyWith<$Res>(_value.table, (value) {
      return _then(_value.copyWith(table: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TableAvailabilityImplCopyWith<$Res>
    implements $TableAvailabilityCopyWith<$Res> {
  factory _$$TableAvailabilityImplCopyWith(_$TableAvailabilityImpl value,
          $Res Function(_$TableAvailabilityImpl) then) =
      __$$TableAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RestaurantTable table,
      List<BookingTimeSlot> timeSlots,
      bool isAvailableToday});

  @override
  $RestaurantTableCopyWith<$Res> get table;
}

/// @nodoc
class __$$TableAvailabilityImplCopyWithImpl<$Res>
    extends _$TableAvailabilityCopyWithImpl<$Res, _$TableAvailabilityImpl>
    implements _$$TableAvailabilityImplCopyWith<$Res> {
  __$$TableAvailabilityImplCopyWithImpl(_$TableAvailabilityImpl _value,
      $Res Function(_$TableAvailabilityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? table = null,
    Object? timeSlots = null,
    Object? isAvailableToday = null,
  }) {
    return _then(_$TableAvailabilityImpl(
      table: null == table
          ? _value.table
          : table // ignore: cast_nullable_to_non_nullable
              as RestaurantTable,
      timeSlots: null == timeSlots
          ? _value._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<BookingTimeSlot>,
      isAvailableToday: null == isAvailableToday
          ? _value.isAvailableToday
          : isAvailableToday // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TableAvailabilityImpl implements _TableAvailability {
  const _$TableAvailabilityImpl(
      {required this.table,
      required final List<BookingTimeSlot> timeSlots,
      required this.isAvailableToday})
      : _timeSlots = timeSlots;

  @override
  final RestaurantTable table;
  final List<BookingTimeSlot> _timeSlots;
  @override
  List<BookingTimeSlot> get timeSlots {
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeSlots);
  }

  @override
  final bool isAvailableToday;

  @override
  String toString() {
    return 'TableAvailability(table: $table, timeSlots: $timeSlots, isAvailableToday: $isAvailableToday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableAvailabilityImpl &&
            (identical(other.table, table) || other.table == table) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            (identical(other.isAvailableToday, isAvailableToday) ||
                other.isAvailableToday == isAvailableToday));
  }

  @override
  int get hashCode => Object.hash(runtimeType, table,
      const DeepCollectionEquality().hash(_timeSlots), isAvailableToday);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TableAvailabilityImplCopyWith<_$TableAvailabilityImpl> get copyWith =>
      __$$TableAvailabilityImplCopyWithImpl<_$TableAvailabilityImpl>(
          this, _$identity);
}

abstract class _TableAvailability implements TableAvailability {
  const factory _TableAvailability(
      {required final RestaurantTable table,
      required final List<BookingTimeSlot> timeSlots,
      required final bool isAvailableToday}) = _$TableAvailabilityImpl;

  @override
  RestaurantTable get table;
  @override
  List<BookingTimeSlot> get timeSlots;
  @override
  bool get isAvailableToday;
  @override
  @JsonKey(ignore: true)
  _$$TableAvailabilityImplCopyWith<_$TableAvailabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
