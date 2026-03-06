// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concierge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConciergeRequest _$ConciergeRequestFromJson(Map<String, dynamic> json) {
  return _ConciergeRequest.fromJson(json);
}

/// @nodoc
mixin _$ConciergeRequest {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_name')
  String get serviceName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  RequestStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_urgent')
  bool get isUrgent => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_at')
  DateTime? get requestedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'additional_details')
  Map<String, dynamic>? get additionalDetails =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_room_id')
  String? get chatRoomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConciergeRequestCopyWith<ConciergeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConciergeRequestCopyWith<$Res> {
  factory $ConciergeRequestCopyWith(
          ConciergeRequest value, $Res Function(ConciergeRequest) then) =
      _$ConciergeRequestCopyWithImpl<$Res, ConciergeRequest>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String category,
      @JsonKey(name: 'service_name') String serviceName,
      String description,
      RequestStatus status,
      @JsonKey(name: 'is_urgent') bool isUrgent,
      @JsonKey(name: 'requested_at') DateTime? requestedAt,
      @JsonKey(name: 'additional_details')
      Map<String, dynamic>? additionalDetails,
      @JsonKey(name: 'chat_room_id') String? chatRoomId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$ConciergeRequestCopyWithImpl<$Res, $Val extends ConciergeRequest>
    implements $ConciergeRequestCopyWith<$Res> {
  _$ConciergeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? serviceName = null,
    Object? description = null,
    Object? status = null,
    Object? isUrgent = null,
    Object? requestedAt = freezed,
    Object? additionalDetails = freezed,
    Object? chatRoomId = freezed,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RequestStatus,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      additionalDetails: freezed == additionalDetails
          ? _value.additionalDetails
          : additionalDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      chatRoomId: freezed == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$ConciergeRequestImplCopyWith<$Res>
    implements $ConciergeRequestCopyWith<$Res> {
  factory _$$ConciergeRequestImplCopyWith(_$ConciergeRequestImpl value,
          $Res Function(_$ConciergeRequestImpl) then) =
      __$$ConciergeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String category,
      @JsonKey(name: 'service_name') String serviceName,
      String description,
      RequestStatus status,
      @JsonKey(name: 'is_urgent') bool isUrgent,
      @JsonKey(name: 'requested_at') DateTime? requestedAt,
      @JsonKey(name: 'additional_details')
      Map<String, dynamic>? additionalDetails,
      @JsonKey(name: 'chat_room_id') String? chatRoomId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$ConciergeRequestImplCopyWithImpl<$Res>
    extends _$ConciergeRequestCopyWithImpl<$Res, _$ConciergeRequestImpl>
    implements _$$ConciergeRequestImplCopyWith<$Res> {
  __$$ConciergeRequestImplCopyWithImpl(_$ConciergeRequestImpl _value,
      $Res Function(_$ConciergeRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? serviceName = null,
    Object? description = null,
    Object? status = null,
    Object? isUrgent = null,
    Object? requestedAt = freezed,
    Object? additionalDetails = freezed,
    Object? chatRoomId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ConciergeRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RequestStatus,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      additionalDetails: freezed == additionalDetails
          ? _value._additionalDetails
          : additionalDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      chatRoomId: freezed == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$ConciergeRequestImpl implements _ConciergeRequest {
  const _$ConciergeRequestImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.category,
      @JsonKey(name: 'service_name') required this.serviceName,
      required this.description,
      this.status = RequestStatus.pending,
      @JsonKey(name: 'is_urgent') this.isUrgent = false,
      @JsonKey(name: 'requested_at') this.requestedAt,
      @JsonKey(name: 'additional_details')
      final Map<String, dynamic>? additionalDetails,
      @JsonKey(name: 'chat_room_id') this.chatRoomId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _additionalDetails = additionalDetails;

  factory _$ConciergeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConciergeRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String category;
  @override
  @JsonKey(name: 'service_name')
  final String serviceName;
  @override
  final String description;
  @override
  @JsonKey()
  final RequestStatus status;
  @override
  @JsonKey(name: 'is_urgent')
  final bool isUrgent;
  @override
  @JsonKey(name: 'requested_at')
  final DateTime? requestedAt;
  final Map<String, dynamic>? _additionalDetails;
  @override
  @JsonKey(name: 'additional_details')
  Map<String, dynamic>? get additionalDetails {
    final value = _additionalDetails;
    if (value == null) return null;
    if (_additionalDetails is EqualUnmodifiableMapView)
      return _additionalDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'chat_room_id')
  final String? chatRoomId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ConciergeRequest(id: $id, userId: $userId, category: $category, serviceName: $serviceName, description: $description, status: $status, isUrgent: $isUrgent, requestedAt: $requestedAt, additionalDetails: $additionalDetails, chatRoomId: $chatRoomId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConciergeRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isUrgent, isUrgent) ||
                other.isUrgent == isUrgent) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            const DeepCollectionEquality()
                .equals(other._additionalDetails, _additionalDetails) &&
            (identical(other.chatRoomId, chatRoomId) ||
                other.chatRoomId == chatRoomId) &&
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
      userId,
      category,
      serviceName,
      description,
      status,
      isUrgent,
      requestedAt,
      const DeepCollectionEquality().hash(_additionalDetails),
      chatRoomId,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConciergeRequestImplCopyWith<_$ConciergeRequestImpl> get copyWith =>
      __$$ConciergeRequestImplCopyWithImpl<_$ConciergeRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConciergeRequestImplToJson(
      this,
    );
  }
}

abstract class _ConciergeRequest implements ConciergeRequest {
  const factory _ConciergeRequest(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String category,
          @JsonKey(name: 'service_name') required final String serviceName,
          required final String description,
          final RequestStatus status,
          @JsonKey(name: 'is_urgent') final bool isUrgent,
          @JsonKey(name: 'requested_at') final DateTime? requestedAt,
          @JsonKey(name: 'additional_details')
          final Map<String, dynamic>? additionalDetails,
          @JsonKey(name: 'chat_room_id') final String? chatRoomId,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$ConciergeRequestImpl;

  factory _ConciergeRequest.fromJson(Map<String, dynamic> json) =
      _$ConciergeRequestImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get category;
  @override
  @JsonKey(name: 'service_name')
  String get serviceName;
  @override
  String get description;
  @override
  RequestStatus get status;
  @override
  @JsonKey(name: 'is_urgent')
  bool get isUrgent;
  @override
  @JsonKey(name: 'requested_at')
  DateTime? get requestedAt;
  @override
  @JsonKey(name: 'additional_details')
  Map<String, dynamic>? get additionalDetails;
  @override
  @JsonKey(name: 'chat_room_id')
  String? get chatRoomId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ConciergeRequestImplCopyWith<_$ConciergeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
