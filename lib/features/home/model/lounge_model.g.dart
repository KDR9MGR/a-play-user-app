// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoungeImpl _$$LoungeImplFromJson(Map<String, dynamic> json) => _$LoungeImpl(
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
      priceRange: (json['price_range'] as num?)?.toInt() ?? 2,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$LoungeImplToJson(_$LoungeImpl instance) =>
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
      'price_range': instance.priceRange,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
