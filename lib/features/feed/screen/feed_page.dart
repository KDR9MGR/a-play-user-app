import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
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
                onRefresh: () => ref.read(feedProvider.notifier).refreshWithRandomFeeds(),
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
                          : const SizedBox(height: 60);
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
                    color: Colors.black.withValues(alpha: 0.1),
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
                                  color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
    final authorAvatar = feed.authorAvatar ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(feed.authorName ?? 'User')}';
    final authorName = feed.authorName ?? 'User';
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnPost = currentUserId == feed.userId;

    return Consumer(
      builder: (context, ref, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header with Follow Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(authorAvatar),
                      radius: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (feed.followerCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '• ${feed.followerCount} followers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
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
                    // Follow/Following Button
                    if (!isOwnPost)
                      TextButton(
                        onPressed: () async {
                          if (feed.isFollowingAuthor) {
                            await ref.read(feedProvider.notifier).unfollowBlogger(feed.userId);
                          } else {
                            await ref.read(feedProvider.notifier).followBlogger(feed.userId);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          backgroundColor: feed.isFollowingAuthor ? Colors.grey[800] : Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          feed.isFollowingAuthor ? 'Following' : 'Follow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
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
            
            // Post Image with proper aspect ratio (Instagram-style)
            FutureBuilder<String?>(
              future: _getImageUrl(feed),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildImagePlaceholder(loading: true);
                }
                final imageUrl = snapshot.data;
                if (imageUrl == null || imageUrl.isEmpty) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onDoubleTap: () {
                    // Double tap to like (Instagram-style)
                    ref.read(feedProvider.notifier).toggleLike(feed.id);
                  },
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
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square images like Instagram
                    child: Hero(
                      tag: 'feed_image_${feed.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
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
            
            // Post Actions (Instagram-style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      feed.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: feed.isLiked ? Colors.red : null,
                      size: 28,
                    ),
                    onPressed: () {
                      ref.read(feedProvider.notifier).toggleLike(feed.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 26),
                    onPressed: () {
                      ref.read(selectedFeedProvider.notifier).state = feed;
                      ref.read(commentProvider.notifier).fetchComments(feed.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.send_2, size: 26),
                    onPressed: () {
                      final text = '$authorName shared: ${feed.content}';
                      Share.share(text, subject: 'Check out this post on A Play');
                    },
                  ),
                  const Spacer(),
                  if (feed.expiresAt != null)
                    IconButton(
                      icon: const Icon(Icons.access_time, size: 22),
                      onPressed: () {
                        final now = DateTime.now();
                        final remaining = feed.expiresAt!.difference(now);
                        final expired = remaining.isNegative;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Post Duration'),
                            content: Text(
                              expired
                                  ? 'This post has expired'
                                  : 'This post expires in ${_formatDuration(remaining)}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Like count
            if (feed.likeCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${feed.likeCount} ${feed.likeCount == 1 ? 'like' : 'likes'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

            // View comments
            if (feed.commentCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedFeedProvider.notifier).state = feed;
                    ref.read(commentProvider.notifier).fetchComments(feed.id);
                  },
                  child: Text(
                    'View all ${feed.commentCount} comments',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      );
      }
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
  }

  Widget _buildImagePlaceholder({bool loading = false, bool error = false}) {
    return AspectRatio(
      aspectRatio: 1.0, // Instagram-style square placeholder
      child: Container(
        color: Colors.grey[900],
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Icon(
                  error ? Icons.broken_image : Icons.image,
                  size: 48,
                  color: Colors.grey[600],
                ),
        ),
      ),
    );
  }
}
