// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserTierInfo _$UserTierInfoFromJson(Map<String, dynamic> json) {
  return _UserTierInfo.fromJson(json);
}

/// @nodoc
mixin _$UserTierInfo {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_tier')
  UserTier get currentTier => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_progress')
  int get tierProgress => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_tier_threshold')
  int get nextTierThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_benefits')
  List<String>? get tierBenefits => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserTierInfoCopyWith<UserTierInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserTierInfoCopyWith<$Res> {
  factory $UserTierInfoCopyWith(
          UserTierInfo value, $Res Function(UserTierInfo) then) =
      _$UserTierInfoCopyWithImpl<$Res, UserTierInfo>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'current_tier') UserTier currentTier,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'tier_progress') int tierProgress,
      @JsonKey(name: 'next_tier_threshold') int nextTierThreshold,
      @JsonKey(name: 'tier_benefits') List<String>? tierBenefits,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$UserTierInfoCopyWithImpl<$Res, $Val extends UserTierInfo>
    implements $UserTierInfoCopyWith<$Res> {
  _$UserTierInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentTier = null,
    Object? totalPoints = null,
    Object? tierProgress = null,
    Object? nextTierThreshold = null,
    Object? tierBenefits = freezed,
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
      currentTier: null == currentTier
          ? _value.currentTier
          : currentTier // ignore: cast_nullable_to_non_nullable
              as UserTier,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      tierProgress: null == tierProgress
          ? _value.tierProgress
          : tierProgress // ignore: cast_nullable_to_non_nullable
              as int,
      nextTierThreshold: null == nextTierThreshold
          ? _value.nextTierThreshold
          : nextTierThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      tierBenefits: freezed == tierBenefits
          ? _value.tierBenefits
          : tierBenefits // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
abstract class _$$UserTierInfoImplCopyWith<$Res>
    implements $UserTierInfoCopyWith<$Res> {
  factory _$$UserTierInfoImplCopyWith(
          _$UserTierInfoImpl value, $Res Function(_$UserTierInfoImpl) then) =
      __$$UserTierInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'current_tier') UserTier currentTier,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'tier_progress') int tierProgress,
      @JsonKey(name: 'next_tier_threshold') int nextTierThreshold,
      @JsonKey(name: 'tier_benefits') List<String>? tierBenefits,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$UserTierInfoImplCopyWithImpl<$Res>
    extends _$UserTierInfoCopyWithImpl<$Res, _$UserTierInfoImpl>
    implements _$$UserTierInfoImplCopyWith<$Res> {
  __$$UserTierInfoImplCopyWithImpl(
      _$UserTierInfoImpl _value, $Res Function(_$UserTierInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentTier = null,
    Object? totalPoints = null,
    Object? tierProgress = null,
    Object? nextTierThreshold = null,
    Object? tierBenefits = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserTierInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentTier: null == currentTier
          ? _value.currentTier
          : currentTier // ignore: cast_nullable_to_non_nullable
              as UserTier,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      tierProgress: null == tierProgress
          ? _value.tierProgress
          : tierProgress // ignore: cast_nullable_to_non_nullable
              as int,
      nextTierThreshold: null == nextTierThreshold
          ? _value.nextTierThreshold
          : nextTierThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      tierBenefits: freezed == tierBenefits
          ? _value._tierBenefits
          : tierBenefits // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
class _$UserTierInfoImpl with DiagnosticableTreeMixin implements _UserTierInfo {
  const _$UserTierInfoImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'current_tier') required this.currentTier,
      @JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'tier_progress') this.tierProgress = 0,
      @JsonKey(name: 'next_tier_threshold') required this.nextTierThreshold,
      @JsonKey(name: 'tier_benefits') final List<String>? tierBenefits,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _tierBenefits = tierBenefits;

  factory _$UserTierInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserTierInfoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'current_tier')
  final UserTier currentTier;
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @override
  @JsonKey(name: 'tier_progress')
  final int tierProgress;
  @override
  @JsonKey(name: 'next_tier_threshold')
  final int nextTierThreshold;
  final List<String>? _tierBenefits;
  @override
  @JsonKey(name: 'tier_benefits')
  List<String>? get tierBenefits {
    final value = _tierBenefits;
    if (value == null) return null;
    if (_tierBenefits is EqualUnmodifiableListView) return _tierBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserTierInfo(id: $id, userId: $userId, currentTier: $currentTier, totalPoints: $totalPoints, tierProgress: $tierProgress, nextTierThreshold: $nextTierThreshold, tierBenefits: $tierBenefits, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserTierInfo'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('currentTier', currentTier))
      ..add(DiagnosticsProperty('totalPoints', totalPoints))
      ..add(DiagnosticsProperty('tierProgress', tierProgress))
      ..add(DiagnosticsProperty('nextTierThreshold', nextTierThreshold))
      ..add(DiagnosticsProperty('tierBenefits', tierBenefits))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserTierInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentTier, currentTier) ||
                other.currentTier == currentTier) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.tierProgress, tierProgress) ||
                other.tierProgress == tierProgress) &&
            (identical(other.nextTierThreshold, nextTierThreshold) ||
                other.nextTierThreshold == nextTierThreshold) &&
            const DeepCollectionEquality()
                .equals(other._tierBenefits, _tierBenefits) &&
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
      userId,
      currentTier,
      totalPoints,
      tierProgress,
      nextTierThreshold,
      const DeepCollectionEquality().hash(_tierBenefits),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserTierInfoImplCopyWith<_$UserTierInfoImpl> get copyWith =>
      __$$UserTierInfoImplCopyWithImpl<_$UserTierInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserTierInfoImplToJson(
      this,
    );
  }
}

