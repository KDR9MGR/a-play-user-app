// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Referral _$ReferralFromJson(Map<String, dynamic> json) {
  return _Referral.fromJson(json);
}

/// @nodoc
mixin _$Referral {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'referral_code')
  String get referralCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'referral_count')
  int get referralCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralCopyWith<Referral> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralCopyWith<$Res> {
  factory $ReferralCopyWith(Referral value, $Res Function(Referral) then) =
      _$ReferralCopyWithImpl<$Res, Referral>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'referral_code') String referralCode,
      @JsonKey(name: 'referral_count') int referralCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ReferralCopyWithImpl<$Res, $Val extends Referral>
    implements $ReferralCopyWith<$Res> {
  _$ReferralCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referralCode = null,
    Object? referralCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      referralCode: null == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String,
      referralCount: null == referralCount
          ? _value.referralCount
          : referralCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralImplCopyWith<$Res>
    implements $ReferralCopyWith<$Res> {
  factory _$$ReferralImplCopyWith(
          _$ReferralImpl value, $Res Function(_$ReferralImpl) then) =
      __$$ReferralImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'referral_code') String referralCode,
      @JsonKey(name: 'referral_count') int referralCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ReferralImplCopyWithImpl<$Res>
    extends _$ReferralCopyWithImpl<$Res, _$ReferralImpl>
    implements _$$ReferralImplCopyWith<$Res> {
  __$$ReferralImplCopyWithImpl(
      _$ReferralImpl _value, $Res Function(_$ReferralImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referralCode = null,
    Object? referralCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ReferralImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      referralCode: null == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String,
      referralCount: null == referralCount
          ? _value.referralCount
          : referralCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralImpl with DiagnosticableTreeMixin implements _Referral {
  const _$ReferralImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'referral_code') required this.referralCode,
      @JsonKey(name: 'referral_count') this.referralCount = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$ReferralImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'referral_code')
  final String referralCode;
  @override
  @JsonKey(name: 'referral_count')
  final int referralCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Referral(id: $id, userId: $userId, referralCode: $referralCode, referralCount: $referralCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Referral'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('referralCode', referralCode))
      ..add(DiagnosticsProperty('referralCount', referralCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.referralCount, referralCount) ||
                other.referralCount == referralCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, referralCode,
      referralCount, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralImplCopyWith<_$ReferralImpl> get copyWith =>
      __$$ReferralImplCopyWithImpl<_$ReferralImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralImplToJson(
      this,
    );
  }
}

abstract class _Referral implements Referral {
  const factory _Referral(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'referral_code') required final String referralCode,
      @JsonKey(name: 'referral_count') final int referralCount,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$ReferralImpl;

  factory _Referral.fromJson(Map<String, dynamic> json) =
      _$ReferralImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'referral_code')
  String get referralCode;
  @override
  @JsonKey(name: 'referral_count')
  int get referralCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ReferralImplCopyWith<_$ReferralImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralHistory _$ReferralHistoryFromJson(Map<String, dynamic> json) {
  return _ReferralHistory.fromJson(json);
}

/// @nodoc
mixin _$ReferralHistory {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'referred_user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'referrer_user_id')
  String get referrerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_earned')
  int get pointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReferralHistoryCopyWith<ReferralHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralHistoryCopyWith<$Res> {
  factory $ReferralHistoryCopyWith(
          ReferralHistory value, $Res Function(ReferralHistory) then) =
      _$ReferralHistoryCopyWithImpl<$Res, ReferralHistory>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'referred_user_id') String userId,
      @JsonKey(name: 'referrer_user_id') String referrerId,
      @JsonKey(name: 'points_earned') int pointsEarned,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ReferralHistoryCopyWithImpl<$Res, $Val extends ReferralHistory>
    implements $ReferralHistoryCopyWith<$Res> {
  _$ReferralHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referrerId = null,
    Object? pointsEarned = null,
    Object? createdAt = null,
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
      referrerId: null == referrerId
          ? _value.referrerId
          : referrerId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralHistoryImplCopyWith<$Res>
    implements $ReferralHistoryCopyWith<$Res> {
  factory _$$ReferralHistoryImplCopyWith(_$ReferralHistoryImpl value,
          $Res Function(_$ReferralHistoryImpl) then) =
      __$$ReferralHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'referred_user_id') String userId,
      @JsonKey(name: 'referrer_user_id') String referrerId,
      @JsonKey(name: 'points_earned') int pointsEarned,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ReferralHistoryImplCopyWithImpl<$Res>
    extends _$ReferralHistoryCopyWithImpl<$Res, _$ReferralHistoryImpl>
    implements _$$ReferralHistoryImplCopyWith<$Res> {
  __$$ReferralHistoryImplCopyWithImpl(
      _$ReferralHistoryImpl _value, $Res Function(_$ReferralHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referrerId = null,
    Object? pointsEarned = null,
    Object? createdAt = null,
  }) {
    return _then(_$ReferralHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      referrerId: null == referrerId
          ? _value.referrerId
          : referrerId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralHistoryImpl
    with DiagnosticableTreeMixin
    implements _ReferralHistory {
  const _$ReferralHistoryImpl(
      {required this.id,
      @JsonKey(name: 'referred_user_id') required this.userId,
      @JsonKey(name: 'referrer_user_id') required this.referrerId,
      @JsonKey(name: 'points_earned') required this.pointsEarned,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ReferralHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralHistoryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'referred_user_id')
  final String userId;
  @override
  @JsonKey(name: 'referrer_user_id')
  final String referrerId;
  @override
  @JsonKey(name: 'points_earned')
  final int pointsEarned;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReferralHistory(id: $id, userId: $userId, referrerId: $referrerId, pointsEarned: $pointsEarned, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ReferralHistory'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('referrerId', referrerId))
      ..add(DiagnosticsProperty('pointsEarned', pointsEarned))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.referrerId, referrerId) ||
                other.referrerId == referrerId) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, referrerId, pointsEarned, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralHistoryImplCopyWith<_$ReferralHistoryImpl> get copyWith =>
      __$$ReferralHistoryImplCopyWithImpl<_$ReferralHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralHistoryImplToJson(
      this,
    );
  }
}

abstract class _ReferralHistory implements ReferralHistory {
  const factory _ReferralHistory(
          {required final String id,
          @JsonKey(name: 'referred_user_id') required final String userId,
          @JsonKey(name: 'referrer_user_id') required final String referrerId,
          @JsonKey(name: 'points_earned') required final int pointsEarned,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ReferralHistoryImpl;

  factory _ReferralHistory.fromJson(Map<String, dynamic> json) =
      _$ReferralHistoryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'referred_user_id')
  String get userId;
  @override
  @JsonKey(name: 'referrer_user_id')
  String get referrerId;
  @override
  @JsonKey(name: 'points_earned')
  int get pointsEarned;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ReferralHistoryImplCopyWith<_$ReferralHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserPoints {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_points')
  int get availablePoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_points')
  int get usedPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_name')
  String? get membershipTierName => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_benefits')
  String? get tierBenefits => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_min_points')
  int? get tierMinPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_max_points')
  int? get tierMaxPoints => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserPointsCopyWith<UserPoints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPointsCopyWith<$Res> {
  factory $UserPointsCopyWith(
          UserPoints value, $Res Function(UserPoints) then) =
      _$UserPointsCopyWithImpl<$Res, UserPoints>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'available_points') int availablePoints,
      @JsonKey(name: 'used_points') int usedPoints,
      @JsonKey(name: 'last_updated') DateTime lastUpdated,
      @JsonKey(name: 'tier_name') String? membershipTierName,
      @JsonKey(name: 'tier_benefits') String? tierBenefits,
      @JsonKey(name: 'tier_min_points') int? tierMinPoints,
      @JsonKey(name: 'tier_max_points') int? tierMaxPoints,
      String? username});
}

/// @nodoc
class _$UserPointsCopyWithImpl<$Res, $Val extends UserPoints>
    implements $UserPointsCopyWith<$Res> {
  _$UserPointsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? totalPoints = null,
    Object? availablePoints = null,
    Object? usedPoints = null,
    Object? lastUpdated = null,
    Object? membershipTierName = freezed,
    Object? tierBenefits = freezed,
    Object? tierMinPoints = freezed,
    Object? tierMaxPoints = freezed,
    Object? username = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      availablePoints: null == availablePoints
          ? _value.availablePoints
          : availablePoints // ignore: cast_nullable_to_non_nullable
              as int,
      usedPoints: null == usedPoints
          ? _value.usedPoints
          : usedPoints // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      membershipTierName: freezed == membershipTierName
          ? _value.membershipTierName
          : membershipTierName // ignore: cast_nullable_to_non_nullable
              as String?,
      tierBenefits: freezed == tierBenefits
          ? _value.tierBenefits
          : tierBenefits // ignore: cast_nullable_to_non_nullable
              as String?,
      tierMinPoints: freezed == tierMinPoints
          ? _value.tierMinPoints
          : tierMinPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      tierMaxPoints: freezed == tierMaxPoints
          ? _value.tierMaxPoints
          : tierMaxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPointsImplCopyWith<$Res>
    implements $UserPointsCopyWith<$Res> {
  factory _$$UserPointsImplCopyWith(
          _$UserPointsImpl value, $Res Function(_$UserPointsImpl) then) =
      __$$UserPointsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'available_points') int availablePoints,
      @JsonKey(name: 'used_points') int usedPoints,
      @JsonKey(name: 'last_updated') DateTime lastUpdated,
      @JsonKey(name: 'tier_name') String? membershipTierName,
      @JsonKey(name: 'tier_benefits') String? tierBenefits,
      @JsonKey(name: 'tier_min_points') int? tierMinPoints,
      @JsonKey(name: 'tier_max_points') int? tierMaxPoints,
      String? username});
}

/// @nodoc
class __$$UserPointsImplCopyWithImpl<$Res>
    extends _$UserPointsCopyWithImpl<$Res, _$UserPointsImpl>
    implements _$$UserPointsImplCopyWith<$Res> {
  __$$UserPointsImplCopyWithImpl(
      _$UserPointsImpl _value, $Res Function(_$UserPointsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? totalPoints = null,
    Object? availablePoints = null,
    Object? usedPoints = null,
    Object? lastUpdated = null,
    Object? membershipTierName = freezed,
    Object? tierBenefits = freezed,
    Object? tierMinPoints = freezed,
    Object? tierMaxPoints = freezed,
    Object? username = freezed,
  }) {
    return _then(_$UserPointsImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      availablePoints: null == availablePoints
          ? _value.availablePoints
          : availablePoints // ignore: cast_nullable_to_non_nullable
              as int,
      usedPoints: null == usedPoints
          ? _value.usedPoints
          : usedPoints // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      membershipTierName: freezed == membershipTierName
          ? _value.membershipTierName
          : membershipTierName // ignore: cast_nullable_to_non_nullable
              as String?,
      tierBenefits: freezed == tierBenefits
          ? _value.tierBenefits
          : tierBenefits // ignore: cast_nullable_to_non_nullable
              as String?,
      tierMinPoints: freezed == tierMinPoints
          ? _value.tierMinPoints
          : tierMinPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      tierMaxPoints: freezed == tierMaxPoints
          ? _value.tierMaxPoints
          : tierMaxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UserPointsImpl extends _UserPoints with DiagnosticableTreeMixin {
  const _$UserPointsImpl(
      {this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'available_points') this.availablePoints = 0,
      @JsonKey(name: 'used_points') this.usedPoints = 0,
      @JsonKey(name: 'last_updated') required this.lastUpdated,
      @JsonKey(name: 'tier_name') this.membershipTierName,
      @JsonKey(name: 'tier_benefits') this.tierBenefits,
      @JsonKey(name: 'tier_min_points') this.tierMinPoints,
      @JsonKey(name: 'tier_max_points') this.tierMaxPoints,
      this.username})
      : super._();

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @override
  @JsonKey(name: 'available_points')
  final int availablePoints;
  @override
  @JsonKey(name: 'used_points')
  final int usedPoints;
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  @override
  @JsonKey(name: 'tier_name')
  final String? membershipTierName;
  @override
  @JsonKey(name: 'tier_benefits')
  final String? tierBenefits;
  @override
  @JsonKey(name: 'tier_min_points')
  final int? tierMinPoints;
  @override
  @JsonKey(name: 'tier_max_points')
  final int? tierMaxPoints;
  @override
  final String? username;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserPoints(id: $id, userId: $userId, totalPoints: $totalPoints, availablePoints: $availablePoints, usedPoints: $usedPoints, lastUpdated: $lastUpdated, membershipTierName: $membershipTierName, tierBenefits: $tierBenefits, tierMinPoints: $tierMinPoints, tierMaxPoints: $tierMaxPoints, username: $username)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserPoints'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('totalPoints', totalPoints))
      ..add(DiagnosticsProperty('availablePoints', availablePoints))
      ..add(DiagnosticsProperty('usedPoints', usedPoints))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated))
      ..add(DiagnosticsProperty('membershipTierName', membershipTierName))
      ..add(DiagnosticsProperty('tierBenefits', tierBenefits))
      ..add(DiagnosticsProperty('tierMinPoints', tierMinPoints))
      ..add(DiagnosticsProperty('tierMaxPoints', tierMaxPoints))
      ..add(DiagnosticsProperty('username', username));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPointsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.availablePoints, availablePoints) ||
                other.availablePoints == availablePoints) &&
            (identical(other.usedPoints, usedPoints) ||
                other.usedPoints == usedPoints) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.membershipTierName, membershipTierName) ||
                other.membershipTierName == membershipTierName) &&
            (identical(other.tierBenefits, tierBenefits) ||
                other.tierBenefits == tierBenefits) &&
            (identical(other.tierMinPoints, tierMinPoints) ||
                other.tierMinPoints == tierMinPoints) &&
            (identical(other.tierMaxPoints, tierMaxPoints) ||
                other.tierMaxPoints == tierMaxPoints) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      totalPoints,
      availablePoints,
      usedPoints,
      lastUpdated,
      membershipTierName,
      tierBenefits,
      tierMinPoints,
      tierMaxPoints,
      username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPointsImplCopyWith<_$UserPointsImpl> get copyWith =>
      __$$UserPointsImplCopyWithImpl<_$UserPointsImpl>(this, _$identity);
}

abstract class _UserPoints extends UserPoints {
  const factory _UserPoints(
      {final String? id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'total_points') final int totalPoints,
      @JsonKey(name: 'available_points') final int availablePoints,
      @JsonKey(name: 'used_points') final int usedPoints,
      @JsonKey(name: 'last_updated') required final DateTime lastUpdated,
      @JsonKey(name: 'tier_name') final String? membershipTierName,
      @JsonKey(name: 'tier_benefits') final String? tierBenefits,
      @JsonKey(name: 'tier_min_points') final int? tierMinPoints,
      @JsonKey(name: 'tier_max_points') final int? tierMaxPoints,
      final String? username}) = _$UserPointsImpl;
  const _UserPoints._() : super._();

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;
  @override
  @JsonKey(name: 'available_points')
  int get availablePoints;
  @override
  @JsonKey(name: 'used_points')
  int get usedPoints;
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;
  @override
  @JsonKey(name: 'tier_name')
  String? get membershipTierName;
  @override
  @JsonKey(name: 'tier_benefits')
  String? get tierBenefits;
  @override
  @JsonKey(name: 'tier_min_points')
  int? get tierMinPoints;
  @override
  @JsonKey(name: 'tier_max_points')
  int? get tierMaxPoints;
  @override
  String? get username;
  @override
  @JsonKey(ignore: true)
  _$$UserPointsImplCopyWith<_$UserPointsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PointTransaction _$PointTransactionFromJson(Map<String, dynamic> json) {
  return _PointTransaction.fromJson(json);
}

/// @nodoc
mixin _$PointTransaction {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String get transactionType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointTransactionCopyWith<PointTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointTransactionCopyWith<$Res> {
  factory $PointTransactionCopyWith(
          PointTransaction value, $Res Function(PointTransaction) then) =
      _$PointTransactionCopyWithImpl<$Res, PointTransaction>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      int points,
      @JsonKey(name: 'transaction_type') String transactionType,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$PointTransactionCopyWithImpl<$Res, $Val extends PointTransaction>
    implements $PointTransactionCopyWith<$Res> {
  _$PointTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? points = null,
    Object? transactionType = null,
    Object? description = null,
    Object? createdAt = null,
    Object? metadata = freezed,
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
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointTransactionImplCopyWith<$Res>
    implements $PointTransactionCopyWith<$Res> {
  factory _$$PointTransactionImplCopyWith(_$PointTransactionImpl value,
          $Res Function(_$PointTransactionImpl) then) =
      __$$PointTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      int points,
      @JsonKey(name: 'transaction_type') String transactionType,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$PointTransactionImplCopyWithImpl<$Res>
    extends _$PointTransactionCopyWithImpl<$Res, _$PointTransactionImpl>
    implements _$$PointTransactionImplCopyWith<$Res> {
  __$$PointTransactionImplCopyWithImpl(_$PointTransactionImpl _value,
      $Res Function(_$PointTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? points = null,
    Object? transactionType = null,
    Object? description = null,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_$PointTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointTransactionImpl
    with DiagnosticableTreeMixin
    implements _PointTransaction {
  const _$PointTransactionImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.points,
      @JsonKey(name: 'transaction_type') required this.transactionType,
      this.description = '',
      @JsonKey(name: 'created_at') required this.createdAt,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$PointTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointTransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final int points;
  @override
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PointTransaction(id: $id, userId: $userId, points: $points, transactionType: $transactionType, description: $description, createdAt: $createdAt, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PointTransaction'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('points', points))
      ..add(DiagnosticsProperty('transactionType', transactionType))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      points,
      transactionType,
      description,
      createdAt,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      __$$PointTransactionImplCopyWithImpl<_$PointTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointTransactionImplToJson(
      this,
    );
  }
}

abstract class _PointTransaction implements PointTransaction {
  const factory _PointTransaction(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      required final int points,
      @JsonKey(name: 'transaction_type') required final String transactionType,
      final String description,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final Map<String, dynamic>? metadata}) = _$PointTransactionImpl;

  factory _PointTransaction.fromJson(Map<String, dynamic> json) =
      _$PointTransactionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  int get points;
  @override
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  @override
  String get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$PointTransactionImplCopyWith<_$PointTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MembershipTier _$MembershipTierFromJson(Map<String, dynamic> json) {
  return _MembershipTier.fromJson(json);
}

/// @nodoc
mixin _$MembershipTier {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_points')
  int get minPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_points')
  int? get maxPoints => throw _privateConstructorUsedError;
  String? get benefits => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MembershipTierCopyWith<MembershipTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipTierCopyWith<$Res> {
  factory $MembershipTierCopyWith(
          MembershipTier value, $Res Function(MembershipTier) then) =
      _$MembershipTierCopyWithImpl<$Res, MembershipTier>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'min_points') int minPoints,
      @JsonKey(name: 'max_points') int? maxPoints,
      String? benefits,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$MembershipTierCopyWithImpl<$Res, $Val extends MembershipTier>
    implements $MembershipTierCopyWith<$Res> {
  _$MembershipTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? minPoints = null,
    Object? maxPoints = freezed,
    Object? benefits = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      minPoints: null == minPoints
          ? _value.minPoints
          : minPoints // ignore: cast_nullable_to_non_nullable
              as int,
      maxPoints: freezed == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      benefits: freezed == benefits
          ? _value.benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipTierImplCopyWith<$Res>
    implements $MembershipTierCopyWith<$Res> {
  factory _$$MembershipTierImplCopyWith(_$MembershipTierImpl value,
          $Res Function(_$MembershipTierImpl) then) =
      __$$MembershipTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'min_points') int minPoints,
      @JsonKey(name: 'max_points') int? maxPoints,
      String? benefits,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$MembershipTierImplCopyWithImpl<$Res>
    extends _$MembershipTierCopyWithImpl<$Res, _$MembershipTierImpl>
    implements _$$MembershipTierImplCopyWith<$Res> {
  __$$MembershipTierImplCopyWithImpl(
      _$MembershipTierImpl _value, $Res Function(_$MembershipTierImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? minPoints = null,
    Object? maxPoints = freezed,
    Object? benefits = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MembershipTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      minPoints: null == minPoints
          ? _value.minPoints
          : minPoints // ignore: cast_nullable_to_non_nullable
              as int,
      maxPoints: freezed == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      benefits: freezed == benefits
          ? _value.benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipTierImpl
    with DiagnosticableTreeMixin
    implements _MembershipTier {
  const _$MembershipTierImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'min_points') required this.minPoints,
      @JsonKey(name: 'max_points') this.maxPoints,
      this.benefits,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$MembershipTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipTierImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'min_points')
  final int minPoints;
  @override
  @JsonKey(name: 'max_points')
  final int? maxPoints;
  @override
  final String? benefits;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MembershipTier(id: $id, name: $name, minPoints: $minPoints, maxPoints: $maxPoints, benefits: $benefits, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MembershipTier'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('minPoints', minPoints))
      ..add(DiagnosticsProperty('maxPoints', maxPoints))
      ..add(DiagnosticsProperty('benefits', benefits))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.minPoints, minPoints) ||
                other.minPoints == minPoints) &&
            (identical(other.maxPoints, maxPoints) ||
                other.maxPoints == maxPoints) &&
            (identical(other.benefits, benefits) ||
                other.benefits == benefits) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, minPoints, maxPoints,
      benefits, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipTierImplCopyWith<_$MembershipTierImpl> get copyWith =>
      __$$MembershipTierImplCopyWithImpl<_$MembershipTierImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipTierImplToJson(
      this,
    );
  }
}

abstract class _MembershipTier implements MembershipTier {
  const factory _MembershipTier(
          {required final String id,
          required final String name,
          @JsonKey(name: 'min_points') required final int minPoints,
          @JsonKey(name: 'max_points') final int? maxPoints,
          final String? benefits,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$MembershipTierImpl;

  factory _MembershipTier.fromJson(Map<String, dynamic> json) =
      _$MembershipTierImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'min_points')
  int get minPoints;
  @override
  @JsonKey(name: 'max_points')
  int? get maxPoints;
  @override
  String? get benefits;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MembershipTierImplCopyWith<_$MembershipTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserChallenge _$UserChallengeFromJson(Map<String, dynamic> json) {
  return _UserChallenge.fromJson(json);
}

/// @nodoc
mixin _$UserChallenge {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'challenge_type')
  String get challengeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_count')
  int get targetCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_days')
  int get periodDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'reward_points')
  int get rewardPoints => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserChallengeCopyWith<UserChallenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserChallengeCopyWith<$Res> {
  factory $UserChallengeCopyWith(
          UserChallenge value, $Res Function(UserChallenge) then) =
      _$UserChallengeCopyWithImpl<$Res, UserChallenge>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'challenge_type') String challengeType,
      @JsonKey(name: 'target_count') int targetCount,
      @JsonKey(name: 'period_days') int periodDays,
      @JsonKey(name: 'reward_points') int rewardPoints,
      bool active,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$UserChallengeCopyWithImpl<$Res, $Val extends UserChallenge>
    implements $UserChallengeCopyWith<$Res> {
  _$UserChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? challengeType = null,
    Object? targetCount = null,
    Object? periodDays = null,
    Object? rewardPoints = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      challengeType: null == challengeType
          ? _value.challengeType
          : challengeType // ignore: cast_nullable_to_non_nullable
              as String,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      periodDays: null == periodDays
          ? _value.periodDays
          : periodDays // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserChallengeImplCopyWith<$Res>
    implements $UserChallengeCopyWith<$Res> {
  factory _$$UserChallengeImplCopyWith(
          _$UserChallengeImpl value, $Res Function(_$UserChallengeImpl) then) =
      __$$UserChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'challenge_type') String challengeType,
      @JsonKey(name: 'target_count') int targetCount,
      @JsonKey(name: 'period_days') int periodDays,
      @JsonKey(name: 'reward_points') int rewardPoints,
      bool active,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$UserChallengeImplCopyWithImpl<$Res>
    extends _$UserChallengeCopyWithImpl<$Res, _$UserChallengeImpl>
    implements _$$UserChallengeImplCopyWith<$Res> {
  __$$UserChallengeImplCopyWithImpl(
      _$UserChallengeImpl _value, $Res Function(_$UserChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? challengeType = null,
    Object? targetCount = null,
    Object? periodDays = null,
    Object? rewardPoints = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      challengeType: null == challengeType
          ? _value.challengeType
          : challengeType // ignore: cast_nullable_to_non_nullable
              as String,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      periodDays: null == periodDays
          ? _value.periodDays
          : periodDays // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserChallengeImpl
    with DiagnosticableTreeMixin
    implements _UserChallenge {
  const _$UserChallengeImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'challenge_type') required this.challengeType,
      @JsonKey(name: 'target_count') required this.targetCount,
      @JsonKey(name: 'period_days') required this.periodDays,
      @JsonKey(name: 'reward_points') required this.rewardPoints,
      this.active = true,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$UserChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'challenge_type')
  final String challengeType;
  @override
  @JsonKey(name: 'target_count')
  final int targetCount;
  @override
  @JsonKey(name: 'period_days')
  final int periodDays;
  @override
  @JsonKey(name: 'reward_points')
  final int rewardPoints;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserChallenge(id: $id, name: $name, description: $description, challengeType: $challengeType, targetCount: $targetCount, periodDays: $periodDays, rewardPoints: $rewardPoints, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserChallenge'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('challengeType', challengeType))
      ..add(DiagnosticsProperty('targetCount', targetCount))
      ..add(DiagnosticsProperty('periodDays', periodDays))
      ..add(DiagnosticsProperty('rewardPoints', rewardPoints))
      ..add(DiagnosticsProperty('active', active))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.challengeType, challengeType) ||
                other.challengeType == challengeType) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount) &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      challengeType,
      targetCount,
      periodDays,
      rewardPoints,
      active,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserChallengeImplCopyWith<_$UserChallengeImpl> get copyWith =>
      __$$UserChallengeImplCopyWithImpl<_$UserChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserChallengeImplToJson(
      this,
    );
  }
}

abstract class _UserChallenge implements UserChallenge {
  const factory _UserChallenge(
          {required final String id,
          required final String name,
          final String? description,
          @JsonKey(name: 'challenge_type') required final String challengeType,
          @JsonKey(name: 'target_count') required final int targetCount,
          @JsonKey(name: 'period_days') required final int periodDays,
          @JsonKey(name: 'reward_points') required final int rewardPoints,
          final bool active,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$UserChallengeImpl;

  factory _UserChallenge.fromJson(Map<String, dynamic> json) =
      _$UserChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'challenge_type')
  String get challengeType;
  @override
  @JsonKey(name: 'target_count')
  int get targetCount;
  @override
  @JsonKey(name: 'period_days')
  int get periodDays;
  @override
  @JsonKey(name: 'reward_points')
  int get rewardPoints;
  @override
  bool get active;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserChallengeImplCopyWith<_$UserChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserChallengeProgress _$UserChallengeProgressFromJson(
    Map<String, dynamic> json) {
  return _UserChallengeProgress.fromJson(json);
}

/// @nodoc
mixin _$UserChallengeProgress {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'challenge_id')
  String get challengeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_count')
  int get currentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  UserChallenge? get challenge => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserChallengeProgressCopyWith<UserChallengeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserChallengeProgressCopyWith<$Res> {
  factory $UserChallengeProgressCopyWith(UserChallengeProgress value,
          $Res Function(UserChallengeProgress) then) =
      _$UserChallengeProgressCopyWithImpl<$Res, UserChallengeProgress>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'challenge_id') String challengeId,
      @JsonKey(name: 'current_count') int currentCount,
      @JsonKey(name: 'start_date') DateTime startDate,
      bool completed,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      UserChallenge? challenge});

  $UserChallengeCopyWith<$Res>? get challenge;
}

/// @nodoc
class _$UserChallengeProgressCopyWithImpl<$Res,
        $Val extends UserChallengeProgress>
    implements $UserChallengeProgressCopyWith<$Res> {
  _$UserChallengeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? currentCount = null,
    Object? startDate = null,
    Object? completed = null,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? challenge = freezed,
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
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challenge: freezed == challenge
          ? _value.challenge
          : challenge // ignore: cast_nullable_to_non_nullable
              as UserChallenge?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserChallengeCopyWith<$Res>? get challenge {
    if (_value.challenge == null) {
      return null;
    }

    return $UserChallengeCopyWith<$Res>(_value.challenge!, (value) {
      return _then(_value.copyWith(challenge: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserChallengeProgressImplCopyWith<$Res>
    implements $UserChallengeProgressCopyWith<$Res> {
  factory _$$UserChallengeProgressImplCopyWith(
          _$UserChallengeProgressImpl value,
          $Res Function(_$UserChallengeProgressImpl) then) =
      __$$UserChallengeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'challenge_id') String challengeId,
      @JsonKey(name: 'current_count') int currentCount,
      @JsonKey(name: 'start_date') DateTime startDate,
      bool completed,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      UserChallenge? challenge});

  @override
  $UserChallengeCopyWith<$Res>? get challenge;
}

/// @nodoc
class __$$UserChallengeProgressImplCopyWithImpl<$Res>
    extends _$UserChallengeProgressCopyWithImpl<$Res,
        _$UserChallengeProgressImpl>
    implements _$$UserChallengeProgressImplCopyWith<$Res> {
  __$$UserChallengeProgressImplCopyWithImpl(_$UserChallengeProgressImpl _value,
      $Res Function(_$UserChallengeProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? currentCount = null,
    Object? startDate = null,
    Object? completed = null,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? challenge = freezed,
  }) {
    return _then(_$UserChallengeProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challenge: freezed == challenge
          ? _value.challenge
          : challenge // ignore: cast_nullable_to_non_nullable
              as UserChallenge?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserChallengeProgressImpl
    with DiagnosticableTreeMixin
    implements _UserChallengeProgress {
  const _$UserChallengeProgressImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'challenge_id') required this.challengeId,
      @JsonKey(name: 'current_count') this.currentCount = 0,
      @JsonKey(name: 'start_date') required this.startDate,
      this.completed = false,
      @JsonKey(name: 'completed_at') this.completedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.challenge});

  factory _$UserChallengeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserChallengeProgressImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'challenge_id')
  final String challengeId;
  @override
  @JsonKey(name: 'current_count')
  final int currentCount;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey()
  final bool completed;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  final UserChallenge? challenge;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserChallengeProgress(id: $id, userId: $userId, challengeId: $challengeId, currentCount: $currentCount, startDate: $startDate, completed: $completed, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, challenge: $challenge)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserChallengeProgress'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('challengeId', challengeId))
      ..add(DiagnosticsProperty('currentCount', currentCount))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('completed', completed))
      ..add(DiagnosticsProperty('completedAt', completedAt))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('challenge', challenge));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChallengeProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.currentCount, currentCount) ||
                other.currentCount == currentCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.challenge, challenge) ||
                other.challenge == challenge));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      challengeId,
      currentCount,
      startDate,
      completed,
      completedAt,
      createdAt,
      updatedAt,
      challenge);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserChallengeProgressImplCopyWith<_$UserChallengeProgressImpl>
      get copyWith => __$$UserChallengeProgressImplCopyWithImpl<
          _$UserChallengeProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserChallengeProgressImplToJson(
      this,
    );
  }
}

abstract class _UserChallengeProgress implements UserChallengeProgress {
  const factory _UserChallengeProgress(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'challenge_id') required final String challengeId,
      @JsonKey(name: 'current_count') final int currentCount,
      @JsonKey(name: 'start_date') required final DateTime startDate,
      final bool completed,
      @JsonKey(name: 'completed_at') final DateTime? completedAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      final UserChallenge? challenge}) = _$UserChallengeProgressImpl;

  factory _UserChallengeProgress.fromJson(Map<String, dynamic> json) =
      _$UserChallengeProgressImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'challenge_id')
  String get challengeId;
  @override
  @JsonKey(name: 'current_count')
  int get currentCount;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  bool get completed;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  UserChallenge? get challenge;
  @override
  @JsonKey(ignore: true)
  _$$UserChallengeProgressImplCopyWith<_$UserChallengeProgressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PointRedemption _$PointRedemptionFromJson(Map<String, dynamic> json) {
  return _PointRedemption.fromJson(json);
}

