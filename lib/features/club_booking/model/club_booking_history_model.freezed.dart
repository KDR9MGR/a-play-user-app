// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_booking_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ClubBookingHistory {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_id')
  String get clubId => throw _privateConstructorUsedError;
  @JsonKey(name: 'table_id')
  String get tableId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_date')
  DateTime get bookingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_price')
  double get totalPrice => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String? get paymentStatus => throw _privateConstructorUsedError;
  String? get clubName => throw _privateConstructorUsedError;
  String? get clubLogoUrl => throw _privateConstructorUsedError;
  String? get tableName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClubBookingHistoryCopyWith<ClubBookingHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubBookingHistoryCopyWith<$Res> {
  factory $ClubBookingHistoryCopyWith(
          ClubBookingHistory value, $Res Function(ClubBookingHistory) then) =
      _$ClubBookingHistoryCopyWithImpl<$Res, ClubBookingHistory>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'club_id') String clubId,
      @JsonKey(name: 'table_id') String tableId,
      @JsonKey(name: 'booking_date') DateTime bookingDate,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      @JsonKey(name: 'total_price') double totalPrice,
      String status,
      @JsonKey(name: 'payment_status') String? paymentStatus,
      String? clubName,
      String? clubLogoUrl,
      String? tableName});
}

/// @nodoc
class _$ClubBookingHistoryCopyWithImpl<$Res, $Val extends ClubBookingHistory>
    implements $ClubBookingHistoryCopyWith<$Res> {
  _$ClubBookingHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubId = null,
    Object? tableId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalPrice = null,
    Object? status = null,
    Object? paymentStatus = freezed,
    Object? clubName = freezed,
    Object? clubLogoUrl = freezed,
    Object? tableName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
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
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      clubName: freezed == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String?,
      clubLogoUrl: freezed == clubLogoUrl
          ? _value.clubLogoUrl
          : clubLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tableName: freezed == tableName
          ? _value.tableName
          : tableName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClubBookingHistoryImplCopyWith<$Res>
    implements $ClubBookingHistoryCopyWith<$Res> {
  factory _$$ClubBookingHistoryImplCopyWith(_$ClubBookingHistoryImpl value,
          $Res Function(_$ClubBookingHistoryImpl) then) =
      __$$ClubBookingHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'club_id') String clubId,
      @JsonKey(name: 'table_id') String tableId,
      @JsonKey(name: 'booking_date') DateTime bookingDate,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      @JsonKey(name: 'total_price') double totalPrice,
      String status,
      @JsonKey(name: 'payment_status') String? paymentStatus,
      String? clubName,
      String? clubLogoUrl,
      String? tableName});
}

/// @nodoc
class __$$ClubBookingHistoryImplCopyWithImpl<$Res>
    extends _$ClubBookingHistoryCopyWithImpl<$Res, _$ClubBookingHistoryImpl>
    implements _$$ClubBookingHistoryImplCopyWith<$Res> {
  __$$ClubBookingHistoryImplCopyWithImpl(_$ClubBookingHistoryImpl _value,
      $Res Function(_$ClubBookingHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clubId = null,
    Object? tableId = null,
    Object? bookingDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalPrice = null,
    Object? status = null,
    Object? paymentStatus = freezed,
    Object? clubName = freezed,
    Object? clubLogoUrl = freezed,
    Object? tableName = freezed,
  }) {
    return _then(_$ClubBookingHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
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
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      clubName: freezed == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String?,
      clubLogoUrl: freezed == clubLogoUrl
          ? _value.clubLogoUrl
          : clubLogoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tableName: freezed == tableName
          ? _value.tableName
          : tableName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ClubBookingHistoryImpl implements _ClubBookingHistory {
  const _$ClubBookingHistoryImpl(
      {required this.id,
      @JsonKey(name: 'club_id') required this.clubId,
      @JsonKey(name: 'table_id') required this.tableId,
      @JsonKey(name: 'booking_date') required this.bookingDate,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'total_price') required this.totalPrice,
      this.status = 'pending',
      @JsonKey(name: 'payment_status') this.paymentStatus,
      this.clubName,
      this.clubLogoUrl,
      this.tableName});

  @override
  final String id;
  @override
  @JsonKey(name: 'club_id')
  final String clubId;
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
  @JsonKey(name: 'total_price')
  final double totalPrice;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @override
  final String? clubName;
  @override
  final String? clubLogoUrl;
  @override
  final String? tableName;

  @override
  String toString() {
    return 'ClubBookingHistory(id: $id, clubId: $clubId, tableId: $tableId, bookingDate: $bookingDate, startTime: $startTime, endTime: $endTime, totalPrice: $totalPrice, status: $status, paymentStatus: $paymentStatus, clubName: $clubName, clubLogoUrl: $clubLogoUrl, tableName: $tableName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubBookingHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clubId, clubId) || other.clubId == clubId) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.clubLogoUrl, clubLogoUrl) ||
                other.clubLogoUrl == clubLogoUrl) &&
            (identical(other.tableName, tableName) ||
                other.tableName == tableName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      clubId,
      tableId,
      bookingDate,
      startTime,
      endTime,
      totalPrice,
      status,
      paymentStatus,
      clubName,
      clubLogoUrl,
      tableName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClubBookingHistoryImplCopyWith<_$ClubBookingHistoryImpl> get copyWith =>
      __$$ClubBookingHistoryImplCopyWithImpl<_$ClubBookingHistoryImpl>(
          this, _$identity);
}

abstract class _ClubBookingHistory implements ClubBookingHistory {
  const factory _ClubBookingHistory(
      {required final String id,
      @JsonKey(name: 'club_id') required final String clubId,
      @JsonKey(name: 'table_id') required final String tableId,
      @JsonKey(name: 'booking_date') required final DateTime bookingDate,
      @JsonKey(name: 'start_time') required final DateTime startTime,
      @JsonKey(name: 'end_time') required final DateTime endTime,
      @JsonKey(name: 'total_price') required final double totalPrice,
      final String status,
      @JsonKey(name: 'payment_status') final String? paymentStatus,
      final String? clubName,
      final String? clubLogoUrl,
      final String? tableName}) = _$ClubBookingHistoryImpl;

  @override
  String get id;
  @override
  @JsonKey(name: 'club_id')
  String get clubId;
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
  @JsonKey(name: 'total_price')
  double get totalPrice;
  @override
  String get status;
  @override
  @JsonKey(name: 'payment_status')
  String? get paymentStatus;
  @override
  String? get clubName;
  @override
  String? get clubLogoUrl;
  @override
  String? get tableName;
  @override
  @JsonKey(ignore: true)
  _$$ClubBookingHistoryImplCopyWith<_$ClubBookingHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
