// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantImpl _$$RestaurantImplFromJson(Map<String, dynamic> json) =>
    _$RestaurantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      priceRange: (json['price_range'] as num?)?.toInt(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      minimumOrder: (json['minimum_order'] as num?)?.toDouble() ?? 0.0,
      estimatedDeliveryTime:
          (json['estimated_delivery_time'] as num?)?.toInt() ?? 30,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      acceptsCash: json['accepts_cash'] as bool? ?? true,
      acceptsCard: json['accepts_card'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$RestaurantImplToJson(_$RestaurantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'logo_url': instance.logoUrl,
      'cover_image_url': instance.coverImageUrl,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'email': instance.email,
      'website_url': instance.websiteUrl,
      'operating_hours': instance.operatingHours,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'price_range': instance.priceRange,
      'delivery_fee': instance.deliveryFee,
      'minimum_order': instance.minimumOrder,
      'estimated_delivery_time': instance.estimatedDeliveryTime,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'accepts_cash': instance.acceptsCash,
      'accepts_card': instance.acceptsCard,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
