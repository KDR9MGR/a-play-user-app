// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedModel _$FeedModelFromJson(Map<String, dynamic> json) {
  return _FeedModel.fromJson(json);
}

/// @nodoc
mixin _$FeedModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_count')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_id')
  String? get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool get isLiked => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedModelCopyWith<FeedModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedModelCopyWith<$Res> {
  factory $FeedModelCopyWith(FeedModel value, $Res Function(FeedModel) then) =
      _$FeedModelCopyWithImpl<$Res, FeedModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'like_count') int likeCount,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'event_id') String? eventId,
      @JsonKey(name: 'is_liked') bool isLiked,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$FeedModelCopyWithImpl<$Res, $Val extends FeedModel>
    implements $FeedModelCopyWith<$Res> {
  _$FeedModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? eventId = freezed,
    Object? isLiked = null,
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
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedModelImplCopyWith<$Res>
    implements $FeedModelCopyWith<$Res> {
  factory _$$FeedModelImplCopyWith(
          _$FeedModelImpl value, $Res Function(_$FeedModelImpl) then) =
      __$$FeedModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'like_count') int likeCount,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'event_id') String? eventId,
      @JsonKey(name: 'is_liked') bool isLiked,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$FeedModelImplCopyWithImpl<$Res>
    extends _$FeedModelCopyWithImpl<$Res, _$FeedModelImpl>
    implements _$$FeedModelImplCopyWith<$Res> {
  __$$FeedModelImplCopyWithImpl(
      _$FeedModelImpl _value, $Res Function(_$FeedModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? eventId = freezed,
    Object? isLiked = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FeedModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedModelImpl extends _FeedModel with DiagnosticableTreeMixin {
  const _$FeedModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.content,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'like_count') this.likeCount = 0,
      @JsonKey(name: 'comment_count') this.commentCount = 0,
      @JsonKey(name: 'event_id') this.eventId,
      @JsonKey(name: 'is_liked') this.isLiked = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : super._();

  factory _$FeedModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String content;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'like_count')
  final int likeCount;
  @override
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @override
  @JsonKey(name: 'event_id')
  final String? eventId;
  @override
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedModel(id: $id, userId: $userId, content: $content, imageUrl: $imageUrl, likeCount: $likeCount, commentCount: $commentCount, eventId: $eventId, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('eventId', eventId))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, content, imageUrl,
      likeCount, commentCount, eventId, isLiked, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedModelImplCopyWith<_$FeedModelImpl> get copyWith =>
      __$$FeedModelImplCopyWithImpl<_$FeedModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedModelImplToJson(
      this,
    );
  }
}

abstract class _FeedModel extends FeedModel {
  const factory _FeedModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String content,
          @JsonKey(name: 'image_url') final String? imageUrl,
          @JsonKey(name: 'like_count') final int likeCount,
          @JsonKey(name: 'comment_count') final int commentCount,
          @JsonKey(name: 'event_id') final String? eventId,
          @JsonKey(name: 'is_liked') final bool isLiked,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$FeedModelImpl;
  const _FeedModel._() : super._();

  factory _FeedModel.fromJson(Map<String, dynamic> json) =
      _$FeedModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get content;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'like_count')
  int get likeCount;
  @override
  @JsonKey(name: 'comment_count')
  int get commentCount;
  @override
  @JsonKey(name: 'event_id')
  String? get eventId;
  @override
  @JsonKey(name: 'is_liked')
  bool get isLiked;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FeedModelImplCopyWith<_$FeedModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedComment _$FeedCommentFromJson(Map<String, dynamic> json) {
  return _FeedComment.fromJson(json);
}

