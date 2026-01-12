// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_gift_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PostGift _$PostGiftFromJson(Map<String, dynamic> json) {
  return _PostGift.fromJson(json);
}

/// @nodoc
mixin _$PostGift {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'feed_id')
  String get feedId => throw _privateConstructorUsedError;
  @JsonKey(name: 'gifter_user_id')
  String get gifterUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_user_id')
  String get receiverUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_amount')
  int get pointsAmount => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'gift_type')
  String get giftType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Additional fields from joins (not in DB)
  @JsonKey(name: 'gifter_name')
  String? get gifterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'gifter_avatar')
  String? get gifterAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_name')
  String? get receiverName => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_avatar')
  String? get receiverAvatar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostGiftCopyWith<PostGift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostGiftCopyWith<$Res> {
  factory $PostGiftCopyWith(PostGift value, $Res Function(PostGift) then) =
      _$PostGiftCopyWithImpl<$Res, PostGift>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'gifter_user_id') String gifterUserId,
      @JsonKey(name: 'receiver_user_id') String receiverUserId,
      @JsonKey(name: 'points_amount') int pointsAmount,
      String? message,
      @JsonKey(name: 'gift_type') String giftType,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'gifter_name') String? gifterName,
      @JsonKey(name: 'gifter_avatar') String? gifterAvatar,
      @JsonKey(name: 'receiver_name') String? receiverName,
      @JsonKey(name: 'receiver_avatar') String? receiverAvatar});
}

/// @nodoc
class _$PostGiftCopyWithImpl<$Res, $Val extends PostGift>
    implements $PostGiftCopyWith<$Res> {
  _$PostGiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? gifterUserId = null,
    Object? receiverUserId = null,
    Object? pointsAmount = null,
    Object? message = freezed,
    Object? giftType = null,
    Object? status = null,
    Object? createdAt = null,
    Object? gifterName = freezed,
    Object? gifterAvatar = freezed,
    Object? receiverName = freezed,
    Object? receiverAvatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      gifterUserId: null == gifterUserId
          ? _value.gifterUserId
          : gifterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverUserId: null == receiverUserId
          ? _value.receiverUserId
          : receiverUserId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsAmount: null == pointsAmount
          ? _value.pointsAmount
          : pointsAmount // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      giftType: null == giftType
          ? _value.giftType
          : giftType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gifterName: freezed == gifterName
          ? _value.gifterName
          : gifterName // ignore: cast_nullable_to_non_nullable
              as String?,
      gifterAvatar: freezed == gifterAvatar
          ? _value.gifterAvatar
          : gifterAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      receiverName: freezed == receiverName
          ? _value.receiverName
          : receiverName // ignore: cast_nullable_to_non_nullable
              as String?,
      receiverAvatar: freezed == receiverAvatar
          ? _value.receiverAvatar
          : receiverAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostGiftImplCopyWith<$Res>
    implements $PostGiftCopyWith<$Res> {
  factory _$$PostGiftImplCopyWith(
          _$PostGiftImpl value, $Res Function(_$PostGiftImpl) then) =
      __$$PostGiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'gifter_user_id') String gifterUserId,
      @JsonKey(name: 'receiver_user_id') String receiverUserId,
      @JsonKey(name: 'points_amount') int pointsAmount,
      String? message,
      @JsonKey(name: 'gift_type') String giftType,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'gifter_name') String? gifterName,
      @JsonKey(name: 'gifter_avatar') String? gifterAvatar,
      @JsonKey(name: 'receiver_name') String? receiverName,
      @JsonKey(name: 'receiver_avatar') String? receiverAvatar});
}

