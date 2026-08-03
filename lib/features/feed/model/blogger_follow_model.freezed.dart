// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blogger_follow_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BloggerFollow _$BloggerFollowFromJson(Map<String, dynamic> json) {
  return _BloggerFollow.fromJson(json);
}

/// @nodoc
mixin _$BloggerFollow {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'follower_id')
  String get followerId =>
      throw _privateConstructorUsedError; // User who is following
  @JsonKey(name: 'following_id')
  String get followingId =>
      throw _privateConstructorUsedError; // Blogger being followed
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BloggerFollowCopyWith<BloggerFollow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BloggerFollowCopyWith<$Res> {
  factory $BloggerFollowCopyWith(
          BloggerFollow value, $Res Function(BloggerFollow) then) =
      _$BloggerFollowCopyWithImpl<$Res, BloggerFollow>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'follower_id') String followerId,
      @JsonKey(name: 'following_id') String followingId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$BloggerFollowCopyWithImpl<$Res, $Val extends BloggerFollow>
    implements $BloggerFollowCopyWith<$Res> {
  _$BloggerFollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? followerId = null,
    Object? followingId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      followerId: null == followerId
          ? _value.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as String,
      followingId: null == followingId
          ? _value.followingId
          : followingId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BloggerFollowImplCopyWith<$Res>
    implements $BloggerFollowCopyWith<$Res> {
  factory _$$BloggerFollowImplCopyWith(
          _$BloggerFollowImpl value, $Res Function(_$BloggerFollowImpl) then) =
      __$$BloggerFollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'follower_id') String followerId,
      @JsonKey(name: 'following_id') String followingId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$BloggerFollowImplCopyWithImpl<$Res>
    extends _$BloggerFollowCopyWithImpl<$Res, _$BloggerFollowImpl>
    implements _$$BloggerFollowImplCopyWith<$Res> {
  __$$BloggerFollowImplCopyWithImpl(
      _$BloggerFollowImpl _value, $Res Function(_$BloggerFollowImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? followerId = null,
    Object? followingId = null,
    Object? createdAt = null,
  }) {
    return _then(_$BloggerFollowImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      followerId: null == followerId
          ? _value.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as String,
      followingId: null == followingId
          ? _value.followingId
          : followingId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BloggerFollowImpl implements _BloggerFollow {
  const _$BloggerFollowImpl(
      {required this.id,
      @JsonKey(name: 'follower_id') required this.followerId,
      @JsonKey(name: 'following_id') required this.followingId,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$BloggerFollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$BloggerFollowImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'follower_id')
  final String followerId;
// User who is following
  @override
  @JsonKey(name: 'following_id')
  final String followingId;
// Blogger being followed
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'BloggerFollow(id: $id, followerId: $followerId, followingId: $followingId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BloggerFollowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.followingId, followingId) ||
                other.followingId == followingId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, followerId, followingId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BloggerFollowImplCopyWith<_$BloggerFollowImpl> get copyWith =>
      __$$BloggerFollowImplCopyWithImpl<_$BloggerFollowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BloggerFollowImplToJson(
      this,
    );
  }
}

abstract class _BloggerFollow implements BloggerFollow {
  const factory _BloggerFollow(
          {required final String id,
          @JsonKey(name: 'follower_id') required final String followerId,
          @JsonKey(name: 'following_id') required final String followingId,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$BloggerFollowImpl;

  factory _BloggerFollow.fromJson(Map<String, dynamic> json) =
      _$BloggerFollowImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'follower_id')
  String get followerId;
  @override // User who is following
  @JsonKey(name: 'following_id')
  String get followingId;
  @override // Blogger being followed
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$BloggerFollowImplCopyWith<_$BloggerFollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
