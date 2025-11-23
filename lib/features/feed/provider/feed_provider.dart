import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/feed_model.dart';
import '../service/feed_service.dart';
import '../../../data/models/event_model.dart';
import 'dart:async';

// Service provider
final feedServiceProvider = Provider<FeedService>((ref) {
  final supabase = Supabase.instance.client;
  return FeedService(supabase);
});

// Event cache provider to store fetched event details
final eventCacheProvider = StateProvider<Map<String, EventModel>>((ref) => {});

// Feed state class
class FeedState {
  final List<FeedModel> feeds;
  final bool isLoading;
  final String? errorMessage;

  const FeedState({
    this.feeds = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FeedState copyWith({
    List<FeedModel>? feeds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeedState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Feed notifier
class FeedNotifier extends AsyncNotifier<List<FeedModel>> {
  late final FeedService _feedService;

  @override
  FutureOr<List<FeedModel>> build() async {
    _feedService = ref.read(feedServiceProvider);
    // Auto-load feeds on first use
    return await _feedService.getFeeds();
  }

  Future<bool> _isValidImageUrl(String? url) async {
    if (url == null || url.isEmpty) return false;
    
    // Check if URL starts with http:// or https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;

    try {
      // Try to fetch image headers
      final response = await http.head(Uri.parse(url));
      
      // Check content type
      final contentType = response.headers['content-type'];
      if (contentType == null) return false;
      
      // Validate content type
      final validTypes = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp',
      ];
      
      return validTypes.any((type) => contentType.toLowerCase().contains(type));
    } catch (e) {
      debugPrint('Error validating image URL: $e');
      return false;
    }
  }

  Future<String?> getEventImageUrl(String eventId) async {
    try {
      // Check cache first
      final cache = ref.read(eventCacheProvider);
      if (cache.containsKey(eventId)) {
        final imageUrl = cache[eventId]?.coverImage;
        return imageUrl;
      }

      // Fetch only the coverImage field from the events table
      final response = await _feedService.client
          .from('events')
          .select('cover_image')
          .eq('id', eventId)
          .single();
      final imageUrl = response['cover_image'] as String?;
      if (imageUrl != null) {
        // Optionally cache the event with just the coverImage
        final event = EventModel(
          id: eventId,
          title: '',
          description: '',
          location: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          clubId: '',
          coverImage: imageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          price: 0.0,
          capacity: 0,
          status: '',
        );
        ref.read(eventCacheProvider.notifier).state = {
          ...cache,
          eventId: event
        };
      }
      return imageUrl;
    } catch (e) {
      debugPrint('Error fetching event image: $e');
      return null;
    }
  }

  Future<void> fetchFeeds() async {
    state = const AsyncValue.loading();
    try {
      final feeds = await _feedService.getFeeds();
      state = AsyncValue.data(feeds);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleLike(String feedId) async {
    final feeds = state.value;
    if (feeds == null) return;
    final index = feeds.indexWhere((feed) => feed.id == feedId);
    if (index == -1) return;
    final feed = feeds[index];
    final isLiked = feed.isLiked;
    final originalFeeds = [...feeds];

    // Optimistically update UI
    final updatedFeeds = [...feeds];
    updatedFeeds[index] = feed.copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? feed.likeCount - 1 : feed.likeCount + 1,
    );
    state = AsyncValue.data(updatedFeeds);

    try {
      // Perform backend operation
      if (isLiked) {
        await _feedService.unlikeFeed(feedId);
      } else {
        await _feedService.likeFeed(feedId);
      }

      // Fetch the updated feed to ensure sync
      final userId = _feedService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _feedService.client
          .rpc('get_feed_with_like_status', params: {
            'feed_id': feedId,
            'current_user_id': userId,
          })
          .single();

      final updatedFeed = FeedModel.fromJson(response);
      final List<FeedModel> latestFeeds = [...state.value ?? []];
      final feedIndex = latestFeeds.indexWhere((f) => f.id == feedId);
      if (feedIndex != -1) {
        latestFeeds[feedIndex] = updatedFeed;
        state = AsyncValue.data(latestFeeds);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // On error, fetch the specific feed's current state
      try {
        final userId = _feedService.client.auth.currentUser?.id;
        if (userId == null) throw Exception('User not authenticated');

        final response = await _feedService.client
            .rpc('get_feed_with_like_status', params: {
              'feed_id': feedId,
              'current_user_id': userId,
            })
            .single();
        final List<FeedModel> latestFeeds = [...state.value ?? []];
        final feedIndex = latestFeeds.indexWhere((f) => f.id == feedId);
        if (feedIndex != -1) {
          latestFeeds[feedIndex] = FeedModel.fromJson(response);
          state = AsyncValue.data(latestFeeds);
        }
      } catch (innerError) {
        debugPrint('Error fetching feed after like error: $innerError');
      }
    }
  }

  Future<void> createPost(String content) async {
    try {
      state = const AsyncValue.loading();
      final newPost = await _feedService.createPost(content);
      state = AsyncValue.data([newPost, ...state.value ?? []]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Feed provider
final feedProvider = AsyncNotifierProvider<FeedNotifier, List<FeedModel>>(FeedNotifier.new);

// Currently selected feed for comments
final selectedFeedProvider = StateProvider<FeedModel?>((ref) => null);

// Comment state class
class CommentState {
  final List<FeedComment> comments;
  final bool isLoading;
  final String? errorMessage;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CommentState copyWith({
    List<FeedComment>? comments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Comment notifier
class CommentNotifier extends StateNotifier<CommentState> {
  final FeedService _feedService;

  CommentNotifier(this._feedService) : super(const CommentState());

  Future<void> fetchComments(String feedId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final comments = await _feedService.getComments(feedId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addComment({required String feedId, required String content}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final newComment = await _feedService.addComment(
        feedId: feedId,
        content: content,
      );
      state = state.copyWith(
        comments: [newComment, ...state.comments],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Comment provider
final commentProvider = StateNotifierProvider<CommentNotifier, CommentState>((ref) {
  final feedService = ref.watch(feedServiceProvider);
  return CommentNotifier(feedService);
}); 