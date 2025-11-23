// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_categories.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PodcastCategory _$PodcastCategoryFromJson(Map<String, dynamic> json) {
  return _PodcastCategory.fromJson(json);
}

/// @nodoc
mixin _$PodcastCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  List<String> get subcategories => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastCategoryCopyWith<PodcastCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastCategoryCopyWith<$Res> {
  factory $PodcastCategoryCopyWith(
          PodcastCategory value, $Res Function(PodcastCategory) then) =
      _$PodcastCategoryCopyWithImpl<$Res, PodcastCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      List<String> subcategories,
      bool isActive});
}

/// @nodoc
class _$PodcastCategoryCopyWithImpl<$Res, $Val extends PodcastCategory>
    implements $PodcastCategoryCopyWith<$Res> {
  _$PodcastCategoryCopyWithImpl(this._value, this._then);

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
    Object? subcategories = null,
    Object? isActive = null,
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
      subcategories: null == subcategories
          ? _value.subcategories
          : subcategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastCategoryImplCopyWith<$Res>
    implements $PodcastCategoryCopyWith<$Res> {
  factory _$$PodcastCategoryImplCopyWith(_$PodcastCategoryImpl value,
          $Res Function(_$PodcastCategoryImpl) then) =
      __$$PodcastCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      List<String> subcategories,
      bool isActive});
}

/// @nodoc
class __$$PodcastCategoryImplCopyWithImpl<$Res>
    extends _$PodcastCategoryCopyWithImpl<$Res, _$PodcastCategoryImpl>
    implements _$$PodcastCategoryImplCopyWith<$Res> {
  __$$PodcastCategoryImplCopyWithImpl(
      _$PodcastCategoryImpl _value, $Res Function(_$PodcastCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = null,
    Object? subcategories = null,
    Object? isActive = null,
  }) {
    return _then(_$PodcastCategoryImpl(
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
      subcategories: null == subcategories
          ? _value._subcategories
          : subcategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastCategoryImpl implements _PodcastCategory {
  const _$PodcastCategoryImpl(
      {required this.id,
      required this.name,
      required this.emoji,
      final List<String> subcategories = const [],
      this.isActive = true})
      : _subcategories = subcategories;

  factory _$PodcastCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String emoji;
  final List<String> _subcategories;
  @override
  @JsonKey()
  List<String> get subcategories {
    if (_subcategories is EqualUnmodifiableListView) return _subcategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subcategories);
  }

  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'PodcastCategory(id: $id, name: $name, emoji: $emoji, subcategories: $subcategories, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality()
                .equals(other._subcategories, _subcategories) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji,
      const DeepCollectionEquality().hash(_subcategories), isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastCategoryImplCopyWith<_$PodcastCategoryImpl> get copyWith =>
      __$$PodcastCategoryImplCopyWithImpl<_$PodcastCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastCategoryImplToJson(
      this,
    );
  }
}

abstract class _PodcastCategory implements PodcastCategory {
  const factory _PodcastCategory(
      {required final String id,
      required final String name,
      required final String emoji,
      final List<String> subcategories,
      final bool isActive}) = _$PodcastCategoryImpl;

  factory _PodcastCategory.fromJson(Map<String, dynamic> json) =
      _$PodcastCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get emoji;
  @override
  List<String> get subcategories;
  @override
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$PodcastCategoryImplCopyWith<_$PodcastCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