/// @nodoc
mixin _$PointRedemption {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_spent')
  int get pointsSpent => throw _privateConstructorUsedError;
  @JsonKey(name: 'reward_type')
  String get rewardType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reward_value')
  double get rewardValue => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'redemption_code')
  String? get redemptionCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'affiliate_id')
  String? get affiliateId => throw _privateConstructorUsedError;
  @JsonKey(name: 'settlement_id')
  String? get settlementId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'redeemed_at')
  DateTime? get redeemedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointRedemptionCopyWith<PointRedemption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointRedemptionCopyWith<$Res> {
  factory $PointRedemptionCopyWith(
          PointRedemption value, $Res Function(PointRedemption) then) =
      _$PointRedemptionCopyWithImpl<$Res, PointRedemption>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'points_spent') int pointsSpent,
      @JsonKey(name: 'reward_type') String rewardType,
      @JsonKey(name: 'reward_value') double rewardValue,
      String description,
      String status,
      @JsonKey(name: 'redemption_code') String? redemptionCode,
      @JsonKey(name: 'affiliate_id') String? affiliateId,
      @JsonKey(name: 'settlement_id') String? settlementId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'redeemed_at') DateTime? redeemedAt});
}

/// @nodoc
class _$PointRedemptionCopyWithImpl<$Res, $Val extends PointRedemption>
    implements $PointRedemptionCopyWith<$Res> {
  _$PointRedemptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? pointsSpent = null,
    Object? rewardType = null,
    Object? rewardValue = null,
    Object? description = null,
    Object? status = null,
    Object? redemptionCode = freezed,
    Object? affiliateId = freezed,
    Object? settlementId = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? redeemedAt = freezed,
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
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      rewardType: null == rewardType
          ? _value.rewardType
          : rewardType // ignore: cast_nullable_to_non_nullable
              as String,
      rewardValue: null == rewardValue
          ? _value.rewardValue
          : rewardValue // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      redemptionCode: freezed == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateId: freezed == affiliateId
          ? _value.affiliateId
          : affiliateId // ignore: cast_nullable_to_non_nullable
              as String?,
      settlementId: freezed == settlementId
          ? _value.settlementId
          : settlementId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redeemedAt: freezed == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointRedemptionImplCopyWith<$Res>
    implements $PointRedemptionCopyWith<$Res> {
  factory _$$PointRedemptionImplCopyWith(_$PointRedemptionImpl value,
          $Res Function(_$PointRedemptionImpl) then) =
      __$$PointRedemptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'points_spent') int pointsSpent,
      @JsonKey(name: 'reward_type') String rewardType,
      @JsonKey(name: 'reward_value') double rewardValue,
      String description,
      String status,
      @JsonKey(name: 'redemption_code') String? redemptionCode,
      @JsonKey(name: 'affiliate_id') String? affiliateId,
      @JsonKey(name: 'settlement_id') String? settlementId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'redeemed_at') DateTime? redeemedAt});
}