abstract class _UserTierInfo implements UserTierInfo {
  const factory _UserTierInfo(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'current_tier') required final UserTier currentTier,
          @JsonKey(name: 'total_points') final int totalPoints,
          @JsonKey(name: 'tier_progress') final int tierProgress,
          @JsonKey(name: 'next_tier_threshold')
          required final int nextTierThreshold,
          @JsonKey(name: 'tier_benefits') final List<String>? tierBenefits,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$UserTierInfoImpl;

  factory _UserTierInfo.fromJson(Map<String, dynamic> json) =
      _$UserTierInfoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'current_tier')
  UserTier get currentTier;
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;
  @override
  @JsonKey(name: 'tier_progress')
  int get tierProgress;
  @override
  @JsonKey(name: 'next_tier_threshold')
  int get nextTierThreshold;
  @override
  @JsonKey(name: 'tier_benefits')
  List<String>? get tierBenefits;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserTierInfoImplCopyWith<_$UserTierInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) {
  return _SubscriptionPlan.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int get durationDays => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_type')
  SubscriptionPlanType get planType => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_points_bonus')
  int get tierPointsBonus => throw _privateConstructorUsedError;
  Map<String, dynamic>? get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_popular')
  bool get isPopular => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_percentage')
  double? get discountPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_price')
  double? get originalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPlanCopyWith<$Res> {
  factory $SubscriptionPlanCopyWith(
          SubscriptionPlan value, $Res Function(SubscriptionPlan) then) =
      _$SubscriptionPlanCopyWithImpl<$Res, SubscriptionPlan>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'duration_days') int durationDays,
      double price,
      String currency,
      @JsonKey(name: 'plan_type') SubscriptionPlanType planType,
      @JsonKey(name: 'tier_points_bonus') int tierPointsBonus,
      Map<String, dynamic>? features,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'discount_percentage') double? discountPercentage,
      @JsonKey(name: 'original_price') double? originalPrice,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res, $Val extends SubscriptionPlan>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._value, this._then);

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
    Object? durationDays = null,
    Object? price = null,
    Object? currency = null,
    Object? planType = null,
    Object? tierPointsBonus = null,
    Object? features = freezed,
    Object? isActive = null,
    Object? isPopular = null,
    Object? discountPercentage = freezed,
    Object? originalPrice = freezed,
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
      durationDays: null == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanType,
      tierPointsBonus: null == tierPointsBonus
          ? _value.tierPointsBonus
          : tierPointsBonus // ignore: cast_nullable_to_non_nullable
              as int,
      features: freezed == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
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
abstract class _$$SubscriptionPlanImplCopyWith<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  factory _$$SubscriptionPlanImplCopyWith(_$SubscriptionPlanImpl value,
          $Res Function(_$SubscriptionPlanImpl) then) =
      __$$SubscriptionPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'duration_days') int durationDays,
      double price,
      String currency,
      @JsonKey(name: 'plan_type') SubscriptionPlanType planType,
      @JsonKey(name: 'tier_points_bonus') int tierPointsBonus,
      Map<String, dynamic>? features,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'discount_percentage') double? discountPercentage,
      @JsonKey(name: 'original_price') double? originalPrice,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$SubscriptionPlanImplCopyWithImpl<$Res>
    extends _$SubscriptionPlanCopyWithImpl<$Res, _$SubscriptionPlanImpl>
    implements _$$SubscriptionPlanImplCopyWith<$Res> {
  __$$SubscriptionPlanImplCopyWithImpl(_$SubscriptionPlanImpl _value,
      $Res Function(_$SubscriptionPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? durationDays = null,
    Object? price = null,
    Object? currency = null,
    Object? planType = null,
    Object? tierPointsBonus = null,
    Object? features = freezed,
    Object? isActive = null,
    Object? isPopular = null,
    Object? discountPercentage = freezed,
    Object? originalPrice = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SubscriptionPlanImpl(
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
      durationDays: null == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanType,
      tierPointsBonus: null == tierPointsBonus
          ? _value.tierPointsBonus
          : tierPointsBonus // ignore: cast_nullable_to_non_nullable
              as int,
      features: freezed == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
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
class _$SubscriptionPlanImpl
    with DiagnosticableTreeMixin
    implements _SubscriptionPlan {
  const _$SubscriptionPlanImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'duration_days') required this.durationDays,
      required this.price,
      this.currency = 'GHS',
      @JsonKey(name: 'plan_type') required this.planType,
      @JsonKey(name: 'tier_points_bonus') this.tierPointsBonus = 0,
      final Map<String, dynamic>? features,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'is_popular') this.isPopular = false,
      @JsonKey(name: 'discount_percentage') this.discountPercentage,
      @JsonKey(name: 'original_price') this.originalPrice,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _features = features;

  factory _$SubscriptionPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'duration_days')
  final int durationDays;
  @override
  final double price;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey(name: 'plan_type')
  final SubscriptionPlanType planType;
  @override
  @JsonKey(name: 'tier_points_bonus')
  final int tierPointsBonus;
  final Map<String, dynamic>? _features;
  @override
  Map<String, dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableMapView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @override
  @JsonKey(name: 'discount_percentage')
  final double? discountPercentage;
  @override
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SubscriptionPlan(id: $id, name: $name, description: $description, durationDays: $durationDays, price: $price, currency: $currency, planType: $planType, tierPointsBonus: $tierPointsBonus, features: $features, isActive: $isActive, isPopular: $isPopular, discountPercentage: $discountPercentage, originalPrice: $originalPrice, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SubscriptionPlan'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('durationDays', durationDays))
      ..add(DiagnosticsProperty('price', price))
      ..add(DiagnosticsProperty('currency', currency))
      ..add(DiagnosticsProperty('planType', planType))
      ..add(DiagnosticsProperty('tierPointsBonus', tierPointsBonus))
      ..add(DiagnosticsProperty('features', features))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('isPopular', isPopular))
      ..add(DiagnosticsProperty('discountPercentage', discountPercentage))
      ..add(DiagnosticsProperty('originalPrice', originalPrice))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.tierPointsBonus, tierPointsBonus) ||
                other.tierPointsBonus == tierPointsBonus) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
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
      durationDays,
      price,
      currency,
      planType,
      tierPointsBonus,
      const DeepCollectionEquality().hash(_features),
      isActive,
      isPopular,
      discountPercentage,
      originalPrice,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      __$$SubscriptionPlanImplCopyWithImpl<_$SubscriptionPlanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionPlanImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionPlan implements SubscriptionPlan {
  const factory _SubscriptionPlan(
      {required final String id,
      required final String name,
      final String? description,
      @JsonKey(name: 'duration_days') required final int durationDays,
      required final double price,
      final String currency,
      @JsonKey(name: 'plan_type') required final SubscriptionPlanType planType,
      @JsonKey(name: 'tier_points_bonus') final int tierPointsBonus,
      final Map<String, dynamic>? features,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'is_popular') final bool isPopular,
      @JsonKey(name: 'discount_percentage') final double? discountPercentage,
      @JsonKey(name: 'original_price') final double? originalPrice,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$SubscriptionPlanImpl;

  factory _SubscriptionPlan.fromJson(Map<String, dynamic> json) =
      _$SubscriptionPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'duration_days')
  int get durationDays;
  @override
  double get price;
  @override
  String get currency;
  @override
  @JsonKey(name: 'plan_type')
  SubscriptionPlanType get planType;
  @override
  @JsonKey(name: 'tier_points_bonus')
  int get tierPointsBonus;
  @override
  Map<String, dynamic>? get features;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'is_popular')
  bool get isPopular;
  @override
  @JsonKey(name: 'discount_percentage')
  double? get discountPercentage;
  @override
  @JsonKey(name: 'original_price')
  double? get originalPrice;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) {
  return _UserSubscription.fromJson(json);
}

