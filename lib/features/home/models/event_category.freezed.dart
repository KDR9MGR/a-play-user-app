// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventCategory _$EventCategoryFromJson(Map<String, dynamic> json) {
  return _EventCategory.fromJson(json);
}

/// @nodoc
mixin _$EventCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventCategoryCopyWith<EventCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCategoryCopyWith<$Res> {
  factory $EventCategoryCopyWith(
          EventCategory value, $Res Function(EventCategory) then) =
      _$EventCategoryCopyWithImpl<$Res, EventCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String displayName,
      String? icon,
      String? color,
      int sortOrder,
      bool isActive,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$EventCategoryCopyWithImpl<$Res, $Val extends EventCategory>
    implements $EventCategoryCopyWith<$Res> {
  _$EventCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? icon = freezed,
    Object? color = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$EventCategoryImplCopyWith<$Res>
    implements $EventCategoryCopyWith<$Res> {
  factory _$$EventCategoryImplCopyWith(
          _$EventCategoryImpl value, $Res Function(_$EventCategoryImpl) then) =
      __$$EventCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String displayName,
      String? icon,
      String? color,
      int sortOrder,
      bool isActive,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$EventCategoryImplCopyWithImpl<$Res>
    extends _$EventCategoryCopyWithImpl<$Res, _$EventCategoryImpl>
    implements _$$EventCategoryImplCopyWith<$Res> {
  __$$EventCategoryImplCopyWithImpl(
      _$EventCategoryImpl _value, $Res Function(_$EventCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? icon = freezed,
    Object? color = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$EventCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$EventCategoryImpl implements _EventCategory {
  const _$EventCategoryImpl(
      {required this.id,
      required this.name,
      required this.displayName,
      this.icon,
      this.color,
      this.sortOrder = 0,
      this.isActive = true,
      required this.createdAt,
      required this.updatedAt});

  factory _$EventCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String displayName;
  @override
  final String? icon;
  @override
  final String? color;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'EventCategory(id: $id, name: $name, displayName: $displayName, icon: $icon, color: $color, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, displayName, icon,
      color, sortOrder, isActive, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventCategoryImplCopyWith<_$EventCategoryImpl> get copyWith =>
      __$$EventCategoryImplCopyWithImpl<_$EventCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventCategoryImplToJson(
      this,
    );
  }
}

abstract class _EventCategory implements EventCategory {
  const factory _EventCategory(
      {required final String id,
      required final String name,
      required final String displayName,
      final String? icon,
      final String? color,
      final int sortOrder,
      final bool isActive,
      required final String createdAt,
      required final String updatedAt}) = _$EventCategoryImpl;

  factory _EventCategory.fromJson(Map<String, dynamic> json) =
      _$EventCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get displayName;
  @override
  String? get icon;
  @override
  String? get color;
  @override
  int get sortOrder;
  @override
  bool get isActive;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$EventCategoryImplCopyWith<_$EventCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
