// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) {
  return _MenuItem.fromJson(json);
}

/// @nodoc
mixin _$MenuItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'restaurant_id')
  String get restaurantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_vegetarian')
  bool get isVegetarian => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_vegan')
  bool get isVegan => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_spicy')
  bool get isSpicy => throw _privateConstructorUsedError;
  List<String> get allergens => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  @JsonKey(name: 'preparation_time')
  int get preparationTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_popular')
  bool get isPopular => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenuItemCopyWith<MenuItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemCopyWith<$Res> {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) then) =
      _$MenuItemCopyWithImpl<$Res, MenuItem>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'category_id') String categoryId,
      String name,
      String? description,
      double price,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'is_vegetarian') bool isVegetarian,
      @JsonKey(name: 'is_vegan') bool isVegan,
      @JsonKey(name: 'is_spicy') bool isSpicy,
      List<String> allergens,
      int? calories,
      @JsonKey(name: 'preparation_time') int preparationTime,
      @JsonKey(name: 'is_available') bool isAvailable,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$MenuItemCopyWithImpl<$Res, $Val extends MenuItem>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? categoryId = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? isVegetarian = null,
    Object? isVegan = null,
    Object? isSpicy = null,
    Object? allergens = null,
    Object? calories = freezed,
    Object? preparationTime = null,
    Object? isAvailable = null,
    Object? isPopular = null,
    Object? displayOrder = null,
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
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVegetarian: null == isVegetarian
          ? _value.isVegetarian
          : isVegetarian // ignore: cast_nullable_to_non_nullable
              as bool,
      isVegan: null == isVegan
          ? _value.isVegan
          : isVegan // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpicy: null == isSpicy
          ? _value.isSpicy
          : isSpicy // ignore: cast_nullable_to_non_nullable
              as bool,
      allergens: null == allergens
          ? _value.allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      preparationTime: null == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$MenuItemImplCopyWith<$Res>
    implements $MenuItemCopyWith<$Res> {
  factory _$$MenuItemImplCopyWith(
          _$MenuItemImpl value, $Res Function(_$MenuItemImpl) then) =
      __$$MenuItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'restaurant_id') String restaurantId,
      @JsonKey(name: 'category_id') String categoryId,
      String name,
      String? description,
      double price,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'is_vegetarian') bool isVegetarian,
      @JsonKey(name: 'is_vegan') bool isVegan,
      @JsonKey(name: 'is_spicy') bool isSpicy,
      List<String> allergens,
      int? calories,
      @JsonKey(name: 'preparation_time') int preparationTime,
      @JsonKey(name: 'is_available') bool isAvailable,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'display_order') int displayOrder,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$MenuItemImplCopyWithImpl<$Res>
    extends _$MenuItemCopyWithImpl<$Res, _$MenuItemImpl>
    implements _$$MenuItemImplCopyWith<$Res> {
  __$$MenuItemImplCopyWithImpl(
      _$MenuItemImpl _value, $Res Function(_$MenuItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantId = null,
    Object? categoryId = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? imageUrl = freezed,
    Object? isVegetarian = null,
    Object? isVegan = null,
    Object? isSpicy = null,
    Object? allergens = null,
    Object? calories = freezed,
    Object? preparationTime = null,
    Object? isAvailable = null,
    Object? isPopular = null,
    Object? displayOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MenuItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantId: null == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isVegetarian: null == isVegetarian
          ? _value.isVegetarian
          : isVegetarian // ignore: cast_nullable_to_non_nullable
              as bool,
      isVegan: null == isVegan
          ? _value.isVegan
          : isVegan // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpicy: null == isSpicy
          ? _value.isSpicy
          : isSpicy // ignore: cast_nullable_to_non_nullable
              as bool,
      allergens: null == allergens
          ? _value._allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      calories: freezed == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int?,
      preparationTime: null == preparationTime
          ? _value.preparationTime
          : preparationTime // ignore: cast_nullable_to_non_nullable
              as int,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$MenuItemImpl implements _MenuItem {
  const _$MenuItemImpl(
      {required this.id,
      @JsonKey(name: 'restaurant_id') required this.restaurantId,
      @JsonKey(name: 'category_id') required this.categoryId,
      required this.name,
      this.description,
      required this.price,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'is_vegetarian') this.isVegetarian = false,
      @JsonKey(name: 'is_vegan') this.isVegan = false,
      @JsonKey(name: 'is_spicy') this.isSpicy = false,
      final List<String> allergens = const [],
      this.calories,
      @JsonKey(name: 'preparation_time') this.preparationTime = 15,
      @JsonKey(name: 'is_available') this.isAvailable = true,
      @JsonKey(name: 'is_popular') this.isPopular = false,
      @JsonKey(name: 'display_order') this.displayOrder = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _allergens = allergens;

  factory _$MenuItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'is_vegetarian')
  final bool isVegetarian;
  @override
  @JsonKey(name: 'is_vegan')
  final bool isVegan;
  @override
  @JsonKey(name: 'is_spicy')
  final bool isSpicy;
  final List<String> _allergens;
  @override
  @JsonKey()
  List<String> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  @override
  final int? calories;
  @override
  @JsonKey(name: 'preparation_time')
  final int preparationTime;
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @override
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @override
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'MenuItem(id: $id, restaurantId: $restaurantId, categoryId: $categoryId, name: $name, description: $description, price: $price, imageUrl: $imageUrl, isVegetarian: $isVegetarian, isVegan: $isVegan, isSpicy: $isSpicy, allergens: $allergens, calories: $calories, preparationTime: $preparationTime, isAvailable: $isAvailable, isPopular: $isPopular, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isVegetarian, isVegetarian) ||
                other.isVegetarian == isVegetarian) &&
            (identical(other.isVegan, isVegan) || other.isVegan == isVegan) &&
            (identical(other.isSpicy, isSpicy) || other.isSpicy == isSpicy) &&
            const DeepCollectionEquality()
                .equals(other._allergens, _allergens) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.preparationTime, preparationTime) ||
                other.preparationTime == preparationTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
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
      categoryId,
      name,
      description,
      price,
      imageUrl,
      isVegetarian,
      isVegan,
      isSpicy,
      const DeepCollectionEquality().hash(_allergens),
      calories,
      preparationTime,
      isAvailable,
      isPopular,
      displayOrder,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      __$$MenuItemImplCopyWithImpl<_$MenuItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemImplToJson(
      this,
    );
  }
}

