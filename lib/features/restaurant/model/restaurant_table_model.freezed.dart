// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_table_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RestaurantTable _$RestaurantTableFromJson(Map<String, dynamic> json) {
  return _RestaurantTable.fromJson(json);
}

/// @nodoc
mixin _$RestaurantTable {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'restaurant_id')
  String get restaurantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'table_number')
  String get tableNumber => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'table_type')
  String get tableType => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_description')
  String? get locationDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RestaurantTableCopyWith<RestaurantTable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantTableCopyWith<$Res> {
  factory $RestaurantTableCopyWith(
          RestaurantTable value, $Res Function(RestaurantTable) then) =
      _$RestaurantTableCopyWithImpl<$Res, RestaurantTable>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'table_number') String tableNumber,
      int capacity,
      @JsonKey(name: 'is_available') bool isAvailable,
      @JsonKey(name: 'table_type') String tableType,
      @JsonKey(name: 'location_description') String? locationDescription,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$RestaurantTableCopyWithImpl<$Res, $Val extends RestaurantTable>
    implements $RestaurantTableCopyWith<$Res> {
  _$RestaurantTableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? tableNumber = null,
    Object? capacity = null,
    Object? isAvailable = null,
    Object? tableType = null,
    Object? locationDescription = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      tableNumber: null == tableNumber
          ? _value.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      tableType: null == tableType
          ? _value.tableType
          : tableType // ignore: cast_nullable_to_non_nullable
              as String,
      locationDescription: freezed == locationDescription
          ? _value.locationDescription
          : locationDescription // ignore: cast_nullable_to_non_nullable
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
abstract class _$$RestaurantTableImplCopyWith<$Res>
    implements $RestaurantTableCopyWith<$Res> {
  factory _$$RestaurantTableImplCopyWith(_$RestaurantTableImpl value,
          $Res Function(_$RestaurantTableImpl) then) =
      __$$RestaurantTableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'table_number') String tableNumber,
      int capacity,
      @JsonKey(name: 'is_available') bool isAvailable,
      @JsonKey(name: 'table_type') String tableType,
      @JsonKey(name: 'location_description') String? locationDescription,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$RestaurantTableImplCopyWithImpl<$Res>
    extends _$RestaurantTableCopyWithImpl<$Res, _$RestaurantTableImpl>
    implements _$$RestaurantTableImplCopyWith<$Res> {
  __$$RestaurantTableImplCopyWithImpl(
      _$RestaurantTableImpl _value, $Res Function(_$RestaurantTableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? tableNumber = null,
    Object? capacity = null,
    Object? isAvailable = null,
    Object? tableType = null,
    Object? locationDescription = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RestaurantTableImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      tableNumber: null == tableNumber
          ? _value.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      tableType: null == tableType
          ? _value.tableType
          : tableType // ignore: cast_nullable_to_non_nullable
              as String,
      locationDescription: freezed == locationDescription
          ? _value.locationDescription
          : locationDescription // ignore: cast_nullable_to_non_nullable
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
class _$RestaurantTableImpl extends _RestaurantTable {
  const _$RestaurantTableImpl(
      {required this.id,
      @JsonKey(name: 'restaurant_id') required this.restaurantId,
      @JsonKey(name: 'table_number') required this.tableNumber,
      required this.capacity,
      @JsonKey(name: 'is_available') this.isAvailable = true,
      @JsonKey(name: 'table_type') this.tableType = 'standard',
      @JsonKey(name: 'location_description') this.locationDescription,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$RestaurantTableImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantTableImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  @override
  @JsonKey(name: 'table_number')
  final String tableNumber;
  @override
  final int capacity;
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @override
  @JsonKey(name: 'table_type')
  final String tableType;
  @override
  @JsonKey(name: 'location_description')
  final String? locationDescription;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RestaurantTable(id: $id, restaurantId: $restaurantId, tableNumber: $tableNumber, capacity: $capacity, isAvailable: $isAvailable, tableType: $tableType, locationDescription: $locationDescription, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantTableImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.tableNumber, tableNumber) ||
                other.tableNumber == tableNumber) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.tableType, tableType) ||
                other.tableType == tableType) &&
            (identical(other.locationDescription, locationDescription) ||
                other.locationDescription == locationDescription) &&
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
      restaurantId,
      tableNumber,
      capacity,
      isAvailable,
      tableType,
      locationDescription,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantTableImplCopyWith<_$RestaurantTableImpl> get copyWith =>
      __$$RestaurantTableImplCopyWithImpl<_$RestaurantTableImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantTableImplToJson(
      this,
    );
  }
}

abstract class _RestaurantTable extends RestaurantTable {
  const factory _RestaurantTable(
      {required final String id,
      @JsonKey(name: 'restaurant_id') required final String restaurantId,
      @JsonKey(name: 'table_number') required final String tableNumber,
      required final int capacity,
      @JsonKey(name: 'is_available') final bool isAvailable,
      @JsonKey(name: 'table_type') final String tableType,
      @JsonKey(name: 'location_description') final String? locationDescription,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$RestaurantTableImpl;
  const _RestaurantTable._() : super._();

  factory _RestaurantTable.fromJson(Map<String, dynamic> json) =
      _$RestaurantTableImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'restaurant_id')
  String get restaurantId;
  @override
  @JsonKey(name: 'table_number')
  String get tableNumber;
  @override
  int get capacity;
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;
  @override
  @JsonKey(name: 'table_type')
  String get tableType;
  @override
  @JsonKey(name: 'location_description')
  String? get locationDescription;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RestaurantTableImplCopyWith<_$RestaurantTableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
