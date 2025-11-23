import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/feed_model.dart';
import '../provider/feed_provider.dart';
import '../../chat/screens/chat_list_screen.dart';
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final Map<String, Future<String?>> _imageUrlCache = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  Future<String?> _getImageUrl(FeedModel feed) {
    final cacheKey = '${feed.id}_${feed.imageUrl ?? feed.eventId}';
    return _imageUrlCache.putIfAbsent(cacheKey, () {
      return feed.imageUrl != null 
        ? Future.value(feed.imageUrl)
        : (feed.eventId != null
            ? ref.read(feedProvider.notifier).getEventImageUrl(feed.eventId!)
            : Future.value(null));
    });
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0; // Load more when user is this far from bottom
    
    if (maxScroll - currentScroll <= delta) {
      _loadMoreFeeds();
    }
  }

  Future<void> _loadMoreFeeds() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // TODO: Implement pagination in provider
    // await ref.read(feedProvider.notifier).loadMoreFeeds();
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _imageUrlCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsyncValue = ref.watch(feedProvider);
    final commentState = ref.watch(commentProvider);
    final selectedFeed = ref.watch(selectedFeedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final userAvatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.email ?? 'User')}';
 
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.message, size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: feedAsyncValue.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading feed...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.activity, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load feed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(feedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (feedList) => feedList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.activity, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for updates',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(feedProvider.notifier).fetchFeeds(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: feedList.length + 1, // +1 for loading indicator
                  itemBuilder: (context, index) {
                    if (index == feedList.length) {
                      return _isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink();
                    }
                    final feed = feedList[index];
                    return _buildFeedCard(context, feed, userAvatarUrl);
                  },
                ),
              ),
      ),
      // Comment Bottom Sheet
      bottomSheet: selectedFeed != null
          ? Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Comment Header with handle
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Comments',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16),
                              ),
                              onPressed: () {
                                ref.read(selectedFeedProvider.notifier).state = null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Comment List
                  Expanded(
                    child: commentState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : commentState.comments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Iconsax.message, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No comments yet',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Be the first to share your thoughts',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: commentState.comments.length,
                                separatorBuilder: (context, index) => const Divider(indent: 70, height: 1),
                                itemBuilder: (context, index) {
                                  final comment = commentState.comments[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(userAvatarUrl),
                                      radius: 20,
                                    ),
                                    title: Row(
                                      children: [
                                        const Text(
                                          'User',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeago.format(comment.createdAt, locale: 'en_short'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        comment.content,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  );
                                },
                              ),
                  ),
                  // Comment Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userAvatarUrl),
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                            //  fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send_rounded,),
                                onPressed: () {
                                  if (_commentController.text.trim().isNotEmpty) {
                                    ref.read(commentProvider.notifier).addComment(
                                          feedId: selectedFeed.id,
                                          content: _commentController.text.trim(),
                                        );
                                    _commentController.clear();
                                  }
                                },
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                ref.read(commentProvider.notifier).addComment(
                                      feedId: selectedFeed.id,
                                      content: value.trim(),
                                    );
                                _commentController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildFeedCard(BuildContext context, FeedModel feed, String avatarUrl) {
    return Consumer (
      builder: (context, ref, child) {
        final feedAsyncValue = ref.watch(feedProvider);
        final commentState = ref.watch(commentProvider);
        final selectedFeed = ref.watch(selectedFeedProvider);
        final user = Supabase.instance.client.auth.currentUser;
        final userAvatarUrl = user?.userMetadata?['avatar_url'] ?? 
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.email ?? 'User')}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          timeago.format(feed.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Post Content
            if (feed.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  feed.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
            
            // Post Image or Event Image
            FutureBuilder<String?>(
              future: _getImageUrl(feed),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildImagePlaceholder(loading: true);
                }
                final imageUrl = snapshot.data;
                if (imageUrl == null || imageUrl.isEmpty) {
                  return _buildImagePlaceholder();
                }
                
                // Generate a stable cache key
                final cacheKey = '${feed.id}_${imageUrl.split('?').first}';
                
                return GestureDetector(
                  onTap: () {
                    // Show image in full screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            iconTheme: const IconThemeData(color: Colors.white),
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              clipBehavior: Clip.none,
                              child: Hero(
                                tag: 'feed_image_${feed.id}',
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: RepaintBoundary(
                    child: Hero(
                      tag: 'feed_image_${feed.id}',
                      child: CachedNetworkImage(
                        key: ValueKey(cacheKey),
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        maxHeightDiskCache: 1000,
                        fadeInDuration: const Duration(milliseconds: 300),
                        cacheKey: cacheKey,
                        memCacheWidth: MediaQuery.of(context).size.width.toInt(),
                        memCacheHeight: (MediaQuery.of(context).size.width * 9 / 9).toInt(),
                        placeholderFadeInDuration: const Duration(milliseconds: 300),
                        httpHeaders: const {
                          'Accept': 'image/jpeg,image/png,image/gif,image/webp',
                          'Cache-Control': 'max-age=31536000',
                        },
                        placeholder: (context, url) => _buildImagePlaceholder(loading: true),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading image: $error');
                          return _buildImagePlaceholder(error: true);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Post Actions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        ref.read(feedProvider.notifier).toggleLike(feed.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              feed.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: feed.isLiked ? Colors.red : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${feed.likeCount}',
                              style: TextStyle(
                                fontWeight: feed.isLiked ? FontWeight.bold : FontWeight.normal,
                                color: feed.isLiked ? Colors.red : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
            
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        ref.read(selectedFeedProvider.notifier).state = feed;
                        ref.read(commentProvider.notifier).fetchComments(feed.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${feed.commentCount}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePlaceholder({bool loading = false, bool error = false}) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 16 / 12,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: loading
                ? const RepaintBoundary(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        error ? Icons.error_outline : Icons.image,
                        size: 40,
                        color: error ? Colors.red[400] : Colors.grey[400],
                      ),
                      if (error)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
