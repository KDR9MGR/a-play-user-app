// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemOptionImpl _$$MenuItemOptionImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemOptionImpl(
      id: json['id'] as String,
      menuItemId: json['menu_item_id'] as String,
      optionType: json['option_type'] as String,
      optionName: json['option_name'] as String,
      priceModifier: (json['price_modifier'] as num?)?.toDouble() ?? 0.0,
      isRequired: json['is_required'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$MenuItemOptionImplToJson(
        _$MenuItemOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menu_item_id': instance.menuItemId,
      'option_type': instance.optionType,
      'option_name': instance.optionName,
      'price_modifier': instance.priceModifier,
      'is_required': instance.isRequired,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
