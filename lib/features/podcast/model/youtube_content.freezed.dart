// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'youtube_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

YoutubeContent _$YoutubeContentFromJson(Map<String, dynamic> json) {
  return _YoutubeContent.fromJson(json);
}

/// @nodoc
mixin _$YoutubeContent {
  String get id => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get maturityRating => throw _privateConstructorUsedError;
  String? get seasons => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  String? get sectionName => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  String? get youtubeUrl => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YoutubeContentCopyWith<YoutubeContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YoutubeContentCopyWith<$Res> {
  factory $YoutubeContentCopyWith(
          YoutubeContent value, $Res Function(YoutubeContent) then) =
      _$YoutubeContentCopyWithImpl<$Res, YoutubeContent>;
  @useResult
  $Res call(
      {String id,
      String videoId,
      String title,
      String? description,
      String? category,
      int? year,
      String? maturityRating,
      String? seasons,
      String contentType,
      String? sectionName,
      bool isFeatured,
      String? youtubeUrl,
      String? coverImage,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy});
}

/// @nodoc
class _$YoutubeContentCopyWithImpl<$Res, $Val extends YoutubeContent>
    implements $YoutubeContentCopyWith<$Res> {
  _$YoutubeContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? year = freezed,
    Object? maturityRating = freezed,
    Object? seasons = freezed,
    Object? contentType = null,
    Object? sectionName = freezed,
    Object? isFeatured = null,
    Object? youtubeUrl = freezed,
    Object? coverImage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      maturityRating: freezed == maturityRating
          ? _value.maturityRating
          : maturityRating // ignore: cast_nullable_to_non_nullable
              as String?,
      seasons: freezed == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      sectionName: freezed == sectionName
          ? _value.sectionName
          : sectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      youtubeUrl: freezed == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YoutubeContentImplCopyWith<$Res>
    implements $YoutubeContentCopyWith<$Res> {
  factory _$$YoutubeContentImplCopyWith(_$YoutubeContentImpl value,
          $Res Function(_$YoutubeContentImpl) then) =
      __$$YoutubeContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String videoId,
      String title,
      String? description,
      String? category,
      int? year,
      String? maturityRating,
      String? seasons,
      String contentType,
      String? sectionName,
      bool isFeatured,
      String? youtubeUrl,
      String? coverImage,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy});
}

/// @nodoc
class __$$YoutubeContentImplCopyWithImpl<$Res>
    extends _$YoutubeContentCopyWithImpl<$Res, _$YoutubeContentImpl>
    implements _$$YoutubeContentImplCopyWith<$Res> {
  __$$YoutubeContentImplCopyWithImpl(
      _$YoutubeContentImpl _value, $Res Function(_$YoutubeContentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? year = freezed,
    Object? maturityRating = freezed,
    Object? seasons = freezed,
    Object? contentType = null,
    Object? sectionName = freezed,
    Object? isFeatured = null,
    Object? youtubeUrl = freezed,
    Object? coverImage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$YoutubeContentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      maturityRating: freezed == maturityRating
          ? _value.maturityRating
          : maturityRating // ignore: cast_nullable_to_non_nullable
              as String?,
      seasons: freezed == seasons
          ? _value.seasons
          : seasons // ignore: cast_nullable_to_non_nullable
              as String?,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      sectionName: freezed == sectionName
          ? _value.sectionName
          : sectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      youtubeUrl: freezed == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YoutubeContentImpl extends _YoutubeContent {
  const _$YoutubeContentImpl(
      {required this.id,
      required this.videoId,
      required this.title,
      this.description,
      this.category,
      this.year,
      this.maturityRating,
      this.seasons,
      this.contentType = 'video',
      this.sectionName,
      this.isFeatured = false,
      this.youtubeUrl,
      this.coverImage,
      this.createdAt,
      this.updatedAt,
      this.createdBy})
      : super._();

  factory _$YoutubeContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$YoutubeContentImplFromJson(json);

  @override
  final String id;
  @override
  final String videoId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final int? year;
  @override
  final String? maturityRating;
  @override
  final String? seasons;
  @override
  @JsonKey()
  final String contentType;
  @override
  final String? sectionName;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  final String? youtubeUrl;
  @override
  final String? coverImage;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'YoutubeContent(id: $id, videoId: $videoId, title: $title, description: $description, category: $category, year: $year, maturityRating: $maturityRating, seasons: $seasons, contentType: $contentType, sectionName: $sectionName, isFeatured: $isFeatured, youtubeUrl: $youtubeUrl, coverImage: $coverImage, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YoutubeContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.maturityRating, maturityRating) ||
                other.maturityRating == maturityRating) &&
            (identical(other.seasons, seasons) || other.seasons == seasons) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.sectionName, sectionName) ||
                other.sectionName == sectionName) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.youtubeUrl, youtubeUrl) ||
                other.youtubeUrl == youtubeUrl) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      videoId,
      title,
      description,
      category,
      year,
      maturityRating,
      seasons,
      contentType,
      sectionName,
      isFeatured,
      youtubeUrl,
      coverImage,
      createdAt,
      updatedAt,
      createdBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YoutubeContentImplCopyWith<_$YoutubeContentImpl> get copyWith =>
      __$$YoutubeContentImplCopyWithImpl<_$YoutubeContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YoutubeContentImplToJson(
      this,
    );
  }
}

