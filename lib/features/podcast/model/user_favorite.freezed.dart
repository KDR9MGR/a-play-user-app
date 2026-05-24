// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_favorite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserFavorite _$UserFavoriteFromJson(Map<String, dynamic> json) {
  return _UserFavorite.fromJson(json);
}

/// @nodoc
mixin _$UserFavorite {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserFavoriteCopyWith<UserFavorite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFavoriteCopyWith<$Res> {
  factory $UserFavoriteCopyWith(
          UserFavorite value, $Res Function(UserFavorite) then) =
      _$UserFavoriteCopyWithImpl<$Res, UserFavorite>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String contentId,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$UserFavoriteCopyWithImpl<$Res, $Val extends UserFavorite>
    implements $UserFavoriteCopyWith<$Res> {
  _$UserFavoriteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
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
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$UserFavoriteImplCopyWith<$Res>
    implements $UserFavoriteCopyWith<$Res> {
  factory _$$UserFavoriteImplCopyWith(
          _$UserFavoriteImpl value, $Res Function(_$UserFavoriteImpl) then) =
      __$$UserFavoriteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String contentId,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$UserFavoriteImplCopyWithImpl<$Res>
    extends _$UserFavoriteCopyWithImpl<$Res, _$UserFavoriteImpl>
    implements _$$UserFavoriteImplCopyWith<$Res> {
  __$$UserFavoriteImplCopyWithImpl(
      _$UserFavoriteImpl _value, $Res Function(_$UserFavoriteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? contentId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserFavoriteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$UserFavoriteImpl implements _UserFavorite {
  const _$UserFavoriteImpl(
      {required this.id,
      required this.userId,
      required this.contentId,
      required this.createdAt,
      required this.updatedAt});

  factory _$UserFavoriteImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserFavoriteImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String contentId;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'UserFavorite(id: $id, userId: $userId, contentId: $contentId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFavoriteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, contentId, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFavoriteImplCopyWith<_$UserFavoriteImpl> get copyWith =>
      __$$UserFavoriteImplCopyWithImpl<_$UserFavoriteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserFavoriteImplToJson(
      this,
    );
  }
}

abstract class _UserFavorite implements UserFavorite {
  const factory _UserFavorite(
      {required final String id,
      required final String userId,
      required final String contentId,
      required final String createdAt,
      required final String updatedAt}) = _$UserFavoriteImpl;

  factory _UserFavorite.fromJson(Map<String, dynamic> json) =
      _$UserFavoriteImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get contentId;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserFavoriteImplCopyWith<_$UserFavoriteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