abstract class _MenuItem implements MenuItem {
  const factory _MenuItem(
          {required final String id,
          @JsonKey(name: 'restaurant_id') required final String restaurantId,
          @JsonKey(name: 'category_id') required final String categoryId,
          required final String name,
          final String? description,
          required final double price,
          @JsonKey(name: 'image_url') final String? imageUrl,
          @JsonKey(name: 'is_vegetarian') final bool isVegetarian,
          @JsonKey(name: 'is_vegan') final bool isVegan,
          @JsonKey(name: 'is_spicy') final bool isSpicy,
          final List<String> allergens,
          final int? calories,
          @JsonKey(name: 'preparation_time') final int preparationTime,
          @JsonKey(name: 'is_available') final bool isAvailable,
          @JsonKey(name: 'is_popular') final bool isPopular,
          @JsonKey(name: 'display_order') final int displayOrder,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$MenuItemImpl;

  factory _MenuItem.fromJson(Map<String, dynamic> json) =
      _$MenuItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'restaurant_id')
  String get restaurantId;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'is_vegetarian')
  bool get isVegetarian;
  @override
  @JsonKey(name: 'is_vegan')
  bool get isVegan;
  @override
  @JsonKey(name: 'is_spicy')
  bool get isSpicy;
  @override
  List<String> get allergens;
  @override
  int? get calories;
  @override
  @JsonKey(name: 'preparation_time')
  int get preparationTime;
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;
  @override
  @JsonKey(name: 'is_popular')
  bool get isPopular;
  @override
  @JsonKey(name: 'display_order')
  int get displayOrder;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
