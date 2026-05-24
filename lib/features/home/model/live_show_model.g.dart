// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_show_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveShowImpl _$$LiveShowImplFromJson(Map<String, dynamic> json) =>
    _$LiveShowImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      venueName: json['venue_name'] as String,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      showDate: json['show_date'] as String?,
      showTime: json['show_time'] as String?,
      ticketPrice: (json['ticket_price'] as num?)?.toDouble() ?? 0.0,
      availableTickets: (json['available_tickets'] as num?)?.toInt() ?? 0,
      showType: json['show_type'] as String? ?? 'music',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$LiveShowImplToJson(_$LiveShowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'venue_name': instance.venueName,
      'logo_url': instance.logoUrl,
      'cover_image_url': instance.coverImageUrl,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'website_url': instance.websiteUrl,
      'show_date': instance.showDate,
      'show_time': instance.showTime,
      'ticket_price': instance.ticketPrice,
      'available_tickets': instance.availableTickets,
      'show_type': instance.showType,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
