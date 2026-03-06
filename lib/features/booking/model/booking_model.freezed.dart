// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'zone_id')
  String get zoneId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_date')
  String get bookingDate => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  String get eventDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String get coverImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'zone_name')
  String get zoneName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
          BookingModel value, $Res Function(BookingModel) then) =
      _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'event_id') String eventId,
      @JsonKey(name: 'zone_id') String zoneId,
      @JsonKey(name: 'booking_date') String bookingDate,
      int quantity,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      String amount,
      @JsonKey(name: 'event_date') String eventDate,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'zone_name') String zoneName});
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventId = null,
    Object? zoneId = null,
    Object? bookingDate = null,
    Object? quantity = null,
    Object? status = null,
    Object? createdAt = null,
    Object? amount = null,
    Object? eventDate = null,
    Object? coverImage = null,
    Object? zoneName = null,
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
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      zoneName: null == zoneName
          ? _value.zoneName
          : zoneName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
          _$BookingModelImpl value, $Res Function(_$BookingModelImpl) then) =
      __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'event_id') String eventId,
      @JsonKey(name: 'zone_id') String zoneId,
      @JsonKey(name: 'booking_date') String bookingDate,
      int quantity,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      String amount,
      @JsonKey(name: 'event_date') String eventDate,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'zone_name') String zoneName});
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
      _$BookingModelImpl _value, $Res Function(_$BookingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventId = null,
    Object? zoneId = null,
    Object? bookingDate = null,
    Object? quantity = null,
    Object? status = null,
    Object? createdAt = null,
    Object? amount = null,
    Object? eventDate = null,
    Object? coverImage = null,
    Object? zoneName = null,
  }) {
    return _then(_$BookingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      zoneName: null == zoneName
          ? _value.zoneName
          : zoneName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'event_id') required this.eventId,
      @JsonKey(name: 'zone_id') required this.zoneId,
      @JsonKey(name: 'booking_date') required this.bookingDate,
      required this.quantity,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      required this.amount,
      @JsonKey(name: 'event_date') required this.eventDate,
      @JsonKey(name: 'cover_image') required this.coverImage,
      @JsonKey(name: 'zone_name') required this.zoneName});

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  @JsonKey(name: 'zone_id')
  final String zoneId;
  @override
  @JsonKey(name: 'booking_date')
  final String bookingDate;
  @override
  final int quantity;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  final String amount;
  @override
  @JsonKey(name: 'event_date')
  final String eventDate;
  @override
  @JsonKey(name: 'cover_image')
  final String coverImage;
  @override
  @JsonKey(name: 'zone_name')
  final String zoneName;

  @override
  String toString() {
    return 'BookingModel(id: $id, userId: $userId, eventId: $eventId, zoneId: $zoneId, bookingDate: $bookingDate, quantity: $quantity, status: $status, createdAt: $createdAt, amount: $amount, eventDate: $eventDate, coverImage: $coverImage, zoneName: $zoneName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.zoneName, zoneName) ||
                other.zoneName == zoneName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      eventId,
      zoneId,
      bookingDate,
      quantity,
      status,
      createdAt,
      amount,
      eventDate,
      coverImage,
      zoneName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(
      this,
    );
  }
}

abstract class _BookingModel implements BookingModel {
  const factory _BookingModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'event_id') required final String eventId,
          @JsonKey(name: 'zone_id') required final String zoneId,
          @JsonKey(name: 'booking_date') required final String bookingDate,
          required final int quantity,
          required final String status,
          @JsonKey(name: 'created_at') required final String createdAt,
          required final String amount,
          @JsonKey(name: 'event_date') required final String eventDate,
          @JsonKey(name: 'cover_image') required final String coverImage,
          @JsonKey(name: 'zone_name') required final String zoneName}) =
      _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  @JsonKey(name: 'zone_id')
  String get zoneId;
  @override
  @JsonKey(name: 'booking_date')
  String get bookingDate;
  @override
  int get quantity;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  String get amount;
  @override
  @JsonKey(name: 'event_date')
  String get eventDate;
  @override
  @JsonKey(name: 'cover_image')
  String get coverImage;
  @override
  @JsonKey(name: 'zone_name')
  String get zoneName;
  @override
  @JsonKey(ignore: true)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