/// @nodoc
mixin _$FeedComment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'feed_id')
  String get feedId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedCommentCopyWith<FeedComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedCommentCopyWith<$Res> {
  factory $FeedCommentCopyWith(
          FeedComment value, $Res Function(FeedComment) then) =
      _$FeedCommentCopyWithImpl<$Res, FeedComment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$FeedCommentCopyWithImpl<$Res, $Val extends FeedComment>
    implements $FeedCommentCopyWith<$Res> {
  _$FeedCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$FeedCommentImplCopyWith<$Res>
    implements $FeedCommentCopyWith<$Res> {
  factory _$$FeedCommentImplCopyWith(
          _$FeedCommentImpl value, $Res Function(_$FeedCommentImpl) then) =
      __$$FeedCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$FeedCommentImplCopyWithImpl<$Res>
    extends _$FeedCommentCopyWithImpl<$Res, _$FeedCommentImpl>
    implements _$$FeedCommentImplCopyWith<$Res> {
  __$$FeedCommentImplCopyWithImpl(
      _$FeedCommentImpl _value, $Res Function(_$FeedCommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$FeedCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$FeedCommentImpl extends _FeedComment with DiagnosticableTreeMixin {
  const _$FeedCommentImpl(
      {required this.id,
      @JsonKey(name: 'feed_id') required this.feedId,
      @JsonKey(name: 'user_id') required this.userId,
      required this.content,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$FeedCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedCommentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'feed_id')
  final String feedId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String content;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedComment(id: $id, feedId: $feedId, userId: $userId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedComment'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('feedId', feedId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, feedId, userId, content, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedCommentImplCopyWith<_$FeedCommentImpl> get copyWith =>
      __$$FeedCommentImplCopyWithImpl<_$FeedCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedCommentImplToJson(
      this,
    );
  }
}

abstract class _FeedComment extends FeedComment {
  const factory _FeedComment(
          {required final String id,
          @JsonKey(name: 'feed_id') required final String feedId,
          @JsonKey(name: 'user_id') required final String userId,
          required final String content,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$FeedCommentImpl;
  const _FeedComment._() : super._();

  factory _FeedComment.fromJson(Map<String, dynamic> json) =
      _$FeedCommentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'feed_id')
  String get feedId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get content;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FeedCommentImplCopyWith<_$FeedCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedLike _$FeedLikeFromJson(Map<String, dynamic> json) {
  return _FeedLike.fromJson(json);
}

/// @nodoc
mixin _$FeedLike {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'feed_id')
  String get feedId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedLikeCopyWith<FeedLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedLikeCopyWith<$Res> {
  factory $FeedLikeCopyWith(FeedLike value, $Res Function(FeedLike) then) =
      _$FeedLikeCopyWithImpl<$Res, FeedLike>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$FeedLikeCopyWithImpl<$Res, $Val extends FeedLike>
    implements $FeedLikeCopyWith<$Res> {
  _$FeedLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedLikeImplCopyWith<$Res>
    implements $FeedLikeCopyWith<$Res> {
  factory _$$FeedLikeImplCopyWith(
          _$FeedLikeImpl value, $Res Function(_$FeedLikeImpl) then) =
      __$$FeedLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'feed_id') String feedId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$FeedLikeImplCopyWithImpl<$Res>
    extends _$FeedLikeCopyWithImpl<$Res, _$FeedLikeImpl>
    implements _$$FeedLikeImplCopyWith<$Res> {
  __$$FeedLikeImplCopyWithImpl(
      _$FeedLikeImpl _value, $Res Function(_$FeedLikeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(_$FeedLikeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _value.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
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
class _$FeedLikeImpl extends _FeedLike with DiagnosticableTreeMixin {
  const _$FeedLikeImpl(
      {required this.id,
      @JsonKey(name: 'feed_id') required this.feedId,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'created_at') required this.createdAt})
      : super._();

  factory _$FeedLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedLikeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'feed_id')
  final String feedId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedLike(id: $id, feedId: $feedId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedLike'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('feedId', feedId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedLikeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, feedId, userId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedLikeImplCopyWith<_$FeedLikeImpl> get copyWith =>
      __$$FeedLikeImplCopyWithImpl<_$FeedLikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedLikeImplToJson(
      this,
    );
  }
}

abstract class _FeedLike extends FeedLike {
  const factory _FeedLike(
          {required final String id,
          @JsonKey(name: 'feed_id') required final String feedId,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$FeedLikeImpl;
  const _FeedLike._() : super._();

  factory _FeedLike.fromJson(Map<String, dynamic> json) =
      _$FeedLikeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'feed_id')
  String get feedId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$FeedLikeImplCopyWith<_$FeedLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
