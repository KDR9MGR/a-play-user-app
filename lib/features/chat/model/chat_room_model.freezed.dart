// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return _ChatRoom.fromJson(json);
}

/// @nodoc
mixin _$ChatRoom {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_ids')
  List<String>? get participantIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message')
  String? get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_time')
  DateTime? get lastMessageTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_group')
  bool get isGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  List<ChatParticipant> get participants => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count')
  int? get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_online')
  bool? get isOnline => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type_id')
  String? get roomTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type')
  RoomType? get roomType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatRoomCopyWith<ChatRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomCopyWith<$Res> {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) then) =
      _$ChatRoomCopyWithImpl<$Res, ChatRoom>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'participant_ids') List<String>? participantIds,
      @JsonKey(name: 'last_message') String? lastMessage,
      @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
      @JsonKey(name: 'is_group') bool isGroup,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      List<ChatParticipant> participants,
      @JsonKey(name: 'unread_count') int? unreadCount,
      @JsonKey(name: 'is_online') bool? isOnline,
      @JsonKey(name: 'room_type_id') String? roomTypeId,
      @JsonKey(name: 'room_type') RoomType? roomType});

  $RoomTypeCopyWith<$Res>? get roomType;
}

/// @nodoc
class _$ChatRoomCopyWithImpl<$Res, $Val extends ChatRoom>
    implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? participantIds = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
    Object? isGroup = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? participants = null,
    Object? unreadCount = freezed,
    Object? isOnline = freezed,
    Object? roomTypeId = freezed,
    Object? roomType = freezed,
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
      participantIds: freezed == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<ChatParticipant>,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      roomTypeId: freezed == roomTypeId
          ? _value.roomTypeId
          : roomTypeId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomType: freezed == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RoomType?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomTypeCopyWith<$Res>? get roomType {
    if (_value.roomType == null) {
      return null;
    }

    return $RoomTypeCopyWith<$Res>(_value.roomType!, (value) {
      return _then(_value.copyWith(roomType: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomImplCopyWith<$Res>
    implements $ChatRoomCopyWith<$Res> {
  factory _$$ChatRoomImplCopyWith(
          _$ChatRoomImpl value, $Res Function(_$ChatRoomImpl) then) =
      __$$ChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'participant_ids') List<String>? participantIds,
      @JsonKey(name: 'last_message') String? lastMessage,
      @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
      @JsonKey(name: 'is_group') bool isGroup,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      List<ChatParticipant> participants,
      @JsonKey(name: 'unread_count') int? unreadCount,
      @JsonKey(name: 'is_online') bool? isOnline,
      @JsonKey(name: 'room_type_id') String? roomTypeId,
      @JsonKey(name: 'room_type') RoomType? roomType});

  @override
  $RoomTypeCopyWith<$Res>? get roomType;
}

/// @nodoc
class __$$ChatRoomImplCopyWithImpl<$Res>
    extends _$ChatRoomCopyWithImpl<$Res, _$ChatRoomImpl>
    implements _$$ChatRoomImplCopyWith<$Res> {
  __$$ChatRoomImplCopyWithImpl(
      _$ChatRoomImpl _value, $Res Function(_$ChatRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? participantIds = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
    Object? isGroup = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? participants = null,
    Object? unreadCount = freezed,
    Object? isOnline = freezed,
    Object? roomTypeId = freezed,
    Object? roomType = freezed,
  }) {
    return _then(_$ChatRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: freezed == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<ChatParticipant>,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      roomTypeId: freezed == roomTypeId
          ? _value.roomTypeId
          : roomTypeId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomType: freezed == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RoomType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomImpl implements _ChatRoom {
  const _$ChatRoomImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'participant_ids') final List<String>? participantIds,
      @JsonKey(name: 'last_message') this.lastMessage,
      @JsonKey(name: 'last_message_time') this.lastMessageTime,
      @JsonKey(name: 'is_group') this.isGroup = false,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      final List<ChatParticipant> participants = const [],
      @JsonKey(name: 'unread_count') this.unreadCount,
      @JsonKey(name: 'is_online') this.isOnline,
      @JsonKey(name: 'room_type_id') this.roomTypeId,
      @JsonKey(name: 'room_type') this.roomType})
      : _participantIds = participantIds,
        _participants = participants;

  factory _$ChatRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String>? _participantIds;
  @override
  @JsonKey(name: 'participant_ids')
  List<String>? get participantIds {
    final value = _participantIds;
    if (value == null) return null;
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'last_message')
  final String? lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  final DateTime? lastMessageTime;
  @override
  @JsonKey(name: 'is_group')
  final bool isGroup;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// Additional fields for UI
  final List<ChatParticipant> _participants;
// Additional fields for UI
  @override
  @JsonKey()
  List<ChatParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey(name: 'unread_count')
  final int? unreadCount;
  @override
  @JsonKey(name: 'is_online')
  final bool? isOnline;
  @override
  @JsonKey(name: 'room_type_id')
  final String? roomTypeId;
  @override
  @JsonKey(name: 'room_type')
  final RoomType? roomType;

  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, participantIds: $participantIds, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, isGroup: $isGroup, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, participants: $participants, unreadCount: $unreadCount, isOnline: $isOnline, roomTypeId: $roomTypeId, roomType: $roomType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.isGroup, isGroup) || other.isGroup == isGroup) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.roomTypeId, roomTypeId) ||
                other.roomTypeId == roomTypeId) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_participantIds),
      lastMessage,
      lastMessageTime,
      isGroup,
      avatarUrl,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_participants),
      unreadCount,
      isOnline,
      roomTypeId,
      roomType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      __$$ChatRoomImplCopyWithImpl<_$ChatRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomImplToJson(
      this,
    );
  }
}

