import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_category.freezed.dart';
part 'event_category.g.dart';

@freezed
class EventCategory with _$EventCategory {
  const factory EventCategory({
    required String id,
    required String name,
    required String displayName,
    String? icon,
    String? color,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    required String createdAt,
    required String updatedAt,
  }) = _EventCategory;

  factory EventCategory.fromJson(Map<String, dynamic> json) =>
      _$EventCategoryFromJson(json);
}

// Helper extension for color parsing
extension EventCategoryExtension on EventCategory {
  int get colorInt {
    if (color == null) return 0xFF6B6B6B;
    try {
      return int.parse(color!.replaceAll('#', '0xFF'));
    } catch (e) {
      return 0xFF6B6B6B; // Default gray color
    }
  }
} 