/// @nodoc
class __$$PointRedemptionImplCopyWithImpl<$Res>
    extends _$PointRedemptionCopyWithImpl<$Res, _$PointRedemptionImpl>
    implements _$$PointRedemptionImplCopyWith<$Res> {
  __$$PointRedemptionImplCopyWithImpl(
      _$PointRedemptionImpl _value, $Res Function(_$PointRedemptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? pointsSpent = null,
    Object? rewardType = null,
    Object? rewardValue = null,
    Object? description = null,
    Object? status = null,
    Object? redemptionCode = freezed,
    Object? affiliateId = freezed,
    Object? settlementId = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? redeemedAt = freezed,
  }) {
    return _then(_$PointRedemptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      rewardType: null == rewardType
          ? _value.rewardType
          : rewardType // ignore: cast_nullable_to_non_nullable
              as String,
      rewardValue: null == rewardValue
          ? _value.rewardValue
          : rewardValue // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      redemptionCode: freezed == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateId: freezed == affiliateId
          ? _value.affiliateId
          : affiliateId // ignore: cast_nullable_to_non_nullable
              as String?,
      settlementId: freezed == settlementId
          ? _value.settlementId
          : settlementId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redeemedAt: freezed == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointRedemptionImpl
    with DiagnosticableTreeMixin
    implements _PointRedemption {
  const _$PointRedemptionImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'points_spent') required this.pointsSpent,
      @JsonKey(name: 'reward_type') required this.rewardType,
      @JsonKey(name: 'reward_value') this.rewardValue = 0,
      this.description = '',
      this.status = 'pending',
      @JsonKey(name: 'redemption_code') this.redemptionCode,
      @JsonKey(name: 'affiliate_id') this.affiliateId,
      @JsonKey(name: 'settlement_id') this.settlementId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'redeemed_at') this.redeemedAt});

  factory _$PointRedemptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointRedemptionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'points_spent')
  final int pointsSpent;
  @override
  @JsonKey(name: 'reward_type')
  final String rewardType;
  @override
  @JsonKey(name: 'reward_value')
  final double rewardValue;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'redemption_code')
  final String? redemptionCode;
  @override
  @JsonKey(name: 'affiliate_id')
  final String? affiliateId;
  @override
  @JsonKey(name: 'settlement_id')
  final String? settlementId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'redeemed_at')
  final DateTime? redeemedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PointRedemption(id: $id, userId: $userId, pointsSpent: $pointsSpent, rewardType: $rewardType, rewardValue: $rewardValue, description: $description, status: $status, redemptionCode: $redemptionCode, affiliateId: $affiliateId, settlementId: $settlementId, createdAt: $createdAt, expiresAt: $expiresAt, redeemedAt: $redeemedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PointRedemption'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('pointsSpent', pointsSpent))
      ..add(DiagnosticsProperty('rewardType', rewardType))
      ..add(DiagnosticsProperty('rewardValue', rewardValue))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('redemptionCode', redemptionCode))
      ..add(DiagnosticsProperty('affiliateId', affiliateId))
      ..add(DiagnosticsProperty('settlementId', settlementId))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('expiresAt', expiresAt))
      ..add(DiagnosticsProperty('redeemedAt', redeemedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointRedemptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.pointsSpent, pointsSpent) ||
                other.pointsSpent == pointsSpent) &&
            (identical(other.rewardType, rewardType) ||
                other.rewardType == rewardType) &&
            (identical(other.rewardValue, rewardValue) ||
                other.rewardValue == rewardValue) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.redemptionCode, redemptionCode) ||
                other.redemptionCode == redemptionCode) &&
            (identical(other.affiliateId, affiliateId) ||
                other.affiliateId == affiliateId) &&
            (identical(other.settlementId, settlementId) ||
                other.settlementId == settlementId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.redeemedAt, redeemedAt) ||
                other.redeemedAt == redeemedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      pointsSpent,
      rewardType,
      rewardValue,
      description,
      status,
      redemptionCode,
      affiliateId,
      settlementId,
      createdAt,
      expiresAt,
      redeemedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointRedemptionImplCopyWith<_$PointRedemptionImpl> get copyWith =>
      __$$PointRedemptionImplCopyWithImpl<_$PointRedemptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointRedemptionImplToJson(
      this,
    );
  }
}