abstract class _ChatRoom implements ChatRoom {
  const factory _ChatRoom(
      {required final String id,
      required final String name,
      @JsonKey(name: 'participant_ids') final List<String>? participantIds,
      @JsonKey(name: 'last_message') final String? lastMessage,
      @JsonKey(name: 'last_message_time') final DateTime? lastMessageTime,
      @JsonKey(name: 'is_group') final bool isGroup,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      final List<ChatParticipant> participants,
      @JsonKey(name: 'unread_count') final int? unreadCount,
      @JsonKey(name: 'is_online') final bool? isOnline,
      @JsonKey(name: 'room_type_id') final String? roomTypeId,
      @JsonKey(name: 'room_type') final RoomType? roomType}) = _$ChatRoomImpl;

  factory _ChatRoom.fromJson(Map<String, dynamic> json) =
      _$ChatRoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'participant_ids')
  List<String>? get participantIds;
  @override
  @JsonKey(name: 'last_message')
  String? get lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  DateTime? get lastMessageTime;
  @override
  @JsonKey(name: 'is_group')
  bool get isGroup;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override // Additional fields for UI
  List<ChatParticipant> get participants;
  @override
  @JsonKey(name: 'unread_count')
  int? get unreadCount;
  @override
  @JsonKey(name: 'is_online')
  bool? get isOnline;
  @override
  @JsonKey(name: 'room_type_id')
  String? get roomTypeId;
  @override
  @JsonKey(name: 'room_type')
  RoomType? get roomType;
  @override
  @JsonKey(ignore: true)
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) {
  return _ChatParticipant.fromJson(json);
}

/// @nodoc
mixin _$ChatParticipant {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_room_id')
  String get chatRoomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_at')
  DateTime? get lastReadAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_muted')
  bool get isMuted => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'left_at')
  DateTime? get leftAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  @JsonKey(name: 'is_online')
  bool? get isOnline => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatParticipantCopyWith<ChatParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatParticipantCopyWith<$Res> {
  factory $ChatParticipantCopyWith(
          ChatParticipant value, $Res Function(ChatParticipant) then) =
      _$ChatParticipantCopyWithImpl<$Res, ChatParticipant>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_room_id') String chatRoomId,
      @JsonKey(name: 'user_id') String userId,
      String? username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String role,
      @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
      @JsonKey(name: 'is_muted') bool isMuted,
      @JsonKey(name: 'joined_at') DateTime? joinedAt,
      @JsonKey(name: 'left_at') DateTime? leftAt,
      @JsonKey(name: 'is_online') bool? isOnline,
      String? status});
}

/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res, $Val extends ChatParticipant>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatRoomId = null,
    Object? userId = null,
    Object? username = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? lastReadAt = freezed,
    Object? isMuted = null,
    Object? joinedAt = freezed,
    Object? leftAt = freezed,
    Object? isOnline = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatRoomId: null == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leftAt: freezed == leftAt
          ? _value.leftAt
          : leftAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatParticipantImplCopyWith<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  factory _$$ChatParticipantImplCopyWith(_$ChatParticipantImpl value,
          $Res Function(_$ChatParticipantImpl) then) =
      __$$ChatParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_room_id') String chatRoomId,
      @JsonKey(name: 'user_id') String userId,
      String? username,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String role,
      @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
      @JsonKey(name: 'is_muted') bool isMuted,
      @JsonKey(name: 'joined_at') DateTime? joinedAt,
      @JsonKey(name: 'left_at') DateTime? leftAt,
      @JsonKey(name: 'is_online') bool? isOnline,
      String? status});
}

