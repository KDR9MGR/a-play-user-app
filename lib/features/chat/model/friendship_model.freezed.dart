// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Friendship _$FriendshipFromJson(Map<String, dynamic> json) {
  return _Friendship.fromJson(json);
}

/// @nodoc
mixin _$Friendship {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get friendId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  String? get friendName => throw _privateConstructorUsedError;
  String? get friendUsername => throw _privateConstructorUsedError;
  String? get friendAvatarUrl => throw _privateConstructorUsedError;
  bool? get friendIsOnline => throw _privateConstructorUsedError;
  String? get friendStatus => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get lastMessageTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FriendshipCopyWith<Friendship> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipCopyWith<$Res> {
  factory $FriendshipCopyWith(
          Friendship value, $Res Function(Friendship) then) =
      _$FriendshipCopyWithImpl<$Res, Friendship>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String friendId,
      String status,
      DateTime createdAt,
      DateTime updatedAt,
      String? friendName,
      String? friendUsername,
      String? friendAvatarUrl,
      bool? friendIsOnline,
      String? friendStatus,
      String? lastMessage,
      DateTime? lastMessageTime});
}

/// @nodoc
class _$FriendshipCopyWithImpl<$Res, $Val extends Friendship>
    implements $FriendshipCopyWith<$Res> {
  _$FriendshipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? friendName = freezed,
    Object? friendUsername = freezed,
    Object? friendAvatarUrl = freezed,
    Object? friendIsOnline = freezed,
    Object? friendStatus = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
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
      friendId: null == friendId
          ? _value.friendId
          : friendId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      friendName: freezed == friendName
          ? _value.friendName
          : friendName // ignore: cast_nullable_to_non_nullable
              as String?,
      friendUsername: freezed == friendUsername
          ? _value.friendUsername
          : friendUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      friendAvatarUrl: freezed == friendAvatarUrl
          ? _value.friendAvatarUrl
          : friendAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      friendIsOnline: freezed == friendIsOnline
          ? _value.friendIsOnline
          : friendIsOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      friendStatus: freezed == friendStatus
          ? _value.friendStatus
          : friendStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendshipImplCopyWith<$Res>
    implements $FriendshipCopyWith<$Res> {
  factory _$$FriendshipImplCopyWith(
          _$FriendshipImpl value, $Res Function(_$FriendshipImpl) then) =
      __$$FriendshipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String friendId,
      String status,
      DateTime createdAt,
      DateTime updatedAt,
      String? friendName,
      String? friendUsername,
      String? friendAvatarUrl,
      bool? friendIsOnline,
      String? friendStatus,
      String? lastMessage,
      DateTime? lastMessageTime});
}

/// @nodoc
class __$$FriendshipImplCopyWithImpl<$Res>
    extends _$FriendshipCopyWithImpl<$Res, _$FriendshipImpl>
    implements _$$FriendshipImplCopyWith<$Res> {
  __$$FriendshipImplCopyWithImpl(
      _$FriendshipImpl _value, $Res Function(_$FriendshipImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? friendId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? friendName = freezed,
    Object? friendUsername = freezed,
    Object? friendAvatarUrl = freezed,
    Object? friendIsOnline = freezed,
    Object? friendStatus = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
  }) {
    return _then(_$FriendshipImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      friendId: null == friendId
          ? _value.friendId
          : friendId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      friendName: freezed == friendName
          ? _value.friendName
          : friendName // ignore: cast_nullable_to_non_nullable
              as String?,
      friendUsername: freezed == friendUsername
          ? _value.friendUsername
          : friendUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      friendAvatarUrl: freezed == friendAvatarUrl
          ? _value.friendAvatarUrl
          : friendAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      friendIsOnline: freezed == friendIsOnline
          ? _value.friendIsOnline
          : friendIsOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      friendStatus: freezed == friendStatus
          ? _value.friendStatus
          : friendStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipImpl implements _Friendship {
  const _$FriendshipImpl(
      {required this.id,
      required this.userId,
      required this.friendId,
      this.status = 'pending',
      required this.createdAt,
      required this.updatedAt,
      this.friendName,
      this.friendUsername,
      this.friendAvatarUrl,
      this.friendIsOnline,
      this.friendStatus,
      this.lastMessage,
      this.lastMessageTime});

  factory _$FriendshipImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String friendId;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// Additional fields for UI
  @override
  final String? friendName;
  @override
  final String? friendUsername;
  @override
  final String? friendAvatarUrl;
  @override
  final bool? friendIsOnline;
  @override
  final String? friendStatus;
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageTime;

  @override
  String toString() {
    return 'Friendship(id: $id, userId: $userId, friendId: $friendId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, friendName: $friendName, friendUsername: $friendUsername, friendAvatarUrl: $friendAvatarUrl, friendIsOnline: $friendIsOnline, friendStatus: $friendStatus, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.friendId, friendId) ||
                other.friendId == friendId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.friendName, friendName) ||
                other.friendName == friendName) &&
            (identical(other.friendUsername, friendUsername) ||
                other.friendUsername == friendUsername) &&
            (identical(other.friendAvatarUrl, friendAvatarUrl) ||
                other.friendAvatarUrl == friendAvatarUrl) &&
            (identical(other.friendIsOnline, friendIsOnline) ||
                other.friendIsOnline == friendIsOnline) &&
            (identical(other.friendStatus, friendStatus) ||
                other.friendStatus == friendStatus) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      friendId,
      status,
      createdAt,
      updatedAt,
      friendName,
      friendUsername,
      friendAvatarUrl,
      friendIsOnline,
      friendStatus,
      lastMessage,
      lastMessageTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipImplCopyWith<_$FriendshipImpl> get copyWith =>
      __$$FriendshipImplCopyWithImpl<_$FriendshipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipImplToJson(
      this,
    );
  }
}

abstract class _Friendship implements Friendship {
  const factory _Friendship(
      {required final String id,
      required final String userId,
      required final String friendId,
      final String status,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? friendName,
      final String? friendUsername,
      final String? friendAvatarUrl,
      final bool? friendIsOnline,
      final String? friendStatus,
      final String? lastMessage,
      final DateTime? lastMessageTime}) = _$FriendshipImpl;

  factory _Friendship.fromJson(Map<String, dynamic> json) =
      _$FriendshipImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get friendId;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override // Additional fields for UI
  String? get friendName;
  @override
  String? get friendUsername;
  @override
  String? get friendAvatarUrl;
  @override
  bool? get friendIsOnline;
  @override
  String? get friendStatus;
  @override
  String? get lastMessage;
  @override
  DateTime? get lastMessageTime;
  @override
  @JsonKey(ignore: true)
  _$$FriendshipImplCopyWith<_$FriendshipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
