// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) {
  return _MenuCategory.fromJson(json);
}

/// @nodoc
mixin _$MenuCategory {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'restaurant_id')
  String get restaurantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenuCategoryCopyWith<MenuCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuCategoryCopyWith<$Res> {
  factory $MenuCategoryCopyWith(
          MenuCategory value, $Res Function(MenuCategory) then) =
      _$MenuCategoryCopyWithImpl<$Res, MenuCategory>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      String name,
      String? description,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$MenuCategoryCopyWithImpl<$Res, $Val extends MenuCategory>
    implements $MenuCategoryCopyWith<$Res> {
  _$MenuCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuCategoryImplCopyWith<$Res>
    implements $MenuCategoryCopyWith<$Res> {
  factory _$$MenuCategoryImplCopyWith(
          _$MenuCategoryImpl value, $Res Function(_$MenuCategoryImpl) then) =
      __$$MenuCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      String name,
      String? description,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$MenuCategoryImplCopyWithImpl<$Res>
    extends _$MenuCategoryCopyWithImpl<$Res, _$MenuCategoryImpl>
    implements _$$MenuCategoryImplCopyWith<$Res> {
  __$$MenuCategoryImplCopyWithImpl(
      _$MenuCategoryImpl _value, $Res Function(_$MenuCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? name = null,
    Object? description = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MenuCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$MenuCategoryImpl implements _MenuCategory {
  const _$MenuCategoryImpl(
      {required this.id,
      @JsonKey(name: 'restaurant_id') required this.restaurantId,
      required this.name,
      this.description,
      @JsonKey(name: 'display_order') this.displayOrder = 0,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$MenuCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuCategoryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'MenuCategory(id: $id, restaurantId: $restaurantId, name: $name, description: $description, displayOrder: $displayOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, restaurantId, name,
      description, displayOrder, isActive, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      __$$MenuCategoryImplCopyWithImpl<_$MenuCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuCategoryImplToJson(
      this,
    );
  }
}

abstract class _MenuCategory implements MenuCategory {
  const factory _MenuCategory(
          {required final String id,
          @JsonKey(name: 'restaurant_id') required final String restaurantId,
          required final String name,
          final String? description,
          @JsonKey(name: 'display_order') final int displayOrder,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$MenuCategoryImpl;

  factory _MenuCategory.fromJson(Map<String, dynamic> json) =
      _$MenuCategoryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'restaurant_id')
  String get restaurantId;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'display_order')
  int get displayOrder;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
