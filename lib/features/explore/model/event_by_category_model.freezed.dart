// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_by_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventByCategoryModel _$EventByCategoryModelFromJson(Map<String, dynamic> json) {
  return _EventByCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$EventByCategoryModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String get coverImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'club_id')
  String get clubId => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name')
  String get categoryName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventByCategoryModelCopyWith<EventByCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventByCategoryModelCopyWith<$Res> {
  factory $EventByCategoryModelCopyWith(EventByCategoryModel value,
          $Res Function(EventByCategoryModel) then) =
      _$EventByCategoryModelCopyWithImpl<$Res, EventByCategoryModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      @JsonKey(name: 'club_id') String clubId,
      String location,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'category_name') String categoryName});
}

/// @nodoc
class _$EventByCategoryModelCopyWithImpl<$Res,
        $Val extends EventByCategoryModel>
    implements $EventByCategoryModelCopyWith<$Res> {
  _$EventByCategoryModelCopyWithImpl(this._value, this._then);

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
    Object? coverImage = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? clubId = null,
    Object? location = null,
    Object? createdAt = null,
    Object? categoryName = null,
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
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventByCategoryModelImplCopyWith<$Res>
    implements $EventByCategoryModelCopyWith<$Res> {
  factory _$$EventByCategoryModelImplCopyWith(_$EventByCategoryModelImpl value,
          $Res Function(_$EventByCategoryModelImpl) then) =
      __$$EventByCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'cover_image') String coverImage,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      @JsonKey(name: 'club_id') String clubId,
      String location,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'category_name') String categoryName});
}

/// @nodoc
class __$$EventByCategoryModelImplCopyWithImpl<$Res>
    extends _$EventByCategoryModelCopyWithImpl<$Res, _$EventByCategoryModelImpl>
    implements _$$EventByCategoryModelImplCopyWith<$Res> {
  __$$EventByCategoryModelImplCopyWithImpl(_$EventByCategoryModelImpl _value,
      $Res Function(_$EventByCategoryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? coverImage = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? clubId = null,
    Object? location = null,
    Object? createdAt = null,
    Object? categoryName = null,
  }) {
    return _then(_$EventByCategoryModelImpl(
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
      coverImage: null == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clubId: null == clubId
          ? _value.clubId
          : clubId // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventByCategoryModelImpl implements _EventByCategoryModel {
  const _$EventByCategoryModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      @JsonKey(name: 'cover_image') required this.coverImage,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'club_id') required this.clubId,
      required this.location,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'category_name') required this.categoryName});

  factory _$EventByCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventByCategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'cover_image')
  final String coverImage;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @override
  @JsonKey(name: 'club_id')
  final String clubId;
  @override
  final String location;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'category_name')
  final String categoryName;

  @override
  String toString() {
    return 'EventByCategoryModel(id: $id, title: $title, description: $description, coverImage: $coverImage, startDate: $startDate, endDate: $endDate, clubId: $clubId, location: $location, createdAt: $createdAt, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventByCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.clubId, clubId) || other.clubId == clubId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      coverImage,
      startDate,
      endDate,
      clubId,
      location,
      createdAt,
      categoryName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventByCategoryModelImplCopyWith<_$EventByCategoryModelImpl>
      get copyWith =>
          __$$EventByCategoryModelImplCopyWithImpl<_$EventByCategoryModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventByCategoryModelImplToJson(
      this,
    );
  }
}

abstract class _EventByCategoryModel implements EventByCategoryModel {
  const factory _EventByCategoryModel(
          {required final String id,
          required final String title,
          required final String description,
          @JsonKey(name: 'cover_image') required final String coverImage,
          @JsonKey(name: 'start_date') required final DateTime startDate,
          @JsonKey(name: 'end_date') required final DateTime endDate,
          @JsonKey(name: 'club_id') required final String clubId,
          required final String location,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'category_name') required final String categoryName}) =
      _$EventByCategoryModelImpl;

  factory _EventByCategoryModel.fromJson(Map<String, dynamic> json) =
      _$EventByCategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'cover_image')
  String get coverImage;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  @JsonKey(name: 'club_id')
  String get clubId;
  @override
  String get location;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'category_name')
  String get categoryName;
  @override
  @JsonKey(ignore: true)
  _$$EventByCategoryModelImplCopyWith<_$EventByCategoryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
