import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_table_model.freezed.dart';
part 'restaurant_table_model.g.dart';

@freezed
class RestaurantTable with _$RestaurantTable {
  const factory RestaurantTable({
    required String id,
    @JsonKey(name: 'restaurant_id') required String restaurantId,
    @JsonKey(name: 'table_number') required String tableNumber,
    required int capacity,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'table_type') @Default('standard') String tableType,
    @JsonKey(name: 'location_description') String? locationDescription,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _RestaurantTable;

  const RestaurantTable._();

  factory RestaurantTable.fromJson(Map<String, dynamic> json) =>
      _$RestaurantTableFromJson(json);
}

enum TableType {
  @JsonValue('standard')
  standard,
  @JsonValue('outdoor')
  outdoor,
  @JsonValue('private')
  private,
  @JsonValue('bar')
  bar,
}

extension TableTypeExtension on TableType {
  String get displayName {
    switch (this) {
      case TableType.standard:
        return 'Standard';
      case TableType.outdoor:
        return 'Outdoor';
      case TableType.private:
        return 'Private';
      case TableType.bar:
        return 'Bar';
    }
  }
  
  String get value {
    switch (this) {
      case TableType.standard:
        return 'standard';
      case TableType.outdoor:
        return 'outdoor';
      case TableType.private:
        return 'private';
      case TableType.bar:
        return 'bar';
    }
  }
}

extension TableTypeStringExtension on String {
  String get displayName {
    switch (toLowerCase()) {
      case 'standard':
        return 'Standard';
      case 'outdoor':
        return 'Outdoor';
      case 'private':
        return 'Private';
      case 'bar':
        return 'Bar';
      default:
        return 'Standard';
    }
  }
}