/// @nodoc
class __$$PostGiftImplCopyWithImpl<$Res>
    extends _$PostGiftCopyWithImpl<$Res, _$PostGiftImpl>
    implements _$$PostGiftImplCopyWith<$Res> {
  __$$PostGiftImplCopyWithImpl(
      _$PostGiftImpl _value, $Res Function(_$PostGiftImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? gifterUserId = null,
    Object? receiverUserId = null,
    Object? pointsAmount = null,
    Object? message = freezed,
    Object? giftType = null,
    Object? status = null,
    Object? createdAt = null,
    Object? gifterName = freezed,
    Object? gifterAvatar = freezed,
    Object? receiverName = freezed,
    Object? receiverAvatar = freezed,
  }) {
    return _then(_$PostGiftImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      gifterUserId: null == gifterUserId
          ? _value.gifterUserId
          : gifterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverUserId: null == receiverUserId
          ? _value.receiverUserId
          : receiverUserId // ignore: cast_nullable_to_non_nullable
              as String,
      pointsAmount: null == pointsAmount
          ? _value.pointsAmount
          : pointsAmount // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      giftType: null == giftType
          ? _value.giftType
          : giftType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gifterName: freezed == gifterName
          ? _value.gifterName
          : gifterName // ignore: cast_nullable_to_non_nullable
              as String?,
      gifterAvatar: freezed == gifterAvatar
          ? _value.gifterAvatar
          : gifterAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      receiverName: freezed == receiverName
          ? _value.receiverName
          : receiverName // ignore: cast_nullable_to_non_nullable
              as String?,
      receiverAvatar: freezed == receiverAvatar
          ? _value.receiverAvatar
          : receiverAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostGiftImpl extends _PostGift with DiagnosticableTreeMixin {
  const _$PostGiftImpl(
      {required this.id,
      @JsonKey(name: 'feed_id') required this.feedId,
      @JsonKey(name: 'gifter_user_id') required this.gifterUserId,
      @JsonKey(name: 'receiver_user_id') required this.receiverUserId,
      @JsonKey(name: 'points_amount') required this.pointsAmount,
      this.message,
      @JsonKey(name: 'gift_type') required this.giftType,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'gifter_name') this.gifterName,
      @JsonKey(name: 'gifter_avatar') this.gifterAvatar,
      @JsonKey(name: 'receiver_name') this.receiverName,
      @JsonKey(name: 'receiver_avatar') this.receiverAvatar})
      : super._();

  factory _$PostGiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostGiftImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'feed_id')
  final String feedId;
  @override
  @JsonKey(name: 'gifter_user_id')
  final String gifterUserId;
  @override
  @JsonKey(name: 'receiver_user_id')
  final String receiverUserId;
  @override
  @JsonKey(name: 'points_amount')
  final int pointsAmount;
  @override
  final String? message;
  @override
  @JsonKey(name: 'gift_type')
  final String giftType;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Additional fields from joins (not in DB)
  @override
  @JsonKey(name: 'gifter_name')
  final String? gifterName;
  @override
  @JsonKey(name: 'gifter_avatar')
  final String? gifterAvatar;
  @override
  @JsonKey(name: 'receiver_name')
  final String? receiverName;
  @override
  @JsonKey(name: 'receiver_avatar')
  final String? receiverAvatar;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostGift(id: $id, feedId: $feedId, gifterUserId: $gifterUserId, receiverUserId: $receiverUserId, pointsAmount: $pointsAmount, message: $message, giftType: $giftType, status: $status, createdAt: $createdAt, gifterName: $gifterName, gifterAvatar: $gifterAvatar, receiverName: $receiverName, receiverAvatar: $receiverAvatar)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PostGift'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('feedId', feedId))
      ..add(DiagnosticsProperty('gifterUserId', gifterUserId))
      ..add(DiagnosticsProperty('receiverUserId', receiverUserId))
      ..add(DiagnosticsProperty('pointsAmount', pointsAmount))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('giftType', giftType))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('gifterName', gifterName))
      ..add(DiagnosticsProperty('gifterAvatar', gifterAvatar))
      ..add(DiagnosticsProperty('receiverName', receiverName))
      ..add(DiagnosticsProperty('receiverAvatar', receiverAvatar));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostGiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.gifterUserId, gifterUserId) ||
                other.gifterUserId == gifterUserId) &&
            (identical(other.receiverUserId, receiverUserId) ||
                other.receiverUserId == receiverUserId) &&
            (identical(other.pointsAmount, pointsAmount) ||
                other.pointsAmount == pointsAmount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.giftType, giftType) ||
                other.giftType == giftType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.gifterName, gifterName) ||
                other.gifterName == gifterName) &&
            (identical(other.gifterAvatar, gifterAvatar) ||
                other.gifterAvatar == gifterAvatar) &&
            (identical(other.receiverName, receiverName) ||
                other.receiverName == receiverName) &&
            (identical(other.receiverAvatar, receiverAvatar) ||
                other.receiverAvatar == receiverAvatar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      feedId,
      gifterUserId,
      receiverUserId,
      pointsAmount,
      message,
      giftType,
      status,
      createdAt,
      gifterName,
      gifterAvatar,
      receiverName,
      receiverAvatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostGiftImplCopyWith<_$PostGiftImpl> get copyWith =>
      __$$PostGiftImplCopyWithImpl<_$PostGiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostGiftImplToJson(
      this,
    );
  }
}