abstract class _PointRedemption implements PointRedemption {
  const factory _PointRedemption(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'points_spent') required final int pointsSpent,
          @JsonKey(name: 'reward_type') required final String rewardType,
          @JsonKey(name: 'reward_value') final double rewardValue,
          final String description,
          final String status,
          @JsonKey(name: 'redemption_code') final String? redemptionCode,
          @JsonKey(name: 'affiliate_id') final String? affiliateId,
          @JsonKey(name: 'settlement_id') final String? settlementId,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'expires_at') final DateTime? expiresAt,
          @JsonKey(name: 'redeemed_at') final DateTime? redeemedAt}) =
      _$PointRedemptionImpl;

  factory _PointRedemption.fromJson(Map<String, dynamic> json) =
      _$PointRedemptionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'points_spent')
  int get pointsSpent;
  @override
  @JsonKey(name: 'reward_type')
  String get rewardType;
  @override
  @JsonKey(name: 'reward_value')
  double get rewardValue;
  @override
  String get description;
  @override
  String get status;
  @override
  @JsonKey(name: 'redemption_code')
  String? get redemptionCode;
  @override
  @JsonKey(name: 'affiliate_id')
  String? get affiliateId;
  @override
  @JsonKey(name: 'settlement_id')
  String? get settlementId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'redeemed_at')
  DateTime? get redeemedAt;
  @override
  @JsonKey(ignore: true)
  _$$PointRedemptionImplCopyWith<_$PointRedemptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Affiliate _$AffiliateFromJson(Map<String, dynamic> json) {
  return _Affiliate.fromJson(json);
}