/// @nodoc
mixin _$UserSubscription {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_type')
  String get subscriptionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_type')
  SubscriptionPlanType get planType => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_reference')
  String? get paymentReference => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_auto_renew')
  bool get isAutoRenew => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_points_earned')
  int get tierPointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'features_unlocked')
  List<String>? get featuresUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserSubscriptionCopyWith<UserSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSubscriptionCopyWith<$Res> {
  factory $UserSubscriptionCopyWith(
          UserSubscription value, $Res Function(UserSubscription) then) =
      _$UserSubscriptionCopyWithImpl<$Res, UserSubscription>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'subscription_type') String subscriptionType,
      @JsonKey(name: 'plan_type') SubscriptionPlanType planType,
      double amount,
      String currency,
      String status,
      @JsonKey(name: 'payment_reference') String? paymentReference,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      @JsonKey(name: 'is_auto_renew') bool isAutoRenew,
      @JsonKey(name: 'tier_points_earned') int tierPointsEarned,
      @JsonKey(name: 'features_unlocked') List<String>? featuresUnlocked,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$UserSubscriptionCopyWithImpl<$Res, $Val extends UserSubscription>
    implements $UserSubscriptionCopyWith<$Res> {
  _$UserSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionType = null,
    Object? planType = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? paymentReference = freezed,
    Object? paymentMethod = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isAutoRenew = null,
    Object? tierPointsEarned = null,
    Object? featuresUnlocked = freezed,
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
      subscriptionType: null == subscriptionType
          ? _value.subscriptionType
          : subscriptionType // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAutoRenew: null == isAutoRenew
          ? _value.isAutoRenew
          : isAutoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      tierPointsEarned: null == tierPointsEarned
          ? _value.tierPointsEarned
          : tierPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      featuresUnlocked: freezed == featuresUnlocked
          ? _value.featuresUnlocked
          : featuresUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
abstract class _$$UserSubscriptionImplCopyWith<$Res>
    implements $UserSubscriptionCopyWith<$Res> {
  factory _$$UserSubscriptionImplCopyWith(_$UserSubscriptionImpl value,
          $Res Function(_$UserSubscriptionImpl) then) =
      __$$UserSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'subscription_type') String subscriptionType,
      @JsonKey(name: 'plan_type') SubscriptionPlanType planType,
      double amount,
      String currency,
      String status,
      @JsonKey(name: 'payment_reference') String? paymentReference,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      @JsonKey(name: 'is_auto_renew') bool isAutoRenew,
      @JsonKey(name: 'tier_points_earned') int tierPointsEarned,
      @JsonKey(name: 'features_unlocked') List<String>? featuresUnlocked,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$UserSubscriptionImplCopyWithImpl<$Res>
    extends _$UserSubscriptionCopyWithImpl<$Res, _$UserSubscriptionImpl>
    implements _$$UserSubscriptionImplCopyWith<$Res> {
  __$$UserSubscriptionImplCopyWithImpl(_$UserSubscriptionImpl _value,
      $Res Function(_$UserSubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionType = null,
    Object? planType = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? paymentReference = freezed,
    Object? paymentMethod = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isAutoRenew = null,
    Object? tierPointsEarned = null,
    Object? featuresUnlocked = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserSubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionType: null == subscriptionType
          ? _value.subscriptionType
          : subscriptionType // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as SubscriptionPlanType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: freezed == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAutoRenew: null == isAutoRenew
          ? _value.isAutoRenew
          : isAutoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      tierPointsEarned: null == tierPointsEarned
          ? _value.tierPointsEarned
          : tierPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      featuresUnlocked: freezed == featuresUnlocked
          ? _value._featuresUnlocked
          : featuresUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
class _$UserSubscriptionImpl
    with DiagnosticableTreeMixin
    implements _UserSubscription {
  const _$UserSubscriptionImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'subscription_type') required this.subscriptionType,
      @JsonKey(name: 'plan_type') required this.planType,
      required this.amount,
      required this.currency,
      required this.status,
      @JsonKey(name: 'payment_reference') this.paymentReference,
      @JsonKey(name: 'payment_method') required this.paymentMethod,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'is_auto_renew') required this.isAutoRenew,
      @JsonKey(name: 'tier_points_earned') this.tierPointsEarned = 0,
      @JsonKey(name: 'features_unlocked') final List<String>? featuresUnlocked,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _featuresUnlocked = featuresUnlocked;

  factory _$UserSubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'subscription_type')
  final String subscriptionType;
  @override
  @JsonKey(name: 'plan_type')
  final SubscriptionPlanType planType;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final String status;
  @override
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @override
  @JsonKey(name: 'is_auto_renew')
  final bool isAutoRenew;
  @override
  @JsonKey(name: 'tier_points_earned')
  final int tierPointsEarned;
  final List<String>? _featuresUnlocked;
  @override
  @JsonKey(name: 'features_unlocked')
  List<String>? get featuresUnlocked {
    final value = _featuresUnlocked;
    if (value == null) return null;
    if (_featuresUnlocked is EqualUnmodifiableListView)
      return _featuresUnlocked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserSubscription(id: $id, userId: $userId, subscriptionType: $subscriptionType, planType: $planType, amount: $amount, currency: $currency, status: $status, paymentReference: $paymentReference, paymentMethod: $paymentMethod, startDate: $startDate, endDate: $endDate, isAutoRenew: $isAutoRenew, tierPointsEarned: $tierPointsEarned, featuresUnlocked: $featuresUnlocked, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserSubscription'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('subscriptionType', subscriptionType))
      ..add(DiagnosticsProperty('planType', planType))
      ..add(DiagnosticsProperty('amount', amount))
      ..add(DiagnosticsProperty('currency', currency))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('paymentReference', paymentReference))
      ..add(DiagnosticsProperty('paymentMethod', paymentMethod))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('isAutoRenew', isAutoRenew))
      ..add(DiagnosticsProperty('tierPointsEarned', tierPointsEarned))
      ..add(DiagnosticsProperty('featuresUnlocked', featuresUnlocked))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subscriptionType, subscriptionType) ||
                other.subscriptionType == subscriptionType) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentReference, paymentReference) ||
                other.paymentReference == paymentReference) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isAutoRenew, isAutoRenew) ||
                other.isAutoRenew == isAutoRenew) &&
            (identical(other.tierPointsEarned, tierPointsEarned) ||
                other.tierPointsEarned == tierPointsEarned) &&
            const DeepCollectionEquality()
                .equals(other._featuresUnlocked, _featuresUnlocked) &&
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
      userId,
      subscriptionType,
      planType,
      amount,
      currency,
      status,
      paymentReference,
      paymentMethod,
      startDate,
      endDate,
      isAutoRenew,
      tierPointsEarned,
      const DeepCollectionEquality().hash(_featuresUnlocked),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSubscriptionImplCopyWith<_$UserSubscriptionImpl> get copyWith =>
      __$$UserSubscriptionImplCopyWithImpl<_$UserSubscriptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSubscriptionImplToJson(
      this,
    );
  }
}