abstract class _PostGift extends PostGift {
  const factory _PostGift(
      {required final String id,
      @JsonKey(name: 'feed_id') required final String feedId,
      @JsonKey(name: 'gifter_user_id') required final String gifterUserId,
      @JsonKey(name: 'receiver_user_id') required final String receiverUserId,
      @JsonKey(name: 'points_amount') required final int pointsAmount,
      final String? message,
      @JsonKey(name: 'gift_type') required final String giftType,
      required final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'gifter_name') final String? gifterName,
      @JsonKey(name: 'gifter_avatar') final String? gifterAvatar,
      @JsonKey(name: 'receiver_name') final String? receiverName,
      @JsonKey(name: 'receiver_avatar')
      final String? receiverAvatar}) = _$PostGiftImpl;
  const _PostGift._() : super._();

  factory _PostGift.fromJson(Map<String, dynamic> json) =
      _$PostGiftImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'feed_id')
  String get feedId;
  @override
  @JsonKey(name: 'gifter_user_id')
  String get gifterUserId;
  @override
  @JsonKey(name: 'receiver_user_id')
  String get receiverUserId;
  @override
  @JsonKey(name: 'points_amount')
  int get pointsAmount;
  @override
  String? get message;
  @override
  @JsonKey(name: 'gift_type')
  String get giftType;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override // Additional fields from joins (not in DB)
  @JsonKey(name: 'gifter_name')
  String? get gifterName;
  @override
  @JsonKey(name: 'gifter_avatar')
  String? get gifterAvatar;
  @override
  @JsonKey(name: 'receiver_name')
  String? get receiverName;
  @override
  @JsonKey(name: 'receiver_avatar')
  String? get receiverAvatar;
  @override
  @JsonKey(ignore: true)
  _$$PostGiftImplCopyWith<_$PostGiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GiftPreset _$GiftPresetFromJson(Map<String, dynamic> json) {
  return _GiftPreset.fromJson(json);
}

