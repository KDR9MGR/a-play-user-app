// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isSpicy: json['is_spicy'] as bool? ?? false,
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      calories: (json['calories'] as num?)?.toInt(),
      preparationTime: (json['preparation_time'] as num?)?.toInt() ?? 15,
      isAvailable: json['is_available'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant_id': instance.restaurantId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'is_vegetarian': instance.isVegetarian,
      'is_vegan': instance.isVegan,
      'is_spicy': instance.isSpicy,
      'allergens': instance.allergens,
      'calories': instance.calories,
      'preparation_time': instance.preparationTime,
      'is_available': instance.isAvailable,
      'is_popular': instance.isPopular,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
