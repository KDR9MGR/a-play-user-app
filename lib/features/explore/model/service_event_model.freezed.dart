// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceEventModel _$ServiceEventModelFromJson(Map<String, dynamic> json) {
  return _ServiceEventModel.fromJson(json);
}

/// @nodoc
mixin _$ServiceEventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String get coverImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_id')
  String? get clubId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name')
  String? get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServiceEventModelCopyWith<ServiceEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceEventModelCopyWith<$Res> {
  factory $ServiceEventModelCopyWith(
          ServiceEventModel value, $Res Function(ServiceEventModel) then) =
      _$ServiceEventModelCopyWithImpl<$Res, ServiceEventModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String location,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'club_id') String? clubId,
      @JsonKey(name: 'category_name') String? category});
}

/// @nodoc
class _$ServiceEventModelCopyWithImpl<$Res, $Val extends ServiceEventModel>
    implements $ServiceEventModelCopyWith<$Res> {
  _$ServiceEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? location = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? coverImage = null,
    Object? createdAt = null,
    Object? clubId = freezed,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: freezed == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceEventModelImplCopyWith<$Res>
    implements $ServiceEventModelCopyWith<$Res> {
  factory _$$ServiceEventModelImplCopyWith(_$ServiceEventModelImpl value,
          $Res Function(_$ServiceEventModelImpl) then) =
      __$$ServiceEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String location,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'club_id') String? clubId,
      @JsonKey(name: 'category_name') String? category});
}

/// @nodoc
class __$$ServiceEventModelImplCopyWithImpl<$Res>
    extends _$ServiceEventModelCopyWithImpl<$Res, _$ServiceEventModelImpl>
    implements _$$ServiceEventModelImplCopyWith<$Res> {
  __$$ServiceEventModelImplCopyWithImpl(_$ServiceEventModelImpl _value,
      $Res Function(_$ServiceEventModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? location = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? coverImage = null,
    Object? createdAt = null,
    Object? clubId = freezed,
    Object? category = freezed,
  }) {
    return _then(_$ServiceEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      clubId: freezed == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceEventModelImpl implements _ServiceEventModel {
  const _$ServiceEventModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.location,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'cover_image') required this.coverImage,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'club_id') this.clubId,
      @JsonKey(name: 'category_name') this.category});

  factory _$ServiceEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String location;
  @override
  @JsonKey(name: 'start_date')
  final String startDate;
  @override
  @JsonKey(name: 'end_date')
  final String endDate;
  @override
  @JsonKey(name: 'cover_image')
  final String coverImage;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'club_id')
  final String? clubId;
  @override
  @JsonKey(name: 'category_name')
  final String? category;

  @override
  String toString() {
    return 'ServiceEventModel(id: $id, title: $title, description: $description, location: $location, startDate: $startDate, endDate: $endDate, coverImage: $coverImage, createdAt: $createdAt, clubId: $clubId, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.clubId, clubId) || other.clubId == clubId) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, location,
      startDate, endDate, coverImage, createdAt, clubId, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceEventModelImplCopyWith<_$ServiceEventModelImpl> get copyWith =>
      __$$ServiceEventModelImplCopyWithImpl<_$ServiceEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceEventModelImplToJson(
      this,
    );
  }
}

abstract class _ServiceEventModel implements ServiceEventModel {
  const factory _ServiceEventModel(
          {required final String id,
          required final String title,
          required final String description,
          required final String location,
          @JsonKey(name: 'start_date') required final String startDate,
          @JsonKey(name: 'end_date') required final String endDate,
          @JsonKey(name: 'cover_image') required final String coverImage,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'club_id') final String? clubId,
          @JsonKey(name: 'category_name') final String? category}) =
      _$ServiceEventModelImpl;

  factory _ServiceEventModel.fromJson(Map<String, dynamic> json) =
      _$ServiceEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get location;
  @override
  @JsonKey(name: 'start_date')
  String get startDate;
  @override
  @JsonKey(name: 'end_date')
  String get endDate;
  @override
  @JsonKey(name: 'cover_image')
  String get coverImage;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'club_id')
  String? get clubId;
  @override
  @JsonKey(name: 'category_name')
  String? get category;
  @override
  @JsonKey(ignore: true)
  _$$ServiceEventModelImplCopyWith<_$ServiceEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
