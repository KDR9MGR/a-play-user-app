import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../model/category.dart';
import '../../../core/services/auth_service.dart';

class CategoryService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all active categories ordered by sort_order
  Future<List<Category>> getActiveCategories() async {
    return await AuthService.withAuthRetry(() async {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final data = response as List<dynamic>;
      
      return data
          .map((item) => Category.fromJson(_mapDatabaseToModel(item)))
          .toList();
    });
  }

  /// Fetch category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('name', name)
          .eq('is_active', true)
          .single();

      return Category.fromJson(_mapDatabaseToModel(response));
    } catch (e) {
      foundation.debugPrint('Error fetching category by name: $e');
      return null;
    }
  }

  /// Fetch category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return Category.fromJson(_mapDatabaseToModel(response));
    } catch (e) {
      foundation.debugPrint('Error fetching category by ID: $e');
      return null;
    }
  }

  /// Map database fields to model fields (handling snake_case to camelCase)
  Map<String, dynamic> _mapDatabaseToModel(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'name': dbData['name'],
      'displayName': dbData['display_name'],
      'icon': dbData['icon'],
      'color': dbData['color'],
      'sortOrder': dbData['sort_order'],
      'isActive': dbData['is_active'],
      'createdAt': _formatDateTimeForJson(dbData['created_at']),
      'updatedAt': _formatDateTimeForJson(dbData['updated_at']),
    };
  }

  /// Helper method to format DateTime for JSON serialization
  String? _formatDateTimeForJson(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return value.toIso8601String();
    }
    
    if (value is String) {
      try {
        final dateTime = DateTime.parse(value);
        return dateTime.toIso8601String();
      } catch (e) {
        return value;
      }
    }
    
    return null;
  }
} 