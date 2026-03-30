import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_show_model.freezed.dart';
part 'live_show_model.g.dart';

@freezed
class LiveShow with _$LiveShow {
  const factory LiveShow({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'venue_name') required String venueName,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @Default('') String address,
    String? phone,
    String? email,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'show_date') String? showDate,
    @JsonKey(name: 'show_time') String? showTime,
    @JsonKey(name: 'ticket_price') @Default(0.0) double ticketPrice,
    @JsonKey(name: 'available_tickets') @Default(0) int availableTickets,
    @JsonKey(name: 'show_type') @Default('music') String showType,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _LiveShow;

  factory LiveShow.fromJson(Map<String, dynamic> json) => _$LiveShowFromJson(json);
}