/// @nodoc
mixin _$Affiliate {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_name')
  String get businessName => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_name')
  String? get contactName => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_email')
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'point_value_ghs')
  double? get pointValueGhs => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AffiliateCopyWith<Affiliate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AffiliateCopyWith<$Res> {
  factory $AffiliateCopyWith(Affiliate value, $Res Function(Affiliate) then) =
      _$AffiliateCopyWithImpl<$Res, Affiliate>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'business_name') String businessName,
      String? category,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_email') String? contactEmail,
      String? address,
      @JsonKey(name: 'point_value_ghs') double? pointValueGhs,
      @JsonKey(name: 'is_active') bool isActive,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$AffiliateCopyWithImpl<$Res, $Val extends Affiliate>
    implements $AffiliateCopyWith<$Res> {
  _$AffiliateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? businessName = null,
    Object? category = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? address = freezed,
    Object? pointValueGhs = freezed,
    Object? isActive = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      pointValueGhs: freezed == pointValueGhs
          ? _value.pointValueGhs
          : pointValueGhs // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AffiliateImplCopyWith<$Res>
    implements $AffiliateCopyWith<$Res> {
  factory _$$AffiliateImplCopyWith(
          _$AffiliateImpl value, $Res Function(_$AffiliateImpl) then) =
      __$$AffiliateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'business_name') String businessName,
      String? category,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_email') String? contactEmail,
      String? address,
      @JsonKey(name: 'point_value_ghs') double? pointValueGhs,
      @JsonKey(name: 'is_active') bool isActive,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$AffiliateImplCopyWithImpl<$Res>
    extends _$AffiliateCopyWithImpl<$Res, _$AffiliateImpl>
    implements _$$AffiliateImplCopyWith<$Res> {
  __$$AffiliateImplCopyWithImpl(
      _$AffiliateImpl _value, $Res Function(_$AffiliateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? businessName = null,
    Object? category = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? address = freezed,
    Object? pointValueGhs = freezed,
    Object? isActive = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AffiliateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      pointValueGhs: freezed == pointValueGhs
          ? _value.pointValueGhs
          : pointValueGhs // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AffiliateImpl with DiagnosticableTreeMixin implements _Affiliate {
  const _$AffiliateImpl(
      {required this.id,
      @JsonKey(name: 'business_name') required this.businessName,
      this.category,
      @JsonKey(name: 'contact_name') this.contactName,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'contact_email') this.contactEmail,
      this.address,
      @JsonKey(name: 'point_value_ghs') this.pointValueGhs,
      @JsonKey(name: 'is_active') this.isActive = true,
      this.notes,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$AffiliateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AffiliateImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'business_name')
  final String businessName;
  @override
  final String? category;
  @override
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  final String? address;
  @override
  @JsonKey(name: 'point_value_ghs')
  final double? pointValueGhs;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Affiliate(id: $id, businessName: $businessName, category: $category, contactName: $contactName, contactPhone: $contactPhone, contactEmail: $contactEmail, address: $address, pointValueGhs: $pointValueGhs, isActive: $isActive, notes: $notes, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Affiliate'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('businessName', businessName))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('contactName', contactName))
      ..add(DiagnosticsProperty('contactPhone', contactPhone))
      ..add(DiagnosticsProperty('contactEmail', contactEmail))
      ..add(DiagnosticsProperty('address', address))
      ..add(DiagnosticsProperty('pointValueGhs', pointValueGhs))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AffiliateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.pointValueGhs, pointValueGhs) ||
                other.pointValueGhs == pointValueGhs) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      businessName,
      category,
      contactName,
      contactPhone,
      contactEmail,
      address,
      pointValueGhs,
      isActive,
      notes,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AffiliateImplCopyWith<_$AffiliateImpl> get copyWith =>
      __$$AffiliateImplCopyWithImpl<_$AffiliateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AffiliateImplToJson(
      this,
    );
  }
}

abstract class _Affiliate implements Affiliate {
  const factory _Affiliate(
          {required final String id,
          @JsonKey(name: 'business_name') required final String businessName,
          final String? category,
          @JsonKey(name: 'contact_name') final String? contactName,
          @JsonKey(name: 'contact_phone') final String? contactPhone,
          @JsonKey(name: 'contact_email') final String? contactEmail,
          final String? address,
          @JsonKey(name: 'point_value_ghs') final double? pointValueGhs,
          @JsonKey(name: 'is_active') final bool isActive,
          final String? notes,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$AffiliateImpl;

  factory _Affiliate.fromJson(Map<String, dynamic> json) =
      _$AffiliateImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'business_name')
  String get businessName;
  @override
  String? get category;
  @override
  @JsonKey(name: 'contact_name')
  String? get contactName;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @override
  String? get address;
  @override
  @JsonKey(name: 'point_value_ghs')
  double? get pointValueGhs;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$AffiliateImplCopyWith<_$AffiliateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeLimitedOffer _$TimeLimitedOfferFromJson(Map<String, dynamic> json) {
  return _TimeLimitedOffer.fromJson(json);
}

/// @nodoc
mixin _$TimeLimitedOffer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get multiplier => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeLimitedOfferCopyWith<TimeLimitedOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeLimitedOfferCopyWith<$Res> {
  factory $TimeLimitedOfferCopyWith(
          TimeLimitedOffer value, $Res Function(TimeLimitedOffer) then) =
      _$TimeLimitedOfferCopyWithImpl<$Res, TimeLimitedOffer>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      double multiplier,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      bool active,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$TimeLimitedOfferCopyWithImpl<$Res, $Val extends TimeLimitedOffer>
    implements $TimeLimitedOfferCopyWith<$Res> {
  _$TimeLimitedOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? multiplier = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeLimitedOfferImplCopyWith<$Res>
    implements $TimeLimitedOfferCopyWith<$Res> {
  factory _$$TimeLimitedOfferImplCopyWith(_$TimeLimitedOfferImpl value,
          $Res Function(_$TimeLimitedOfferImpl) then) =
      __$$TimeLimitedOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      double multiplier,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      bool active,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$TimeLimitedOfferImplCopyWithImpl<$Res>
    extends _$TimeLimitedOfferCopyWithImpl<$Res, _$TimeLimitedOfferImpl>
    implements _$$TimeLimitedOfferImplCopyWith<$Res> {
  __$$TimeLimitedOfferImplCopyWithImpl(_$TimeLimitedOfferImpl _value,
      $Res Function(_$TimeLimitedOfferImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? multiplier = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TimeLimitedOfferImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeLimitedOfferImpl
    with DiagnosticableTreeMixin
    implements _TimeLimitedOffer {
  const _$TimeLimitedOfferImpl(
      {required this.id,
      required this.name,
      this.description,
      this.multiplier = 1.0,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      this.active = true,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$TimeLimitedOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeLimitedOfferImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final double multiplier;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TimeLimitedOffer(id: $id, name: $name, description: $description, multiplier: $multiplier, startDate: $startDate, endDate: $endDate, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TimeLimitedOffer'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('multiplier', multiplier))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('active', active))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeLimitedOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description,
      multiplier, startDate, endDate, active, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeLimitedOfferImplCopyWith<_$TimeLimitedOfferImpl> get copyWith =>
      __$$TimeLimitedOfferImplCopyWithImpl<_$TimeLimitedOfferImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeLimitedOfferImplToJson(
      this,
    );
  }
}

abstract class _TimeLimitedOffer implements TimeLimitedOffer {
  const factory _TimeLimitedOffer(
          {required final String id,
          required final String name,
          final String? description,
          final double multiplier,
          @JsonKey(name: 'start_date') required final DateTime startDate,
          @JsonKey(name: 'end_date') required final DateTime endDate,
          final bool active,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$TimeLimitedOfferImpl;

  factory _TimeLimitedOffer.fromJson(Map<String, dynamic> json) =
      _$TimeLimitedOfferImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get multiplier;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  bool get active;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TimeLimitedOfferImplCopyWith<_$TimeLimitedOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
