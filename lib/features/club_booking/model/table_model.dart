import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_model.freezed.dart';
part 'table_model.g.dart';

@freezed
class TableModel with _$TableModel {
  const factory TableModel({
    required String id,
    required String clubId,
    required String name,
    required int capacity,
    required bool isAvailable,
    required double pricePerHour,
    String? location,
    @Default(false) bool isSelected,
  }) = _TableModel;

  factory TableModel.fromJson(Map<String, dynamic> json) => _$TableModelFromJson(json);
} 