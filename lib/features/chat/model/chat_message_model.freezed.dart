// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String? get receiverId => throw _privateConstructorUsedError;
  String get messageType => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  String? get replyTo => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderAvatarUrl => throw _privateConstructorUsedError;
  List<MessageReaction> get reactions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      String content,
      String senderId,
      String roomId,
      String? receiverId,
      String messageType,
      String? attachmentUrl,
      String? replyTo,
      bool isEdited,
      DateTime createdAt,
      DateTime updatedAt,
      String? senderName,
      String? senderAvatarUrl,
      List<MessageReaction> reactions});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? senderId = null,
    Object? roomId = null,
    Object? receiverId = freezed,
    Object? messageType = null,
    Object? attachmentUrl = freezed,
    Object? replyTo = freezed,
    Object? isEdited = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? senderName = freezed,
    Object? senderAvatarUrl = freezed,
    Object? reactions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: freezed == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatarUrl: freezed == senderAvatarUrl
          ? _value.senderAvatarUrl
          : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<MessageReaction>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      String senderId,
      String roomId,
      String? receiverId,
      String messageType,
      String? attachmentUrl,
      String? replyTo,
      bool isEdited,
      DateTime createdAt,
      DateTime updatedAt,
      String? senderName,
      String? senderAvatarUrl,
      List<MessageReaction> reactions});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? senderId = null,
    Object? roomId = null,
    Object? receiverId = freezed,
    Object? messageType = null,
    Object? attachmentUrl = freezed,
    Object? replyTo = freezed,
    Object? isEdited = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? senderName = freezed,
    Object? senderAvatarUrl = freezed,
    Object? reactions = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: freezed == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatarUrl: freezed == senderAvatarUrl
          ? _value.senderAvatarUrl
          : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<MessageReaction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.content,
      required this.senderId,
      required this.roomId,
      this.receiverId,
      this.messageType = 'text',
      this.attachmentUrl,
      this.replyTo,
      this.isEdited = false,
      required this.createdAt,
      required this.updatedAt,
      this.senderName,
      this.senderAvatarUrl,
      final List<MessageReaction> reactions = const []})
      : _reactions = reactions;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String senderId;
  @override
  final String roomId;
  @override
  final String? receiverId;
  @override
  @JsonKey()
  final String messageType;
  @override
  final String? attachmentUrl;
  @override
  final String? replyTo;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// Additional fields for UI
  @override
  final String? senderName;
  @override
  final String? senderAvatarUrl;
  final List<MessageReaction> _reactions;
  @override
  @JsonKey()
  List<MessageReaction> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, senderId: $senderId, roomId: $roomId, receiverId: $receiverId, messageType: $messageType, attachmentUrl: $attachmentUrl, replyTo: $replyTo, isEdited: $isEdited, createdAt: $createdAt, updatedAt: $updatedAt, senderName: $senderName, senderAvatarUrl: $senderAvatarUrl, reactions: $reactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatarUrl, senderAvatarUrl) ||
                other.senderAvatarUrl == senderAvatarUrl) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      senderId,
      roomId,
      receiverId,
      messageType,
      attachmentUrl,
      replyTo,
      isEdited,
      createdAt,
      updatedAt,
      senderName,
      senderAvatarUrl,
      const DeepCollectionEquality().hash(_reactions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String id,
      required final String content,
      required final String senderId,
      required final String roomId,
      final String? receiverId,
      final String messageType,
      final String? attachmentUrl,
      final String? replyTo,
      final bool isEdited,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? senderName,
      final String? senderAvatarUrl,
      final List<MessageReaction> reactions}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String get senderId;
  @override
  String get roomId;
  @override
  String? get receiverId;
  @override
  String get messageType;
  @override
  String? get attachmentUrl;
  @override
  String? get replyTo;
  @override
  bool get isEdited;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override // Additional fields for UI
  String? get senderName;
  @override
  String? get senderAvatarUrl;
  @override
  List<MessageReaction> get reactions;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) {
  return _MessageReaction.fromJson(json);
}

/// @nodoc
mixin _$MessageReaction {
  String get id => throw _privateConstructorUsedError;
  String get messageId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Additional fields for UI
  String? get userName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageReactionCopyWith<MessageReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReactionCopyWith<$Res> {
  factory $MessageReactionCopyWith(
          MessageReaction value, $Res Function(MessageReaction) then) =
      _$MessageReactionCopyWithImpl<$Res, MessageReaction>;
  @useResult
  $Res call(
      {String id,
      String messageId,
      String userId,
      String emoji,
      DateTime createdAt,
      String? userName});
}

/// @nodoc
class _$MessageReactionCopyWithImpl<$Res, $Val extends MessageReaction>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? userId = null,
    Object? emoji = null,
    Object? createdAt = null,
    Object? userName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageReactionImplCopyWith<$Res>
    implements $MessageReactionCopyWith<$Res> {
  factory _$$MessageReactionImplCopyWith(_$MessageReactionImpl value,
          $Res Function(_$MessageReactionImpl) then) =
      __$$MessageReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageId,
      String userId,
      String emoji,
      DateTime createdAt,
      String? userName});
}

/// @nodoc
class __$$MessageReactionImplCopyWithImpl<$Res>
    extends _$MessageReactionCopyWithImpl<$Res, _$MessageReactionImpl>
    implements _$$MessageReactionImplCopyWith<$Res> {
  __$$MessageReactionImplCopyWithImpl(
      _$MessageReactionImpl _value, $Res Function(_$MessageReactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? userId = null,
    Object? emoji = null,
    Object? createdAt = null,
    Object? userName = freezed,
  }) {
    return _then(_$MessageReactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageReactionImpl implements _MessageReaction {
  const _$MessageReactionImpl(
      {required this.id,
      required this.messageId,
      required this.userId,
      required this.emoji,
      required this.createdAt,
      this.userName});

  factory _$MessageReactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReactionImplFromJson(json);

  @override
  final String id;
  @override
  final String messageId;
  @override
  final String userId;
  @override
  final String emoji;
  @override
  final DateTime createdAt;
// Additional fields for UI
  @override
  final String? userName;

  @override
  String toString() {
    return 'MessageReaction(id: $id, messageId: $messageId, userId: $userId, emoji: $emoji, createdAt: $createdAt, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, messageId, userId, emoji, createdAt, userName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      __$$MessageReactionImplCopyWithImpl<_$MessageReactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReactionImplToJson(
      this,
    );
  }
}

abstract class _MessageReaction implements MessageReaction {
  const factory _MessageReaction(
      {required final String id,
      required final String messageId,
      required final String userId,
      required final String emoji,
      required final DateTime createdAt,
      final String? userName}) = _$MessageReactionImpl;

  factory _MessageReaction.fromJson(Map<String, dynamic> json) =
      _$MessageReactionImpl.fromJson;

  @override
  String get id;
  @override
  String get messageId;
  @override
  String get userId;
  @override
  String get emoji;
  @override
  DateTime get createdAt;
  @override // Additional fields for UI
  String? get userName;
  @override
  @JsonKey(ignore: true)
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
