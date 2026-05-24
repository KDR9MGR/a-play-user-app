// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      id: json['id'] as String,
      menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      selectedOptions: (json['selectedOptions'] as List<dynamic>?)
              ?.map((e) => MenuItemOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItem': instance.menuItem,
      'quantity': instance.quantity,
      'selectedOptions': instance.selectedOptions,
      'specialInstructions': instance.specialInstructions,
    };
