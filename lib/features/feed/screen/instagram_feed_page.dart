import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../model/feed_model.dart';
import '../model/blogger_follow_model.dart';
import '../provider/feed_provider.dart';
import '../../chat/screens/chat_list_screen.dart';

class InstagramFeedPage extends ConsumerStatefulWidget {
  const InstagramFeedPage({super.key});

  @override
  ConsumerState<InstagramFeedPage> createState() => _InstagramFeedPageState();
}

class _InstagramFeedPageState extends ConsumerState<InstagramFeedPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final Map<String, Future<String?>> _imageUrlCache = {};
  PostDuration _selectedDuration = PostDuration.hours24;

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
    const delta = 200.0;

    if (maxScroll - currentScroll <= delta) {
      _loadMoreFeeds();
    }
  }

  Future<void> _loadMoreFeeds() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // TODO: Implement pagination
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_postController.text.trim().isNotEmpty) {
                        await ref.read(feedProvider.notifier).createPostWithDuration(
                              content: _postController.text.trim(),
                              durationHours: _selectedDuration.hours,
                            );
                        _postController.clear();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Post Duration:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: PostDuration.values.map((duration) {
                        return ChoiceChip(
                          label: Text(duration.label),
                          selected: _selectedDuration == duration,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedDuration = duration);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _postController.dispose();
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
    final userAvatarUrl = user?.userMetadata?['avatar_url'] ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.email ?? 'User')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_square),
            onPressed: _showCreatePostDialog,
            tooltip: 'Create Post',
          ),
          IconButton(
            icon: const Icon(Iconsax.message),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
            tooltip: 'Messages',
          ),
        ],
      ),
      body: feedAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.danger, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load feed',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(feedProvider.notifier).refreshWithRandomFeeds(),
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
                    const Icon(Iconsax.note, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showCreatePostDialog,
                      child: const Text('Create First Post'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(feedProvider.notifier).refreshWithRandomFeeds(),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: feedList.length + 1,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == feedList.length) {
                      return _isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 60);
                    }
                    final feed = feedList[index];
                    return _buildInstagramFeedCard(context, feed, userAvatarUrl);
                  },
                ),
              ),
      ),
      // Comment Bottom Sheet
      bottomSheet: selectedFeed != null
          ? _buildCommentSheet(context, selectedFeed, commentState, userAvatarUrl)
          : null,
    );
  }

  Widget _buildInstagramFeedCard(BuildContext context, FeedModel feed, String currentUserAvatar) {
    final authorAvatar = feed.authorAvatar ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(feed.authorName ?? 'User')}';
    final authorName = feed.authorName ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar, name, and follow button
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
                // Follow/Following button
                _buildFollowButton(feed),
              ],
            ),
          ),

          // Post Image with proper aspect ratio
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
                  ref.read(feedProvider.notifier).toggleLike(feed.id);
                },
                child: AspectRatio(
                  aspectRatio: 1.0, // Instagram-style square images
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(loading: true),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(error: true),
                  ),
                ),
              );
            },
          ),

          // Action buttons (like, comment, share)
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
                  onPressed: () => _sharePost(feed),
                ),
                const Spacer(),
                if (feed.expiresAt != null)
                  IconButton(
                    icon: const Icon(Icons.access_time, size: 22),
                    onPressed: () => _showDurationInfo(feed),
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

          // Post content
          if (feed.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '$authorName ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: feed.content),
                  ],
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

  Widget _buildFollowButton(FeedModel feed) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == feed.userId) {
      return const SizedBox.shrink(); // Don't show follow button on own posts
    }

    return Consumer(
      builder: (context, ref, child) {
        return TextButton(
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
        );
      },
    );
  }

  void _sharePost(FeedModel feed) {
    final text = '${feed.authorName ?? "Someone"} shared: ${feed.content}';
    Share.share(text, subject: 'Check out this post on A Play');
  }

  void _showDurationInfo(FeedModel feed) {
    if (feed.expiresAt == null) return;

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
      aspectRatio: 1.0,
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

  Widget _buildCommentSheet(BuildContext context, FeedModel selectedFeed, CommentState commentState, String userAvatarUrl) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(selectedFeedProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // Comments List
          Expanded(
            child: commentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : commentState.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.message, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: commentState.comments.length,
                        itemBuilder: (context, index) {
                          final comment = commentState.comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userAvatarUrl),
                              radius: 18,
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'User',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timeago.format(comment.createdAt, locale: 'en_short'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(comment.content),
                            ),
                          );
                        },
                      ),
          ),
          // Comment Input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userAvatarUrl),
                  radius: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (value) => _submitComment(selectedFeed.id),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _submitComment(selectedFeed.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment(String feedId) {
    if (_commentController.text.trim().isNotEmpty) {
      ref.read(commentProvider.notifier).addComment(
            feedId: feedId,
            content: _commentController.text.trim(),
          );
      _commentController.clear();
    }
  }
}
