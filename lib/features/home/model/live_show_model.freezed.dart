// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_show_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiveShow _$LiveShowFromJson(Map<String, dynamic> json) {
  return _LiveShow.fromJson(json);
}

/// @nodoc
mixin _$LiveShow {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'venue_name')
  String get venueName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'website_url')
  String? get websiteUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_date')
  String? get showDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_time')
  String? get showTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'ticket_price')
  double get ticketPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_tickets')
  int get availableTickets => throw _privateConstructorUsedError;
  @JsonKey(name: 'show_type')
  String get showType => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int get totalReviews => throw _privateConstructorUsedError;
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
  $LiveShowCopyWith<LiveShow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveShowCopyWith<$Res> {
  factory $LiveShowCopyWith(LiveShow value, $Res Function(LiveShow) then) =
      _$LiveShowCopyWithImpl<$Res, LiveShow>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'venue_name') String venueName,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      String address,
      String? phone,
      String? email,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'show_date') String? showDate,
      @JsonKey(name: 'show_time') String? showTime,
      @JsonKey(name: 'ticket_price') double ticketPrice,
      @JsonKey(name: 'available_tickets') int availableTickets,
      @JsonKey(name: 'show_type') String showType,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$LiveShowCopyWithImpl<$Res, $Val extends LiveShow>
    implements $LiveShowCopyWith<$Res> {
  _$LiveShowCopyWithImpl(this._value, this._then);

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
    Object? venueName = null,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? websiteUrl = freezed,
    Object? showDate = freezed,
    Object? showTime = freezed,
    Object? ticketPrice = null,
    Object? availableTickets = null,
    Object? showType = null,
    Object? averageRating = null,
    Object? totalReviews = null,
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
      venueName: null == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
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
      showDate: freezed == showDate
          ? _value.showDate
          : showDate // ignore: cast_nullable_to_non_nullable
              as String?,
      showTime: freezed == showTime
          ? _value.showTime
          : showTime // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketPrice: null == ticketPrice
          ? _value.ticketPrice
          : ticketPrice // ignore: cast_nullable_to_non_nullable
              as double,
      availableTickets: null == availableTickets
          ? _value.availableTickets
          : availableTickets // ignore: cast_nullable_to_non_nullable
              as int,
      showType: null == showType
          ? _value.showType
          : showType // ignore: cast_nullable_to_non_nullable
              as String,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$LiveShowImplCopyWith<$Res>
    implements $LiveShowCopyWith<$Res> {
  factory _$$LiveShowImplCopyWith(
          _$LiveShowImpl value, $Res Function(_$LiveShowImpl) then) =
      __$$LiveShowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'venue_name') String venueName,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      String address,
      String? phone,
      String? email,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'show_date') String? showDate,
      @JsonKey(name: 'show_time') String? showTime,
      @JsonKey(name: 'ticket_price') double ticketPrice,
      @JsonKey(name: 'available_tickets') int availableTickets,
      @JsonKey(name: 'show_type') String showType,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'total_reviews') int totalReviews,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$LiveShowImplCopyWithImpl<$Res>
    extends _$LiveShowCopyWithImpl<$Res, _$LiveShowImpl>
    implements _$$LiveShowImplCopyWith<$Res> {
  __$$LiveShowImplCopyWithImpl(
      _$LiveShowImpl _value, $Res Function(_$LiveShowImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? venueName = null,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? websiteUrl = freezed,
    Object? showDate = freezed,
    Object? showTime = freezed,
    Object? ticketPrice = null,
    Object? availableTickets = null,
    Object? showType = null,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$LiveShowImpl(
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
      venueName: null == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
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
      showDate: freezed == showDate
          ? _value.showDate
          : showDate // ignore: cast_nullable_to_non_nullable
              as String?,
      showTime: freezed == showTime
          ? _value.showTime
          : showTime // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketPrice: null == ticketPrice
          ? _value.ticketPrice
          : ticketPrice // ignore: cast_nullable_to_non_nullable
              as double,
      availableTickets: null == availableTickets
          ? _value.availableTickets
          : availableTickets // ignore: cast_nullable_to_non_nullable
              as int,
      showType: null == showType
          ? _value.showType
          : showType // ignore: cast_nullable_to_non_nullable
              as String,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$LiveShowImpl implements _LiveShow {
  const _$LiveShowImpl(
      {required this.id,
      required this.name,
      required this.description,
      @JsonKey(name: 'venue_name') required this.venueName,
      @JsonKey(name: 'logo_url') this.logoUrl,
      @JsonKey(name: 'cover_image_url') this.coverImageUrl,
      this.address = '',
      this.phone,
      this.email,
      @JsonKey(name: 'website_url') this.websiteUrl,
      @JsonKey(name: 'show_date') this.showDate,
      @JsonKey(name: 'show_time') this.showTime,
      @JsonKey(name: 'ticket_price') this.ticketPrice = 0.0,
      @JsonKey(name: 'available_tickets') this.availableTickets = 0,
      @JsonKey(name: 'show_type') this.showType = 'music',
      @JsonKey(name: 'average_rating') this.averageRating = 0.0,
      @JsonKey(name: 'total_reviews') this.totalReviews = 0,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'is_featured') this.isFeatured = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$LiveShowImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveShowImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'venue_name')
  final String venueName;
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
  @override
  @JsonKey(name: 'show_date')
  final String? showDate;
  @override
  @JsonKey(name: 'show_time')
  final String? showTime;
  @override
  @JsonKey(name: 'ticket_price')
  final double ticketPrice;
  @override
  @JsonKey(name: 'available_tickets')
  final int availableTickets;
  @override
  @JsonKey(name: 'show_type')
  final String showType;
  @override
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
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
    return 'LiveShow(id: $id, name: $name, description: $description, venueName: $venueName, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, address: $address, phone: $phone, email: $email, websiteUrl: $websiteUrl, showDate: $showDate, showTime: $showTime, ticketPrice: $ticketPrice, availableTickets: $availableTickets, showType: $showType, averageRating: $averageRating, totalReviews: $totalReviews, isActive: $isActive, isFeatured: $isFeatured, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveShowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.showDate, showDate) ||
                other.showDate == showDate) &&
            (identical(other.showTime, showTime) ||
                other.showTime == showTime) &&
            (identical(other.ticketPrice, ticketPrice) ||
                other.ticketPrice == ticketPrice) &&
            (identical(other.availableTickets, availableTickets) ||
                other.availableTickets == availableTickets) &&
            (identical(other.showType, showType) ||
                other.showType == showType) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
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
        venueName,
        logoUrl,
        coverImageUrl,
        address,
        phone,
        email,
        websiteUrl,
        showDate,
        showTime,
        ticketPrice,
        availableTickets,
        showType,
        averageRating,
        totalReviews,
        isActive,
        isFeatured,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveShowImplCopyWith<_$LiveShowImpl> get copyWith =>
      __$$LiveShowImplCopyWithImpl<_$LiveShowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveShowImplToJson(
      this,
    );
  }
}

abstract class _LiveShow implements LiveShow {
  const factory _LiveShow(
          {required final String id,
          required final String name,
          required final String description,
          @JsonKey(name: 'venue_name') required final String venueName,
          @JsonKey(name: 'logo_url') final String? logoUrl,
          @JsonKey(name: 'cover_image_url') final String? coverImageUrl,
          final String address,
          final String? phone,
          final String? email,
          @JsonKey(name: 'website_url') final String? websiteUrl,
          @JsonKey(name: 'show_date') final String? showDate,
          @JsonKey(name: 'show_time') final String? showTime,
          @JsonKey(name: 'ticket_price') final double ticketPrice,
          @JsonKey(name: 'available_tickets') final int availableTickets,
          @JsonKey(name: 'show_type') final String showType,
          @JsonKey(name: 'average_rating') final double averageRating,
          @JsonKey(name: 'total_reviews') final int totalReviews,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'is_featured') final bool isFeatured,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$LiveShowImpl;

  factory _LiveShow.fromJson(Map<String, dynamic> json) =
      _$LiveShowImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'venue_name')
  String get venueName;
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
  @JsonKey(name: 'show_date')
  String? get showDate;
  @override
  @JsonKey(name: 'show_time')
  String? get showTime;
  @override
  @JsonKey(name: 'ticket_price')
  double get ticketPrice;
  @override
  @JsonKey(name: 'available_tickets')
  int get availableTickets;
  @override
  @JsonKey(name: 'show_type')
  String get showType;
  @override
  @JsonKey(name: 'average_rating')
  double get averageRating;
  @override
  @JsonKey(name: 'total_reviews')
  int get totalReviews;
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
  _$$LiveShowImplCopyWith<_$LiveShowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
