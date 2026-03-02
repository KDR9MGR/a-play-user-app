// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantTableImpl _$$RestaurantTableImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantTableImpl(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      tableNumber: json['table_number'] as String,
      capacity: (json['capacity'] as num).toInt(),
      isAvailable: json['is_available'] as bool? ?? true,
      tableType: json['table_type'] as String? ?? 'standard',
      locationDescription: json['location_description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$RestaurantTableImplToJson(
        _$RestaurantTableImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant_id': instance.restaurantId,
      'table_number': instance.tableNumber,
      'capacity': instance.capacity,
      'is_available': instance.isAvailable,
      'table_type': instance.tableType,
      'location_description': instance.locationDescription,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
