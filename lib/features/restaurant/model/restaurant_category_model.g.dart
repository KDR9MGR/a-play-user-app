// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantCategoryImpl _$$RestaurantCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$RestaurantCategoryImplToJson(
        _$RestaurantCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
