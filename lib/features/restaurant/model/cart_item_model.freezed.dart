// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartItem _$CartItemFromJson(Map<String, dynamic> json) {
  return _CartItem.fromJson(json);
}

/// @nodoc
mixin _$CartItem {
  String get id => throw _privateConstructorUsedError;
  MenuItem get menuItem => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  List<MenuItemOption> get selectedOptions =>
      throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call(
      {String id,
      MenuItem menuItem,
      int quantity,
      List<MenuItemOption> selectedOptions,
      String? specialInstructions});

  $MenuItemCopyWith<$Res> get menuItem;
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItem = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItem: null == menuItem
          ? _value.menuItem
          : menuItem // ignore: cast_nullable_to_non_nullable
              as MenuItem,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptions: null == selectedOptions
          ? _value.selectedOptions
          : selectedOptions // ignore: cast_nullable_to_non_nullable
              as List<MenuItemOption>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MenuItemCopyWith<$Res> get menuItem {
    return $MenuItemCopyWith<$Res>(_value.menuItem, (value) {
      return _then(_value.copyWith(menuItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
          _$CartItemImpl value, $Res Function(_$CartItemImpl) then) =
      __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MenuItem menuItem,
      int quantity,
      List<MenuItemOption> selectedOptions,
      String? specialInstructions});

  @override
  $MenuItemCopyWith<$Res> get menuItem;
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
      _$CartItemImpl _value, $Res Function(_$CartItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItem = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? specialInstructions = freezed,
  }) {
    return _then(_$CartItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItem: null == menuItem
          ? _value.menuItem
          : menuItem // ignore: cast_nullable_to_non_nullable
              as MenuItem,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptions: null == selectedOptions
          ? _value._selectedOptions
          : selectedOptions // ignore: cast_nullable_to_non_nullable
              as List<MenuItemOption>,
      specialInstructions: freezed == specialInstructions
          ? _value.specialInstructions
          : specialInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemImpl implements _CartItem {
  const _$CartItemImpl(
      {required this.id,
      required this.menuItem,
      required this.quantity,
      final List<MenuItemOption> selectedOptions = const [],
      this.specialInstructions})
      : _selectedOptions = selectedOptions;

  factory _$CartItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemImplFromJson(json);

  @override
  final String id;
  @override
  final MenuItem menuItem;
  @override
  final int quantity;
  final List<MenuItemOption> _selectedOptions;
  @override
  @JsonKey()
  List<MenuItemOption> get selectedOptions {
    if (_selectedOptions is EqualUnmodifiableListView) return _selectedOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedOptions);
  }

  @override
  final String? specialInstructions;

  @override
  String toString() {
    return 'CartItem(id: $id, menuItem: $menuItem, quantity: $quantity, selectedOptions: $selectedOptions, specialInstructions: $specialInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItem, menuItem) ||
                other.menuItem == menuItem) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality()
                .equals(other._selectedOptions, _selectedOptions) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      menuItem,
      quantity,
      const DeepCollectionEquality().hash(_selectedOptions),
      specialInstructions);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemImplToJson(
      this,
    );
  }
}

abstract class _CartItem implements CartItem {
  const factory _CartItem(
      {required final String id,
      required final MenuItem menuItem,
      required final int quantity,
      final List<MenuItemOption> selectedOptions,
      final String? specialInstructions}) = _$CartItemImpl;

  factory _CartItem.fromJson(Map<String, dynamic> json) =
      _$CartItemImpl.fromJson;

  @override
  String get id;
  @override
  MenuItem get menuItem;
  @override
  int get quantity;
  @override
  List<MenuItemOption> get selectedOptions;
  @override
  String? get specialInstructions;
  @override
  @JsonKey(ignore: true)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