/// @nodoc
mixin _$GiftPreset {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_amount')
  int get pointsAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GiftPresetCopyWith<GiftPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GiftPresetCopyWith<$Res> {
  factory $GiftPresetCopyWith(
          GiftPreset value, $Res Function(GiftPreset) then) =
      _$GiftPresetCopyWithImpl<$Res, GiftPreset>;
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      @JsonKey(name: 'points_amount') int pointsAmount,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$GiftPresetCopyWithImpl<$Res, $Val extends GiftPreset>
    implements $GiftPresetCopyWith<$Res> {
  _$GiftPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = null,
    Object? pointsAmount = null,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
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
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      pointsAmount: null == pointsAmount
          ? _value.pointsAmount
          : pointsAmount // ignore: cast_nullable_to_non_nullable
              as int,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GiftPresetImplCopyWith<$Res>
    implements $GiftPresetCopyWith<$Res> {
  factory _$$GiftPresetImplCopyWith(
          _$GiftPresetImpl value, $Res Function(_$GiftPresetImpl) then) =
      __$$GiftPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      @JsonKey(name: 'points_amount') int pointsAmount,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$GiftPresetImplCopyWithImpl<$Res>
    extends _$GiftPresetCopyWithImpl<$Res, _$GiftPresetImpl>
    implements _$$GiftPresetImplCopyWith<$Res> {
  __$$GiftPresetImplCopyWithImpl(
      _$GiftPresetImpl _value, $Res Function(_$GiftPresetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = null,
    Object? pointsAmount = null,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(_$GiftPresetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      pointsAmount: null == pointsAmount
          ? _value.pointsAmount
          : pointsAmount // ignore: cast_nullable_to_non_nullable
              as int,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GiftPresetImpl extends _GiftPreset with DiagnosticableTreeMixin {
  const _$GiftPresetImpl(
      {required this.id,
      required this.name,
      required this.emoji,
      @JsonKey(name: 'points_amount') required this.pointsAmount,
      @JsonKey(name: 'display_order') this.displayOrder = 0,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') required this.createdAt})
      : super._();

  factory _$GiftPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$GiftPresetImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String emoji;
  @override
  @JsonKey(name: 'points_amount')
  final int pointsAmount;
  @override
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GiftPreset(id: $id, name: $name, emoji: $emoji, pointsAmount: $pointsAmount, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GiftPreset'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('emoji', emoji))
      ..add(DiagnosticsProperty('pointsAmount', pointsAmount))
      ..add(DiagnosticsProperty('displayOrder', displayOrder))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GiftPresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.pointsAmount, pointsAmount) ||
                other.pointsAmount == pointsAmount) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji, pointsAmount,
      displayOrder, isActive, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GiftPresetImplCopyWith<_$GiftPresetImpl> get copyWith =>
      __$$GiftPresetImplCopyWithImpl<_$GiftPresetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GiftPresetImplToJson(
      this,
    );
  }
}

abstract class _GiftPreset extends GiftPreset {
  const factory _GiftPreset(
          {required final String id,
          required final String name,
          required final String emoji,
          @JsonKey(name: 'points_amount') required final int pointsAmount,
          @JsonKey(name: 'display_order') final int displayOrder,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$GiftPresetImpl;
  const _GiftPreset._() : super._();

  factory _GiftPreset.fromJson(Map<String, dynamic> json) =
      _$GiftPresetImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get emoji;
  @override
  @JsonKey(name: 'points_amount')
  int get pointsAmount;
  @override
  @JsonKey(name: 'display_order')
  int get displayOrder;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$GiftPresetImplCopyWith<_$GiftPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostGiftSummary _$PostGiftSummaryFromJson(Map<String, dynamic> json) {
  return _PostGiftSummary.fromJson(json);
}

/// @nodoc
mixin _$PostGiftSummary {
  @JsonKey(name: 'total_gifts')
  int get totalGifts => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'unique_gifters')
  int get uniqueGifters => throw _privateConstructorUsedError;
  @JsonKey(name: 'gift_breakdown')
  List<GiftBreakdown> get giftBreakdown => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_has_gifted')
  bool get userHasGifted => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_gift_type')
  String? get userGiftType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostGiftSummaryCopyWith<PostGiftSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostGiftSummaryCopyWith<$Res> {
  factory $PostGiftSummaryCopyWith(
          PostGiftSummary value, $Res Function(PostGiftSummary) then) =
      _$PostGiftSummaryCopyWithImpl<$Res, PostGiftSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_gifts') int totalGifts,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'unique_gifters') int uniqueGifters,
      @JsonKey(name: 'gift_breakdown') List<GiftBreakdown> giftBreakdown,
      @JsonKey(name: 'user_has_gifted') bool userHasGifted,
      @JsonKey(name: 'user_gift_type') String? userGiftType});
}

/// @nodoc
class _$PostGiftSummaryCopyWithImpl<$Res, $Val extends PostGiftSummary>
    implements $PostGiftSummaryCopyWith<$Res> {
  _$PostGiftSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGifts = null,
    Object? totalPoints = null,
    Object? uniqueGifters = null,
    Object? giftBreakdown = null,
    Object? userHasGifted = null,
    Object? userGiftType = freezed,
  }) {
    return _then(_value.copyWith(
      totalGifts: null == totalGifts
          ? _value.totalGifts
          : totalGifts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueGifters: null == uniqueGifters
          ? _value.uniqueGifters
          : uniqueGifters // ignore: cast_nullable_to_non_nullable
              as int,
      giftBreakdown: null == giftBreakdown
          ? _value.giftBreakdown
          : giftBreakdown // ignore: cast_nullable_to_non_nullable
              as List<GiftBreakdown>,
      userHasGifted: null == userHasGifted
          ? _value.userHasGifted
          : userHasGifted // ignore: cast_nullable_to_non_nullable
              as bool,
      userGiftType: freezed == userGiftType
          ? _value.userGiftType
          : userGiftType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostGiftSummaryImplCopyWith<$Res>
    implements $PostGiftSummaryCopyWith<$Res> {
  factory _$$PostGiftSummaryImplCopyWith(_$PostGiftSummaryImpl value,
          $Res Function(_$PostGiftSummaryImpl) then) =
      __$$PostGiftSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_gifts') int totalGifts,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'unique_gifters') int uniqueGifters,
      @JsonKey(name: 'gift_breakdown') List<GiftBreakdown> giftBreakdown,
      @JsonKey(name: 'user_has_gifted') bool userHasGifted,
      @JsonKey(name: 'user_gift_type') String? userGiftType});
}

/// @nodoc
class __$$PostGiftSummaryImplCopyWithImpl<$Res>
    extends _$PostGiftSummaryCopyWithImpl<$Res, _$PostGiftSummaryImpl>
    implements _$$PostGiftSummaryImplCopyWith<$Res> {
  __$$PostGiftSummaryImplCopyWithImpl(
      _$PostGiftSummaryImpl _value, $Res Function(_$PostGiftSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGifts = null,
    Object? totalPoints = null,
    Object? uniqueGifters = null,
    Object? giftBreakdown = null,
    Object? userHasGifted = null,
    Object? userGiftType = freezed,
  }) {
    return _then(_$PostGiftSummaryImpl(
      totalGifts: null == totalGifts
          ? _value.totalGifts
          : totalGifts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueGifters: null == uniqueGifters
          ? _value.uniqueGifters
          : uniqueGifters // ignore: cast_nullable_to_non_nullable
              as int,
      giftBreakdown: null == giftBreakdown
          ? _value._giftBreakdown
          : giftBreakdown // ignore: cast_nullable_to_non_nullable
              as List<GiftBreakdown>,
      userHasGifted: null == userHasGifted
          ? _value.userHasGifted
          : userHasGifted // ignore: cast_nullable_to_non_nullable
              as bool,
      userGiftType: freezed == userGiftType
          ? _value.userGiftType
          : userGiftType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostGiftSummaryImpl extends _PostGiftSummary
    with DiagnosticableTreeMixin {
  const _$PostGiftSummaryImpl(
      {@JsonKey(name: 'total_gifts') this.totalGifts = 0,
      @JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'unique_gifters') this.uniqueGifters = 0,
      @JsonKey(name: 'gift_breakdown')
      final List<GiftBreakdown> giftBreakdown = const [],
      @JsonKey(name: 'user_has_gifted') this.userHasGifted = false,
      @JsonKey(name: 'user_gift_type') this.userGiftType})
      : _giftBreakdown = giftBreakdown,
        super._();

  factory _$PostGiftSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostGiftSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_gifts')
  final int totalGifts;
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @override
  @JsonKey(name: 'unique_gifters')
  final int uniqueGifters;
  final List<GiftBreakdown> _giftBreakdown;
  @override
  @JsonKey(name: 'gift_breakdown')
  List<GiftBreakdown> get giftBreakdown {
    if (_giftBreakdown is EqualUnmodifiableListView) return _giftBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_giftBreakdown);
  }

  @override
  @JsonKey(name: 'user_has_gifted')
  final bool userHasGifted;
  @override
  @JsonKey(name: 'user_gift_type')
  final String? userGiftType;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostGiftSummary(totalGifts: $totalGifts, totalPoints: $totalPoints, uniqueGifters: $uniqueGifters, giftBreakdown: $giftBreakdown, userHasGifted: $userHasGifted, userGiftType: $userGiftType)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PostGiftSummary'))
      ..add(DiagnosticsProperty('totalGifts', totalGifts))
      ..add(DiagnosticsProperty('totalPoints', totalPoints))
      ..add(DiagnosticsProperty('uniqueGifters', uniqueGifters))
      ..add(DiagnosticsProperty('giftBreakdown', giftBreakdown))
      ..add(DiagnosticsProperty('userHasGifted', userHasGifted))
      ..add(DiagnosticsProperty('userGiftType', userGiftType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostGiftSummaryImpl &&
            (identical(other.totalGifts, totalGifts) ||
                other.totalGifts == totalGifts) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.uniqueGifters, uniqueGifters) ||
                other.uniqueGifters == uniqueGifters) &&
            const DeepCollectionEquality()
                .equals(other._giftBreakdown, _giftBreakdown) &&
            (identical(other.userHasGifted, userHasGifted) ||
                other.userHasGifted == userHasGifted) &&
            (identical(other.userGiftType, userGiftType) ||
                other.userGiftType == userGiftType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalGifts,
      totalPoints,
      uniqueGifters,
      const DeepCollectionEquality().hash(_giftBreakdown),
      userHasGifted,
      userGiftType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostGiftSummaryImplCopyWith<_$PostGiftSummaryImpl> get copyWith =>
      __$$PostGiftSummaryImplCopyWithImpl<_$PostGiftSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostGiftSummaryImplToJson(
      this,
    );
  }
}

abstract class _PostGiftSummary extends PostGiftSummary {
  const factory _PostGiftSummary(
      {@JsonKey(name: 'total_gifts') final int totalGifts,
      @JsonKey(name: 'total_points') final int totalPoints,
      @JsonKey(name: 'unique_gifters') final int uniqueGifters,
      @JsonKey(name: 'gift_breakdown') final List<GiftBreakdown> giftBreakdown,
      @JsonKey(name: 'user_has_gifted') final bool userHasGifted,
      @JsonKey(name: 'user_gift_type')
      final String? userGiftType}) = _$PostGiftSummaryImpl;
  const _PostGiftSummary._() : super._();

  factory _PostGiftSummary.fromJson(Map<String, dynamic> json) =
      _$PostGiftSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_gifts')
  int get totalGifts;
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;
  @override
  @JsonKey(name: 'unique_gifters')
  int get uniqueGifters;
  @override
  @JsonKey(name: 'gift_breakdown')
  List<GiftBreakdown> get giftBreakdown;
  @override
  @JsonKey(name: 'user_has_gifted')
  bool get userHasGifted;
  @override
  @JsonKey(name: 'user_gift_type')
  String? get userGiftType;
  @override
  @JsonKey(ignore: true)
  _$$PostGiftSummaryImplCopyWith<_$PostGiftSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GiftBreakdown _$GiftBreakdownFromJson(Map<String, dynamic> json) {
  return _GiftBreakdown.fromJson(json);
}

/// @nodoc
mixin _$GiftBreakdown {
  @JsonKey(name: 'gift_type')
  String get giftType => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GiftBreakdownCopyWith<GiftBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GiftBreakdownCopyWith<$Res> {
  factory $GiftBreakdownCopyWith(
          GiftBreakdown value, $Res Function(GiftBreakdown) then) =
      _$GiftBreakdownCopyWithImpl<$Res, GiftBreakdown>;
  @useResult
  $Res call({@JsonKey(name: 'gift_type') String giftType, int count});
}

/// @nodoc
class _$GiftBreakdownCopyWithImpl<$Res, $Val extends GiftBreakdown>
    implements $GiftBreakdownCopyWith<$Res> {
  _$GiftBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? giftType = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      giftType: null == giftType
          ? _value.giftType
          : giftType // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GiftBreakdownImplCopyWith<$Res>
    implements $GiftBreakdownCopyWith<$Res> {
  factory _$$GiftBreakdownImplCopyWith(
          _$GiftBreakdownImpl value, $Res Function(_$GiftBreakdownImpl) then) =
      __$$GiftBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'gift_type') String giftType, int count});
}

/// @nodoc
class __$$GiftBreakdownImplCopyWithImpl<$Res>
    extends _$GiftBreakdownCopyWithImpl<$Res, _$GiftBreakdownImpl>
    implements _$$GiftBreakdownImplCopyWith<$Res> {
  __$$GiftBreakdownImplCopyWithImpl(
      _$GiftBreakdownImpl _value, $Res Function(_$GiftBreakdownImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? giftType = null,
    Object? count = null,
  }) {
    return _then(_$GiftBreakdownImpl(
      giftType: null == giftType
          ? _value.giftType
          : giftType // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GiftBreakdownImpl extends _GiftBreakdown with DiagnosticableTreeMixin {
  const _$GiftBreakdownImpl(
      {@JsonKey(name: 'gift_type') required this.giftType, required this.count})
      : super._();

  factory _$GiftBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$GiftBreakdownImplFromJson(json);

  @override
  @JsonKey(name: 'gift_type')
  final String giftType;
  @override
  final int count;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GiftBreakdown(giftType: $giftType, count: $count)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GiftBreakdown'))
      ..add(DiagnosticsProperty('giftType', giftType))
      ..add(DiagnosticsProperty('count', count));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GiftBreakdownImpl &&
            (identical(other.giftType, giftType) ||
                other.giftType == giftType) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, giftType, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GiftBreakdownImplCopyWith<_$GiftBreakdownImpl> get copyWith =>
      __$$GiftBreakdownImplCopyWithImpl<_$GiftBreakdownImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GiftBreakdownImplToJson(
      this,
    );
  }
}

abstract class _GiftBreakdown extends GiftBreakdown {
  const factory _GiftBreakdown(
      {@JsonKey(name: 'gift_type') required final String giftType,
      required final int count}) = _$GiftBreakdownImpl;
  const _GiftBreakdown._() : super._();

  factory _GiftBreakdown.fromJson(Map<String, dynamic> json) =
      _$GiftBreakdownImpl.fromJson;

  @override
  @JsonKey(name: 'gift_type')
  String get giftType;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$GiftBreakdownImplCopyWith<_$GiftBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GiftResponse _$GiftResponseFromJson(Map<String, dynamic> json) {
  return _GiftResponse.fromJson(json);
}

/// @nodoc
mixin _$GiftResponse {
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  @JsonKey(name: 'gift_id')
  String? get giftId => throw _privateConstructorUsedError;
  @JsonKey(name: 'points_gifted')
  int? get pointsGifted => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_points')
  int? get remainingPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_points')
  int? get currentPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_points')
  int? get requiredPoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GiftResponseCopyWith<GiftResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GiftResponseCopyWith<$Res> {
  factory $GiftResponseCopyWith(
          GiftResponse value, $Res Function(GiftResponse) then) =
      _$GiftResponseCopyWithImpl<$Res, GiftResponse>;
  @useResult
  $Res call(
      {bool success,
      String? error,
      @JsonKey(name: 'gift_id') String? giftId,
      @JsonKey(name: 'points_gifted') int? pointsGifted,
      @JsonKey(name: 'remaining_points') int? remainingPoints,
      @JsonKey(name: 'current_points') int? currentPoints,
      @JsonKey(name: 'required_points') int? requiredPoints});
}

/// @nodoc
class _$GiftResponseCopyWithImpl<$Res, $Val extends GiftResponse>
    implements $GiftResponseCopyWith<$Res> {
  _$GiftResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? error = freezed,
    Object? giftId = freezed,
    Object? pointsGifted = freezed,
    Object? remainingPoints = freezed,
    Object? currentPoints = freezed,
    Object? requiredPoints = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      giftId: freezed == giftId
          ? _value.giftId
          : giftId // ignore: cast_nullable_to_non_nullable
              as String?,
      pointsGifted: freezed == pointsGifted
          ? _value.pointsGifted
          : pointsGifted // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingPoints: freezed == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      currentPoints: freezed == currentPoints
          ? _value.currentPoints
          : currentPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      requiredPoints: freezed == requiredPoints
          ? _value.requiredPoints
          : requiredPoints // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GiftResponseImplCopyWith<$Res>
    implements $GiftResponseCopyWith<$Res> {
  factory _$$GiftResponseImplCopyWith(
          _$GiftResponseImpl value, $Res Function(_$GiftResponseImpl) then) =
      __$$GiftResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? error,
      @JsonKey(name: 'gift_id') String? giftId,
      @JsonKey(name: 'points_gifted') int? pointsGifted,
      @JsonKey(name: 'remaining_points') int? remainingPoints,
      @JsonKey(name: 'current_points') int? currentPoints,
      @JsonKey(name: 'required_points') int? requiredPoints});
}

/// @nodoc
class __$$GiftResponseImplCopyWithImpl<$Res>
    extends _$GiftResponseCopyWithImpl<$Res, _$GiftResponseImpl>
    implements _$$GiftResponseImplCopyWith<$Res> {
  __$$GiftResponseImplCopyWithImpl(
      _$GiftResponseImpl _value, $Res Function(_$GiftResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? error = freezed,
    Object? giftId = freezed,
    Object? pointsGifted = freezed,
    Object? remainingPoints = freezed,
    Object? currentPoints = freezed,
    Object? requiredPoints = freezed,
  }) {
    return _then(_$GiftResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      giftId: freezed == giftId
          ? _value.giftId
          : giftId // ignore: cast_nullable_to_non_nullable
              as String?,
      pointsGifted: freezed == pointsGifted
          ? _value.pointsGifted
          : pointsGifted // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingPoints: freezed == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      currentPoints: freezed == currentPoints
          ? _value.currentPoints
          : currentPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      requiredPoints: freezed == requiredPoints
          ? _value.requiredPoints
          : requiredPoints // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GiftResponseImpl extends _GiftResponse with DiagnosticableTreeMixin {
  const _$GiftResponseImpl(
      {required this.success,
      this.error,
      @JsonKey(name: 'gift_id') this.giftId,
      @JsonKey(name: 'points_gifted') this.pointsGifted,
      @JsonKey(name: 'remaining_points') this.remainingPoints,
      @JsonKey(name: 'current_points') this.currentPoints,
      @JsonKey(name: 'required_points') this.requiredPoints})
      : super._();

  factory _$GiftResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GiftResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String? error;
  @override
  @JsonKey(name: 'gift_id')
  final String? giftId;
  @override
  @JsonKey(name: 'points_gifted')
  final int? pointsGifted;
  @override
  @JsonKey(name: 'remaining_points')
  final int? remainingPoints;
  @override
  @JsonKey(name: 'current_points')
  final int? currentPoints;
  @override
  @JsonKey(name: 'required_points')
  final int? requiredPoints;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GiftResponse(success: $success, error: $error, giftId: $giftId, pointsGifted: $pointsGifted, remainingPoints: $remainingPoints, currentPoints: $currentPoints, requiredPoints: $requiredPoints)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GiftResponse'))
      ..add(DiagnosticsProperty('success', success))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('giftId', giftId))
      ..add(DiagnosticsProperty('pointsGifted', pointsGifted))
      ..add(DiagnosticsProperty('remainingPoints', remainingPoints))
      ..add(DiagnosticsProperty('currentPoints', currentPoints))
      ..add(DiagnosticsProperty('requiredPoints', requiredPoints));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GiftResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.giftId, giftId) || other.giftId == giftId) &&
            (identical(other.pointsGifted, pointsGifted) ||
                other.pointsGifted == pointsGifted) &&
            (identical(other.remainingPoints, remainingPoints) ||
                other.remainingPoints == remainingPoints) &&
            (identical(other.currentPoints, currentPoints) ||
                other.currentPoints == currentPoints) &&
            (identical(other.requiredPoints, requiredPoints) ||
                other.requiredPoints == requiredPoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, error, giftId,
      pointsGifted, remainingPoints, currentPoints, requiredPoints);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GiftResponseImplCopyWith<_$GiftResponseImpl> get copyWith =>
      __$$GiftResponseImplCopyWithImpl<_$GiftResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GiftResponseImplToJson(
      this,
    );
  }
}

abstract class _GiftResponse extends GiftResponse {
  const factory _GiftResponse(
          {required final bool success,
          final String? error,
          @JsonKey(name: 'gift_id') final String? giftId,
          @JsonKey(name: 'points_gifted') final int? pointsGifted,
          @JsonKey(name: 'remaining_points') final int? remainingPoints,
          @JsonKey(name: 'current_points') final int? currentPoints,
          @JsonKey(name: 'required_points') final int? requiredPoints}) =
      _$GiftResponseImpl;
  const _GiftResponse._() : super._();

  factory _GiftResponse.fromJson(Map<String, dynamic> json) =
      _$GiftResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String? get error;
  @override
  @JsonKey(name: 'gift_id')
  String? get giftId;
  @override
  @JsonKey(name: 'points_gifted')
  int? get pointsGifted;
  @override
  @JsonKey(name: 'remaining_points')
  int? get remainingPoints;
  @override
  @JsonKey(name: 'current_points')
  int? get currentPoints;
  @override
  @JsonKey(name: 'required_points')
  int? get requiredPoints;
  @override
  @JsonKey(ignore: true)
  _$$GiftResponseImplCopyWith<_$GiftResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
