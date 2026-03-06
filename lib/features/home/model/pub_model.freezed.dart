// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pub_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Pub _$PubFromJson(Map<String, dynamic> json) {
  return _Pub.fromJson(json);
}

/// @nodoc
mixin _$Pub {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'website_url')
  String? get websiteUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'operating_hours')
  Map<String, dynamic>? get operatingHours =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_range')
  int get priceRange => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_sports_viewing')
  bool get hasSportsViewing => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_live_music')
  bool get hasLiveMusic => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PubCopyWith<Pub> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PubCopyWith<$Res> {
  factory $PubCopyWith(Pub value, $Res Function(Pub) then) =
      _$PubCopyWithImpl<$Res, Pub>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      String address,
      String? phone,
      String? email,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'price_range') int priceRange,
      @JsonKey(name: 'has_sports_viewing') bool hasSportsViewing,
      @JsonKey(name: 'has_live_music') bool hasLiveMusic,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$PubCopyWithImpl<$Res, $Val extends Pub> implements $PubCopyWith<$Res> {
  _$PubCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? websiteUrl = freezed,
    Object? operatingHours = freezed,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? priceRange = null,
    Object? hasSportsViewing = null,
    Object? hasLiveMusic = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingHours: freezed == operatingHours
          ? _value.operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      priceRange: null == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int,
      hasSportsViewing: null == hasSportsViewing
          ? _value.hasSportsViewing
          : hasSportsViewing // ignore: cast_nullable_to_non_nullable
              as bool,
      hasLiveMusic: null == hasLiveMusic
          ? _value.hasLiveMusic
          : hasLiveMusic // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$PubImplCopyWith<$Res> implements $PubCopyWith<$Res> {
  factory _$$PubImplCopyWith(_$PubImpl value, $Res Function(_$PubImpl) then) =
      __$$PubImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      String address,
      String? phone,
      String? email,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'price_range') int priceRange,
      @JsonKey(name: 'has_sports_viewing') bool hasSportsViewing,
      @JsonKey(name: 'has_live_music') bool hasLiveMusic,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$PubImplCopyWithImpl<$Res> extends _$PubCopyWithImpl<$Res, _$PubImpl>
    implements _$$PubImplCopyWith<$Res> {
  __$$PubImplCopyWithImpl(_$PubImpl _value, $Res Function(_$PubImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? websiteUrl = freezed,
    Object? operatingHours = freezed,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? priceRange = null,
    Object? hasSportsViewing = null,
    Object? hasLiveMusic = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PubImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingHours: freezed == operatingHours
          ? _value._operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      priceRange: null == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as int,
      hasSportsViewing: null == hasSportsViewing
          ? _value.hasSportsViewing
          : hasSportsViewing // ignore: cast_nullable_to_non_nullable
              as bool,
      hasLiveMusic: null == hasLiveMusic
          ? _value.hasLiveMusic
          : hasLiveMusic // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$PubImpl implements _Pub {
  const _$PubImpl(
      {required this.id,
      required this.name,
      required this.description,
      @JsonKey(name: 'logo_url') this.logoUrl,
      @JsonKey(name: 'cover_image_url') this.coverImageUrl,
      this.address = '',
      this.phone,
      this.email,
      @JsonKey(name: 'website_url') this.websiteUrl,
      @JsonKey(name: 'operating_hours')
      final Map<String, dynamic>? operatingHours,
      @JsonKey(name: 'average_rating') this.averageRating = 0.0,
      @JsonKey(name: 'total_reviews') this.totalReviews = 0,
      @JsonKey(name: 'price_range') this.priceRange = 2,
      @JsonKey(name: 'has_sports_viewing') this.hasSportsViewing = true,
      @JsonKey(name: 'has_live_music') this.hasLiveMusic = false,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'is_featured') this.isFeatured = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _operatingHours = operatingHours;

  factory _$PubImpl.fromJson(Map<String, dynamic> json) =>
      _$$PubImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @override
  @JsonKey()
  final String address;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  final Map<String, dynamic>? _operatingHours;
  @override
  @JsonKey(name: 'operating_hours')
  Map<String, dynamic>? get operatingHours {
    final value = _operatingHours;
    if (value == null) return null;
    if (_operatingHours is EqualUnmodifiableMapView) return _operatingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @override
  @JsonKey(name: 'price_range')
  final int priceRange;
  @override
  @JsonKey(name: 'has_sports_viewing')
  final bool hasSportsViewing;
  @override
  @JsonKey(name: 'has_live_music')
  final bool hasLiveMusic;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'Pub(id: $id, name: $name, description: $description, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, address: $address, phone: $phone, email: $email, websiteUrl: $websiteUrl, operatingHours: $operatingHours, averageRating: $averageRating, totalReviews: $totalReviews, priceRange: $priceRange, hasSportsViewing: $hasSportsViewing, hasLiveMusic: $hasLiveMusic, isActive: $isActive, isFeatured: $isFeatured, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PubImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            const DeepCollectionEquality()
                .equals(other._operatingHours, _operatingHours) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.hasSportsViewing, hasSportsViewing) ||
                other.hasSportsViewing == hasSportsViewing) &&
            (identical(other.hasLiveMusic, hasLiveMusic) ||
                other.hasLiveMusic == hasLiveMusic) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        logoUrl,
        coverImageUrl,
        address,
        phone,
        email,
        websiteUrl,
        const DeepCollectionEquality().hash(_operatingHours),
        averageRating,
        totalReviews,
        priceRange,
        hasSportsViewing,
        hasLiveMusic,
        isActive,
        isFeatured,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PubImplCopyWith<_$PubImpl> get copyWith =>
      __$$PubImplCopyWithImpl<_$PubImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PubImplToJson(
      this,
    );
  }
}

abstract class _Pub implements Pub {
  const factory _Pub(
          {required final String id,
          required final String name,
          required final String description,
          @JsonKey(name: 'logo_url') final String? logoUrl,
          @JsonKey(name: 'cover_image_url') final String? coverImageUrl,
          final String address,
          final String? phone,
          final String? email,
          @JsonKey(name: 'website_url') final String? websiteUrl,
          @JsonKey(name: 'operating_hours')
          final Map<String, dynamic>? operatingHours,
          @JsonKey(name: 'average_rating') final double averageRating,
          @JsonKey(name: 'total_reviews') final int totalReviews,
          @JsonKey(name: 'price_range') final int priceRange,
          @JsonKey(name: 'has_sports_viewing') final bool hasSportsViewing,
          @JsonKey(name: 'has_live_music') final bool hasLiveMusic,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'is_featured') final bool isFeatured,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$PubImpl;

  factory _Pub.fromJson(Map<String, dynamic> json) = _$PubImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl;
  @override
  String get address;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  @JsonKey(name: 'website_url')
  String? get websiteUrl;
  @override
  @JsonKey(name: 'operating_hours')
  Map<String, dynamic>? get operatingHours;
  @override
  @JsonKey(name: 'average_rating')
  double get averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  int get totalReviews;
  @override
  @JsonKey(name: 'price_range')
  int get priceRange;
  @override
  @JsonKey(name: 'has_sports_viewing')
  bool get hasSportsViewing;
  @override
  @JsonKey(name: 'has_live_music')
  bool get hasLiveMusic;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$PubImplCopyWith<_$PubImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
