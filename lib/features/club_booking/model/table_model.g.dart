// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TableModelImpl _$$TableModelImplFromJson(Map<String, dynamic> json) =>
    _$TableModelImpl(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      location: json['location'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$TableModelImplToJson(_$TableModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clubId': instance.clubId,
      'name': instance.name,
      'capacity': instance.capacity,
      'isAvailable': instance.isAvailable,
      'pricePerHour': instance.pricePerHour,
      'location': instance.location,
      'isSelected': instance.isSelected,
    };
