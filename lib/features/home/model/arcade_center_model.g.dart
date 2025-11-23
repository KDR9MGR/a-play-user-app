// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arcade_center_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArcadeCenterImpl _$$ArcadeCenterImplFromJson(Map<String, dynamic> json) =>
    _$ArcadeCenterImpl(
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
      hasVrGames: json['has_vr_games'] as bool? ?? false,
      hasConsoleGames: json['has_console_games'] as bool? ?? true,
      hasArcadeMachines: json['has_arcade_machines'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$ArcadeCenterImplToJson(_$ArcadeCenterImpl instance) =>
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
      'has_vr_games': instance.hasVrGames,
      'has_console_games': instance.hasConsoleGames,
      'has_arcade_machines': instance.hasArcadeMachines,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