abstract class _YoutubeContent extends YoutubeContent {
  const factory _YoutubeContent(
      {required final String id,
      required final String videoId,
      required final String title,
      final String? description,
      final String? category,
      final int? year,
      final String? maturityRating,
      final String? seasons,
      final String contentType,
      final String? sectionName,
      final bool isFeatured,
      final String? youtubeUrl,
      final String? coverImage,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? createdBy}) = _$YoutubeContentImpl;
  const _YoutubeContent._() : super._();

  factory _YoutubeContent.fromJson(Map<String, dynamic> json) =
      _$YoutubeContentImpl.fromJson;

  @override
  String get id;
  @override
  String get videoId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get category;
  @override
  int? get year;
  @override
  String? get maturityRating;
  @override
  String? get seasons;
  @override
  String get contentType;
  @override
  String? get sectionName;
  @override
  bool get isFeatured;
  @override
  String? get youtubeUrl;
  @override
  String? get coverImage;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get createdBy;
  @override
  @JsonKey(ignore: true)
  _$$YoutubeContentImplCopyWith<_$YoutubeContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YoutubeContentSections _$YoutubeContentSectionsFromJson(
    Map<String, dynamic> json) {
  return _YoutubeContentSections.fromJson(json);
}

/// @nodoc
mixin _$YoutubeContentSections {
  List<YoutubeContent> get featured => throw _privateConstructorUsedError;
  List<YoutubeContent> get popular => throw _privateConstructorUsedError;
  List<YoutubeContent> get trending => throw _privateConstructorUsedError;
  List<YoutubeContent> get action => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YoutubeContentSectionsCopyWith<YoutubeContentSections> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YoutubeContentSectionsCopyWith<$Res> {
  factory $YoutubeContentSectionsCopyWith(YoutubeContentSections value,
          $Res Function(YoutubeContentSections) then) =
      _$YoutubeContentSectionsCopyWithImpl<$Res, YoutubeContentSections>;
  @useResult
  $Res call(
      {List<YoutubeContent> featured,
      List<YoutubeContent> popular,
      List<YoutubeContent> trending,
      List<YoutubeContent> action});
}

/// @nodoc
class _$YoutubeContentSectionsCopyWithImpl<$Res,
        $Val extends YoutubeContentSections>
    implements $YoutubeContentSectionsCopyWith<$Res> {
  _$YoutubeContentSectionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featured = null,
    Object? popular = null,
    Object? trending = null,
    Object? action = null,
  }) {
    return _then(_value.copyWith(
      featured: null == featured
          ? _value.featured
          : featured // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      popular: null == popular
          ? _value.popular
          : popular // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      trending: null == trending
          ? _value.trending
          : trending // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YoutubeContentSectionsImplCopyWith<$Res>
    implements $YoutubeContentSectionsCopyWith<$Res> {
  factory _$$YoutubeContentSectionsImplCopyWith(
          _$YoutubeContentSectionsImpl value,
          $Res Function(_$YoutubeContentSectionsImpl) then) =
      __$$YoutubeContentSectionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<YoutubeContent> featured,
      List<YoutubeContent> popular,
      List<YoutubeContent> trending,
      List<YoutubeContent> action});
}

/// @nodoc
class __$$YoutubeContentSectionsImplCopyWithImpl<$Res>
    extends _$YoutubeContentSectionsCopyWithImpl<$Res,
        _$YoutubeContentSectionsImpl>
    implements _$$YoutubeContentSectionsImplCopyWith<$Res> {
  __$$YoutubeContentSectionsImplCopyWithImpl(
      _$YoutubeContentSectionsImpl _value,
      $Res Function(_$YoutubeContentSectionsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featured = null,
    Object? popular = null,
    Object? trending = null,
    Object? action = null,
  }) {
    return _then(_$YoutubeContentSectionsImpl(
      featured: null == featured
          ? _value._featured
          : featured // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      popular: null == popular
          ? _value._popular
          : popular // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      trending: null == trending
          ? _value._trending
          : trending // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
      action: null == action
          ? _value._action
          : action // ignore: cast_nullable_to_non_nullable
              as List<YoutubeContent>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YoutubeContentSectionsImpl implements _YoutubeContentSections {
  const _$YoutubeContentSectionsImpl(
      {final List<YoutubeContent> featured = const [],
      final List<YoutubeContent> popular = const [],
      final List<YoutubeContent> trending = const [],
      final List<YoutubeContent> action = const []})
      : _featured = featured,
        _popular = popular,
        _trending = trending,
        _action = action;

  factory _$YoutubeContentSectionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$YoutubeContentSectionsImplFromJson(json);

  final List<YoutubeContent> _featured;
  @override
  @JsonKey()
  List<YoutubeContent> get featured {
    if (_featured is EqualUnmodifiableListView) return _featured;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featured);
  }

  final List<YoutubeContent> _popular;
  @override
  @JsonKey()
  List<YoutubeContent> get popular {
    if (_popular is EqualUnmodifiableListView) return _popular;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popular);
  }

  final List<YoutubeContent> _trending;
  @override
  @JsonKey()
  List<YoutubeContent> get trending {
    if (_trending is EqualUnmodifiableListView) return _trending;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trending);
  }

  final List<YoutubeContent> _action;
  @override
  @JsonKey()
  List<YoutubeContent> get action {
    if (_action is EqualUnmodifiableListView) return _action;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_action);
  }

  @override
  String toString() {
    return 'YoutubeContentSections(featured: $featured, popular: $popular, trending: $trending, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YoutubeContentSectionsImpl &&
            const DeepCollectionEquality().equals(other._featured, _featured) &&
            const DeepCollectionEquality().equals(other._popular, _popular) &&
            const DeepCollectionEquality().equals(other._trending, _trending) &&
            const DeepCollectionEquality().equals(other._action, _action));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_featured),
      const DeepCollectionEquality().hash(_popular),
      const DeepCollectionEquality().hash(_trending),
      const DeepCollectionEquality().hash(_action));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YoutubeContentSectionsImplCopyWith<_$YoutubeContentSectionsImpl>
      get copyWith => __$$YoutubeContentSectionsImplCopyWithImpl<
          _$YoutubeContentSectionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YoutubeContentSectionsImplToJson(
      this,
    );
  }
}

abstract class _YoutubeContentSections implements YoutubeContentSections {
  const factory _YoutubeContentSections(
      {final List<YoutubeContent> featured,
      final List<YoutubeContent> popular,
      final List<YoutubeContent> trending,
      final List<YoutubeContent> action}) = _$YoutubeContentSectionsImpl;

  factory _YoutubeContentSections.fromJson(Map<String, dynamic> json) =
      _$YoutubeContentSectionsImpl.fromJson;

  @override
  List<YoutubeContent> get featured;
  @override
  List<YoutubeContent> get popular;
  @override
  List<YoutubeContent> get trending;
  @override
  List<YoutubeContent> get action;
  @override
  @JsonKey(ignore: true)
  _$$YoutubeContentSectionsImplCopyWith<_$YoutubeContentSectionsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
