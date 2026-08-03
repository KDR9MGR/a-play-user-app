// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concierge_request_tracking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConciergeRequestTracking _$ConciergeRequestTrackingFromJson(
    Map<String, dynamic> json) {
  return _ConciergeRequestTracking.fromJson(json);
}

/// @nodoc
mixin _$ConciergeRequestTracking {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError; // 1-12
  int get year => throw _privateConstructorUsedError; // >= 2020
  @JsonKey(name: 'request_count')
  int get requestCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConciergeRequestTrackingCopyWith<ConciergeRequestTracking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConciergeRequestTrackingCopyWith<$Res> {
  factory $ConciergeRequestTrackingCopyWith(ConciergeRequestTracking value,
          $Res Function(ConciergeRequestTracking) then) =
      _$ConciergeRequestTrackingCopyWithImpl<$Res, ConciergeRequestTracking>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      int month,
      int year,
      @JsonKey(name: 'request_count') int requestCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$ConciergeRequestTrackingCopyWithImpl<$Res,
        $Val extends ConciergeRequestTracking>
    implements $ConciergeRequestTrackingCopyWith<$Res> {
  _$ConciergeRequestTrackingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? month = null,
    Object? year = null,
    Object? requestCount = null,
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
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      requestCount: null == requestCount
          ? _value.requestCount
          : requestCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConciergeRequestTrackingImplCopyWith<$Res>
    implements $ConciergeRequestTrackingCopyWith<$Res> {
  factory _$$ConciergeRequestTrackingImplCopyWith(
          _$ConciergeRequestTrackingImpl value,
          $Res Function(_$ConciergeRequestTrackingImpl) then) =
      __$$ConciergeRequestTrackingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      int month,
      int year,
      @JsonKey(name: 'request_count') int requestCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$ConciergeRequestTrackingImplCopyWithImpl<$Res>
    extends _$ConciergeRequestTrackingCopyWithImpl<$Res,
        _$ConciergeRequestTrackingImpl>
    implements _$$ConciergeRequestTrackingImplCopyWith<$Res> {
  __$$ConciergeRequestTrackingImplCopyWithImpl(
      _$ConciergeRequestTrackingImpl _value,
      $Res Function(_$ConciergeRequestTrackingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? month = null,
    Object? year = null,
    Object? requestCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ConciergeRequestTrackingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      requestCount: null == requestCount
          ? _value.requestCount
          : requestCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConciergeRequestTrackingImpl implements _ConciergeRequestTracking {
  const _$ConciergeRequestTrackingImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.month,
      required this.year,
      @JsonKey(name: 'request_count') this.requestCount = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$ConciergeRequestTrackingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConciergeRequestTrackingImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final int month;
// 1-12
  @override
  final int year;
// >= 2020
  @override
  @JsonKey(name: 'request_count')
  final int requestCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ConciergeRequestTracking(id: $id, userId: $userId, month: $month, year: $year, requestCount: $requestCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConciergeRequestTrackingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.requestCount, requestCount) ||
                other.requestCount == requestCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, month, year, requestCount, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConciergeRequestTrackingImplCopyWith<_$ConciergeRequestTrackingImpl>
      get copyWith => __$$ConciergeRequestTrackingImplCopyWithImpl<
          _$ConciergeRequestTrackingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConciergeRequestTrackingImplToJson(
      this,
    );
  }
}

abstract class _ConciergeRequestTracking implements ConciergeRequestTracking {
  const factory _ConciergeRequestTracking(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final int month,
          required final int year,
          @JsonKey(name: 'request_count') final int requestCount,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$ConciergeRequestTrackingImpl;

  factory _ConciergeRequestTracking.fromJson(Map<String, dynamic> json) =
      _$ConciergeRequestTrackingImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  int get month;
  @override // 1-12
  int get year;
  @override // >= 2020
  @JsonKey(name: 'request_count')
  int get requestCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ConciergeRequestTrackingImplCopyWith<_$ConciergeRequestTrackingImpl>
      get copyWith => throw _privateConstructorUsedError;
}