abstract class _UserSubscription implements UserSubscription {
  const factory _UserSubscription(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'subscription_type')
      required final String subscriptionType,
      @JsonKey(name: 'plan_type') required final SubscriptionPlanType planType,
      required final double amount,
      required final String currency,
      required final String status,
      @JsonKey(name: 'payment_reference') final String? paymentReference,
      @JsonKey(name: 'payment_method') required final String paymentMethod,
      @JsonKey(name: 'start_date') required final DateTime startDate,
      @JsonKey(name: 'end_date') required final DateTime endDate,
      @JsonKey(name: 'is_auto_renew') required final bool isAutoRenew,
      @JsonKey(name: 'tier_points_earned') final int tierPointsEarned,
      @JsonKey(name: 'features_unlocked') final List<String>? featuresUnlocked,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$UserSubscriptionImpl;

  factory _UserSubscription.fromJson(Map<String, dynamic> json) =
      _$UserSubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'subscription_type')
  String get subscriptionType;
  @override
  @JsonKey(name: 'plan_type')
  SubscriptionPlanType get planType;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get status;
  @override
  @JsonKey(name: 'payment_reference')
  String? get paymentReference;
  @override
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  @JsonKey(name: 'is_auto_renew')
  bool get isAutoRenew;
  @override
  @JsonKey(name: 'tier_points_earned')
  int get tierPointsEarned;
  @override
  @JsonKey(name: 'features_unlocked')
  List<String>? get featuresUnlocked;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserSubscriptionImplCopyWith<_$UserSubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionPayment _$SubscriptionPaymentFromJson(Map<String, dynamic> json) {
  return _SubscriptionPayment.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionPayment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_id')
  String get subscriptionId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_reference')
  String get paymentReference => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_date')
  DateTime get paymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_points_awarded')
  int get tierPointsAwarded => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionPaymentCopyWith<SubscriptionPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPaymentCopyWith<$Res> {
  factory $SubscriptionPaymentCopyWith(
          SubscriptionPayment value, $Res Function(SubscriptionPayment) then) =
      _$SubscriptionPaymentCopyWithImpl<$Res, SubscriptionPayment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'subscription_id') String subscriptionId,
      double amount,
      String currency,
      @JsonKey(name: 'payment_reference') String paymentReference,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'payment_date') DateTime paymentDate,
      @JsonKey(name: 'tier_points_awarded') int tierPointsAwarded,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$SubscriptionPaymentCopyWithImpl<$Res, $Val extends SubscriptionPayment>
    implements $SubscriptionPaymentCopyWith<$Res> {
  _$SubscriptionPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentReference = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? paymentDate = null,
    Object? tierPointsAwarded = null,
    Object? metadata = freezed,
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
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: null == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tierPointsAwarded: null == tierPointsAwarded
          ? _value.tierPointsAwarded
          : tierPointsAwarded // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionPaymentImplCopyWith<$Res>
    implements $SubscriptionPaymentCopyWith<$Res> {
  factory _$$SubscriptionPaymentImplCopyWith(_$SubscriptionPaymentImpl value,
          $Res Function(_$SubscriptionPaymentImpl) then) =
      __$$SubscriptionPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'subscription_id') String subscriptionId,
      double amount,
      String currency,
      @JsonKey(name: 'payment_reference') String paymentReference,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_status') String paymentStatus,
      @JsonKey(name: 'payment_date') DateTime paymentDate,
      @JsonKey(name: 'tier_points_awarded') int tierPointsAwarded,
      Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$SubscriptionPaymentImplCopyWithImpl<$Res>
    extends _$SubscriptionPaymentCopyWithImpl<$Res, _$SubscriptionPaymentImpl>
    implements _$$SubscriptionPaymentImplCopyWith<$Res> {
  __$$SubscriptionPaymentImplCopyWithImpl(_$SubscriptionPaymentImpl _value,
      $Res Function(_$SubscriptionPaymentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentReference = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? paymentDate = null,
    Object? tierPointsAwarded = null,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$SubscriptionPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      paymentReference: null == paymentReference
          ? _value.paymentReference
          : paymentReference // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tierPointsAwarded: null == tierPointsAwarded
          ? _value.tierPointsAwarded
          : tierPointsAwarded // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionPaymentImpl
    with DiagnosticableTreeMixin
    implements _SubscriptionPayment {
  const _$SubscriptionPaymentImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'subscription_id') required this.subscriptionId,
      required this.amount,
      required this.currency,
      @JsonKey(name: 'payment_reference') required this.paymentReference,
      @JsonKey(name: 'payment_method') required this.paymentMethod,
      @JsonKey(name: 'payment_status') required this.paymentStatus,
      @JsonKey(name: 'payment_date') required this.paymentDate,
      @JsonKey(name: 'tier_points_awarded') this.tierPointsAwarded = 0,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _metadata = metadata;

  factory _$SubscriptionPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionPaymentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'subscription_id')
  final String subscriptionId;
  @override
  final double amount;
  @override
  final String currency;
  @override
  @JsonKey(name: 'payment_reference')
  final String paymentReference;
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @override
  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;
  @override
  @JsonKey(name: 'tier_points_awarded')
  final int tierPointsAwarded;
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
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SubscriptionPayment(id: $id, userId: $userId, subscriptionId: $subscriptionId, amount: $amount, currency: $currency, paymentReference: $paymentReference, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentDate: $paymentDate, tierPointsAwarded: $tierPointsAwarded, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SubscriptionPayment'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('subscriptionId', subscriptionId))
      ..add(DiagnosticsProperty('amount', amount))
      ..add(DiagnosticsProperty('currency', currency))
      ..add(DiagnosticsProperty('paymentReference', paymentReference))
      ..add(DiagnosticsProperty('paymentMethod', paymentMethod))
      ..add(DiagnosticsProperty('paymentStatus', paymentStatus))
      ..add(DiagnosticsProperty('paymentDate', paymentDate))
      ..add(DiagnosticsProperty('tierPointsAwarded', tierPointsAwarded))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.paymentReference, paymentReference) ||
                other.paymentReference == paymentReference) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.tierPointsAwarded, tierPointsAwarded) ||
                other.tierPointsAwarded == tierPointsAwarded) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      subscriptionId,
      amount,
      currency,
      paymentReference,
      paymentMethod,
      paymentStatus,
      paymentDate,
      tierPointsAwarded,
      const DeepCollectionEquality().hash(_metadata),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPaymentImplCopyWith<_$SubscriptionPaymentImpl> get copyWith =>
      __$$SubscriptionPaymentImplCopyWithImpl<_$SubscriptionPaymentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionPaymentImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionPayment implements SubscriptionPayment {
  const factory _SubscriptionPayment(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'subscription_id') required final String subscriptionId,
      required final double amount,
      required final String currency,
      @JsonKey(name: 'payment_reference')
      required final String paymentReference,
      @JsonKey(name: 'payment_method') required final String paymentMethod,
      @JsonKey(name: 'payment_status') required final String paymentStatus,
      @JsonKey(name: 'payment_date') required final DateTime paymentDate,
      @JsonKey(name: 'tier_points_awarded') final int tierPointsAwarded,
      final Map<String, dynamic>? metadata,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$SubscriptionPaymentImpl;

  factory _SubscriptionPayment.fromJson(Map<String, dynamic> json) =
      _$SubscriptionPaymentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'subscription_id')
  String get subscriptionId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  @JsonKey(name: 'payment_reference')
  String get paymentReference;
  @override
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override
  @JsonKey(name: 'payment_date')
  DateTime get paymentDate;
  @override
  @JsonKey(name: 'tier_points_awarded')
  int get tierPointsAwarded;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionPaymentImplCopyWith<_$SubscriptionPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaystackVerification _$PaystackVerificationFromJson(Map<String, dynamic> json) {
  return _PaystackVerification.fromJson(json);
}

