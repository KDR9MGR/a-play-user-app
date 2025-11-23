// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beach_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BeachImpl _$$BeachImplFromJson(Map<String, dynamic> json) => _$BeachImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      entryFee: (json['entry_fee'] as num?)?.toDouble() ?? 0.0,
      hasFacilities: json['has_facilities'] as bool? ?? true,
      hasWaterSports: json['has_water_sports'] as bool? ?? false,
      hasRestaurant: json['has_restaurant'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$BeachImplToJson(_$BeachImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'cover_image_url': instance.coverImageUrl,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'website_url': instance.websiteUrl,
      'operating_hours': instance.operatingHours,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'entry_fee': instance.entryFee,
      'has_facilities': instance.hasFacilities,
      'has_water_sports': instance.hasWaterSports,
      'has_restaurant': instance.hasRestaurant,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
