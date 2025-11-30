import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/youtube_content.dart';
import '../service/user_favorite_service.dart';

class UserFavoriteController extends StateNotifier<AsyncValue<List<YoutubeContent>>> {
  UserFavoriteController() : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  UserFavoriteService? _service;
  UserFavoriteService get service {
    _service ??= UserFavoriteService();
    return _service!;
  }

  // Cache for quick favorite status checks
  final Map<String, bool> _favoriteStatusCache = {};

  /// Load all user favorites
  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final favorites = await service.getUserFavorites();
      
      // Update cache
      _favoriteStatusCache.clear();
      for (final content in favorites) {
        _favoriteStatusCache[content.id] = true;
      }
      
      state = AsyncValue.data(favorites);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Check if content is in favorites (uses cache for quick access)
  bool isInFavorites(String contentId) {
    return _favoriteStatusCache[contentId] ?? false;
  }

  /// Toggle favorite status for content
  Future<bool> toggleFavorite(YoutubeContent content) async {
    try {
      final isCurrentlyFavorite = isInFavorites(content.id);
      
      if (isCurrentlyFavorite) {
        await service.removeFromFavorites(content.id);
        _favoriteStatusCache[content.id] = false;
        
        // Update state to remove from list
        final currentFavorites = state.value ?? [];
        final updatedFavorites = currentFavorites.where((item) => item.id != content.id).toList();
        state = AsyncValue.data(updatedFavorites);
        
        return false;
      } else {
        await service.addToFavorites(content.id);
        _favoriteStatusCache[content.id] = true;
        
        // Update state to add to list
        final currentFavorites = state.value ?? [];
        final updatedFavorites = [content, ...currentFavorites];
        state = AsyncValue.data(updatedFavorites);
        
        return true;
      }
    } catch (e) {
      // Revert cache on error
      final originalStatus = !(_favoriteStatusCache[content.id] ?? false);
      _favoriteStatusCache[content.id] = originalStatus;
      throw Exception('Failed to update favorites: $e');
    }
  }

  /// Add content to favorites
  Future<void> addToFavorites(YoutubeContent content) async {
    if (!isInFavorites(content.id)) {
      await toggleFavorite(content);
    }
  }

  /// Remove content from favorites
  Future<void> removeFromFavorites(String contentId) async {
    if (isInFavorites(contentId)) {
      // Find the content to remove
      final currentFavorites = state.value ?? [];
      final contentToRemove = currentFavorites.firstWhere(
        (item) => item.id == contentId,
        orElse: () => throw Exception('Content not found in favorites'),
      );
      await toggleFavorite(contentToRemove);
    }
  }

  /// Refresh favorites from server
  Future<void> refresh() async {
    await loadFavorites();
  }
}

/// Provider for user favorites controller
final userFavoriteProvider = StateNotifierProvider<UserFavoriteController, AsyncValue<List<YoutubeContent>>>(
  (ref) => UserFavoriteController(),
);

/// Provider to check if specific content is in favorites
final isContentInFavoritesProvider = Provider.family<bool, String>((ref, contentId) {
  final favoriteController = ref.watch(userFavoriteProvider.notifier);
  return favoriteController.isInFavorites(contentId);
});

/// Provider for favorite count
final favoriteCountProvider = Provider<int>((ref) {
  final favoritesState = ref.watch(userFavoriteProvider);
  return favoritesState.when(
    data: (favorites) => favorites.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}); 