/// @nodoc
mixin _$PaystackVerification {
  bool get status => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaystackVerificationCopyWith<PaystackVerification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaystackVerificationCopyWith<$Res> {
  factory $PaystackVerificationCopyWith(PaystackVerification value,
          $Res Function(PaystackVerification) then) =
      _$PaystackVerificationCopyWithImpl<$Res, PaystackVerification>;
  @useResult
  $Res call({bool status, String message, Map<String, dynamic>? data});
}

/// @nodoc
class _$PaystackVerificationCopyWithImpl<$Res,
        $Val extends PaystackVerification>
    implements $PaystackVerificationCopyWith<$Res> {
  _$PaystackVerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaystackVerificationImplCopyWith<$Res>
    implements $PaystackVerificationCopyWith<$Res> {
  factory _$$PaystackVerificationImplCopyWith(_$PaystackVerificationImpl value,
          $Res Function(_$PaystackVerificationImpl) then) =
      __$$PaystackVerificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool status, String message, Map<String, dynamic>? data});
}

/// @nodoc
class __$$PaystackVerificationImplCopyWithImpl<$Res>
    extends _$PaystackVerificationCopyWithImpl<$Res, _$PaystackVerificationImpl>
    implements _$$PaystackVerificationImplCopyWith<$Res> {
  __$$PaystackVerificationImplCopyWithImpl(_$PaystackVerificationImpl _value,
      $Res Function(_$PaystackVerificationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_$PaystackVerificationImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaystackVerificationImpl
    with DiagnosticableTreeMixin
    implements _PaystackVerification {
  const _$PaystackVerificationImpl(
      {required this.status,
      required this.message,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$PaystackVerificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaystackVerificationImplFromJson(json);

  @override
  final bool status;
  @override
  final String message;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaystackVerification(status: $status, message: $message, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PaystackVerification'))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaystackVerificationImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, status, message, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaystackVerificationImplCopyWith<_$PaystackVerificationImpl>
      get copyWith =>
          __$$PaystackVerificationImplCopyWithImpl<_$PaystackVerificationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaystackVerificationImplToJson(
      this,
    );
  }
}

abstract class _PaystackVerification implements PaystackVerification {
  const factory _PaystackVerification(
      {required final bool status,
      required final String message,
      final Map<String, dynamic>? data}) = _$PaystackVerificationImpl;

  factory _PaystackVerification.fromJson(Map<String, dynamic> json) =
      _$PaystackVerificationImpl.fromJson;

  @override
  bool get status;
  @override
  String get message;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$PaystackVerificationImplCopyWith<_$PaystackVerificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
