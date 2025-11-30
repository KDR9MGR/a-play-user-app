import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  /// Check if the current session is valid and refresh if needed
  static Future<bool> ensureValidSession() async {
    try {
      final session = _client.auth.currentSession;
      
      if (session == null) {
        debugPrint('No session found');
        return false;
      }
      
      // Check if token is expired or about to expire (within 5 minutes)
      final expiresAtSeconds = session.expiresAt;
      if (expiresAtSeconds == null) {
        debugPrint('No expiry time found in session');
        return false;
      }
      
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtSeconds * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expiresAt.difference(now);
      
      if (timeUntilExpiry.inMinutes <= 5) {
        debugPrint('Token expiring soon, refreshing...');
        await refreshSession();
        return _client.auth.currentSession != null;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }
  
  /// Refresh the current session
  static Future<void> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      if (response.session == null) {
        throw Exception('Failed to refresh session');
      }
      debugPrint('Session refreshed successfully');
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      await _client.auth.signOut();
      throw Exception('Session expired. Please sign in again.');
    }
  }
  
  /// Handle authentication errors globally
  static Future<T> withAuthRetry<T>(Future<T> Function() operation) async {
    try {
      // Ensure valid session before operation
      await ensureValidSession();
      return await operation();
    } catch (e) {
      if (e.toString().contains('JWT expired') || 
          e.toString().contains('PGRST301') ||
          e.toString().contains('Unauthorized')) {
        try {
          debugPrint('JWT expired, attempting to refresh...');
          await refreshSession();
          return await operation();
        } catch (refreshError) {
          debugPrint('Failed to refresh session: $refreshError');
          await _client.auth.signOut();
          throw Exception('Session expired. Please sign in again.');
        }
      }
      rethrow;
    }
  }
  
  /// Sign out the user completely
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }
  
  /// Get current user's name (email or display name)
  static Future<String?> getCurrentUserName() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      // Try to get display name first, then fall back to email
      String? name = user.userMetadata?['full_name'] ?? 
                     user.userMetadata?['name'] ?? 
                     user.userMetadata?['display_name'];
      
      if (name != null && name.isNotEmpty) {
        return name;
      }
      
      // Fall back to email (remove domain part)
      if (user.email != null) {
        final emailParts = user.email!.split('@');
        if (emailParts.isNotEmpty) {
          return emailParts.first;
        }
      }
      
      return 'User';
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return 'User';
    }
  }
}

// Global auth retry provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService()); 