/// @nodoc
class __$$ChatParticipantImplCopyWithImpl<$Res>
    extends _$ChatParticipantCopyWithImpl<$Res, _$ChatParticipantImpl>
    implements _$$ChatParticipantImplCopyWith<$Res> {
  __$$ChatParticipantImplCopyWithImpl(
      _$ChatParticipantImpl _value, $Res Function(_$ChatParticipantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatRoomId = null,
    Object? userId = null,
    Object? username = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? lastReadAt = freezed,
    Object? isMuted = null,
    Object? joinedAt = freezed,
    Object? leftAt = freezed,
    Object? isOnline = freezed,
    Object? status = freezed,
  }) {
    return _then(_$ChatParticipantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatRoomId: null == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leftAt: freezed == leftAt
          ? _value.leftAt
          : leftAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatParticipantImpl implements _ChatParticipant {
  const _$ChatParticipantImpl(
      {required this.id,
      @JsonKey(name: 'chat_room_id') required this.chatRoomId,
      @JsonKey(name: 'user_id') required this.userId,
      this.username,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.role = 'member',
      @JsonKey(name: 'last_read_at') this.lastReadAt,
      @JsonKey(name: 'is_muted') this.isMuted = false,
      @JsonKey(name: 'joined_at') this.joinedAt,
      @JsonKey(name: 'left_at') this.leftAt,
      @JsonKey(name: 'is_online') this.isOnline,
      this.status});

  factory _$ChatParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatParticipantImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'chat_room_id')
  final String chatRoomId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String? username;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'last_read_at')
  final DateTime? lastReadAt;
  @override
  @JsonKey(name: 'is_muted')
  final bool isMuted;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  @override
  @JsonKey(name: 'left_at')
  final DateTime? leftAt;
// Additional fields for UI
  @override
  @JsonKey(name: 'is_online')
  final bool? isOnline;
  @override
  final String? status;

  @override
  String toString() {
    return 'ChatParticipant(id: $id, chatRoomId: $chatRoomId, userId: $userId, username: $username, avatarUrl: $avatarUrl, role: $role, lastReadAt: $lastReadAt, isMuted: $isMuted, joinedAt: $joinedAt, leftAt: $leftAt, isOnline: $isOnline, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatRoomId, chatRoomId) ||
                other.chatRoomId == chatRoomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.leftAt, leftAt) || other.leftAt == leftAt) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, chatRoomId, userId, username,
      avatarUrl, role, lastReadAt, isMuted, joinedAt, leftAt, isOnline, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      __$$ChatParticipantImplCopyWithImpl<_$ChatParticipantImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatParticipantImplToJson(
      this,
    );
  }
}

abstract class _ChatParticipant implements ChatParticipant {
  const factory _ChatParticipant(
      {required final String id,
      @JsonKey(name: 'chat_room_id') required final String chatRoomId,
      @JsonKey(name: 'user_id') required final String userId,
      final String? username,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final String role,
      @JsonKey(name: 'last_read_at') final DateTime? lastReadAt,
      @JsonKey(name: 'is_muted') final bool isMuted,
      @JsonKey(name: 'joined_at') final DateTime? joinedAt,
      @JsonKey(name: 'left_at') final DateTime? leftAt,
      @JsonKey(name: 'is_online') final bool? isOnline,
      final String? status}) = _$ChatParticipantImpl;

  factory _ChatParticipant.fromJson(Map<String, dynamic> json) =
      _$ChatParticipantImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'chat_room_id')
  String get chatRoomId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String? get username;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String get role;
  @override
  @JsonKey(name: 'last_read_at')
  DateTime? get lastReadAt;
  @override
  @JsonKey(name: 'is_muted')
  bool get isMuted;
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt;
  @override
  @JsonKey(name: 'left_at')
  DateTime? get leftAt;
  @override // Additional fields for UI
  @JsonKey(name: 'is_online')
  bool? get isOnline;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoomType _$RoomTypeFromJson(Map<String, dynamic> json) {
  return _RoomType.fromJson(json);
}

/// @nodoc
mixin _$RoomType {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomTypeCopyWith<RoomType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomTypeCopyWith<$Res> {
  factory $RoomTypeCopyWith(RoomType value, $Res Function(RoomType) then) =
      _$RoomTypeCopyWithImpl<$Res, RoomType>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$RoomTypeCopyWithImpl<$Res, $Val extends RoomType>
    implements $RoomTypeCopyWith<$Res> {
  _$RoomTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomTypeImplCopyWith<$Res>
    implements $RoomTypeCopyWith<$Res> {
  factory _$$RoomTypeImplCopyWith(
          _$RoomTypeImpl value, $Res Function(_$RoomTypeImpl) then) =
      __$$RoomTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$RoomTypeImplCopyWithImpl<$Res>
    extends _$RoomTypeCopyWithImpl<$Res, _$RoomTypeImpl>
    implements _$$RoomTypeImplCopyWith<$Res> {
  __$$RoomTypeImplCopyWithImpl(
      _$RoomTypeImpl _value, $Res Function(_$RoomTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$RoomTypeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomTypeImpl implements _RoomType {
  const _$RoomTypeImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$RoomTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RoomType(id: $id, name: $name, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomTypeImplCopyWith<_$RoomTypeImpl> get copyWith =>
      __$$RoomTypeImplCopyWithImpl<_$RoomTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomTypeImplToJson(
      this,
    );
  }
}

abstract class _RoomType implements RoomType {
  const factory _RoomType(
          {required final String id,
          required final String name,
          final String? description,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$RoomTypeImpl;

  factory _RoomType.fromJson(Map<String, dynamic> json) =
      _$RoomTypeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$RoomTypeImplCopyWith<_$RoomTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
