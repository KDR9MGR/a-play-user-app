import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../model/feed_model.dart';
import '../provider/feed_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../subscription/utils/subscription_utils.dart';
import '../../../presentation/widgets/eula_consent_dialog.dart';
import '../service/content_filter_service.dart';
import '../service/block_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/moderation_service.dart';

class EnhancedFeedScreen extends ConsumerStatefulWidget {
  const EnhancedFeedScreen({super.key});

  @override
  ConsumerState<EnhancedFeedScreen> createState() => _EnhancedFeedScreenState();
}

class _EnhancedFeedScreenState extends ConsumerState<EnhancedFeedScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _postController = TextEditingController();
  late AnimationController _fabController;
  final bool _showCreatePost = false;
  bool _consentChecked = false;
  bool _consented = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await EulaConsentDialog.ensureConsent(context);
      setState(() {
        _consentChecked = true;
        _consented = ok;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    if (!_consentChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E0E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE50914)),
        ),
      );
    }

    if (!_consented) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E0E0E),
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.privacy_tip, color: Colors.white, size: 64),
              const SizedBox(height: 12),
              const Text(
                'EULA agreement required to access the Feed',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final ok = await EulaConsentDialog.ensureConsent(context);
                  setState(() {
                    _consented = ok;
                    _consentChecked = true;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                child: const Text('Review and Agree'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: _buildAppBar(),
      body: feedState.when(
        loading: () => _buildShimmerLoading(),
        error: (error, stackTrace) => _buildErrorState(error.toString()),
        data: (feeds) => _buildFeedContent(feeds),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0E0E0E),
      elevation: 0,
      title: const Text(
        'Feed',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerPost(),
    );
  }

  Widget _buildShimmerPost() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFE50914),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load feed. Please try again.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(feedProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(List<FeedModel> feeds) {
    return FutureBuilder<List<String>>(
      future: BlockService.getBlockedUserIds(),
      builder: (context, snapshot) {
        final blocked = snapshot.data ?? const <String>[];
        final visibleFeeds = feeds.where((f) => !blocked.contains(f.userId)).toList();
        return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Create Post Section
        SliverToBoxAdapter(
          child: _buildCreatePostSection(),
        ),
        
        // Feed Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final feed = visibleFeeds[index];
              return _buildFeedPost(feed, index);
            },
            childCount: visibleFeeds.length,
          ),
        ),
        
        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
        );
      },
    );
  }

  Widget _buildCreatePostSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Post Input
          Expanded(
            child: GestureDetector(
              onTap: _showCreatePostModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPost(FeedModel feed, int index) {
    return Consumer(
      builder: (context, ref, child) {
        final hasPremiumAccess = SubscriptionUtils.hasPremiumAccess(ref);
        
        // Allow first few posts for non-premium users
        final canAccess = hasPremiumAccess || index < 2;
        
        return GestureDetector(
          onTap: !canAccess ? () async {
            await SubscriptionUtils.requirePremiumAccess(
              context,
              ref,
              featureName: 'Full Feed Access',
            );
          } : null,
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Header
                    _buildPostHeader(feed, canAccess),
                    
                    // Post Content
                    if (feed.content.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildFilteredContent(feed.content, canAccess),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Post Image
                    if (feed.imageUrl != null)
                      _buildPostImage(feed.imageUrl!, canAccess),
                    
                    // Post Actions
                    _buildPostActions(feed, canAccess),
                  ],
                ),
                
                // Lock overlay for non-premium posts
                if (!canAccess)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Premium Content',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Tap to unlock',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 100 * index))
           .fadeIn(duration: const Duration(milliseconds: 600))
           .slideY(begin: 0.2, duration: const Duration(milliseconds: 600)),
        );
      },
    );
  }

  Widget _buildPostHeader(FeedModel feed, [bool canAccess = true]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Name', // You can get this from user profile
                  style: TextStyle(
                    color: canAccess ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(feed.createdAt),
                  style: TextStyle(
                    color: canAccess ? Colors.grey[400] : Colors.grey[400]?.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // More Options
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
            onPressed: () => _showPostOptions(feed),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl, [bool canAccess = true]) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: ColorFiltered(
          colorFilter: canAccess 
              ? const ColorFilter.mode(
                  Colors.transparent, 
                  BlendMode.multiply,
                )
              : ColorFilter.mode(
                  Colors.grey.withValues(alpha: 0.6), 
                  BlendMode.saturation,
                ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: const Color(0xFF2A2A2A),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: const Color(0xFF2A2A2A),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 48,
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPostActions(FeedModel feed, [bool canAccess = true]) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Like Button
          _buildActionButton(
            icon: feed.isLiked ? Icons.favorite : Icons.favorite_border,
            iconColor: canAccess 
                ? (feed.isLiked ? const Color(0xFFE50914) : Colors.grey)
                : Colors.grey.withValues(alpha: 0.5),
            count: feed.likeCount,
            onPressed: canAccess ? () => _toggleLike(feed) : null,
          ),
          const SizedBox(width: 24),
          
          // Comment Button
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            iconColor: canAccess ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
            count: feed.commentCount,
            onPressed: canAccess ? () => _showComments(feed) : null,
          ),
          const SizedBox(width: 24),
          
          // Share Button
          _buildActionButton(
            icon: Icons.share_outlined,
            iconColor: canAccess ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
            onPressed: canAccess ? () => _sharePost(feed) : null,
          ),
          
          const Spacer(),
          
          // Save Button
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: canAccess ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
            ),
            onPressed: canAccess ? () => _savePost(feed) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    int? count,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          if (count != null && count > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCreatePostModal,
      backgroundColor: const Color(0xFFE50914),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreatePostModal(),
    );
  }

  Widget _buildCreatePostModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Create Post',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _submitPost,
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          
          // Post Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE50914), Color(0xFFFF6B6B)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Public',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(FeedModel feed) {
    // Implement like functionality
    ref.read(feedProvider.notifier).toggleLike(feed.id);
  }

  void _showComments(FeedModel feed) {
    // Implement comments functionality
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsModal(feed),
    );
  }

  Widget _buildCommentsModal(FeedModel feed) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Comments',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          
          // Comments List
          const Expanded(
            child: Center(
              child: Text(
                'No comments yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFE50914)),
                  onPressed: () {
                    // Implement comment submission
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePost(FeedModel feed) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Color(0xFFE50914),
      ),
    );
  }

  void _savePost(FeedModel feed) {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post saved!'),
        backgroundColor: Color(0xFFE50914),
      ),
    );
  }

  void _showPostOptions(FeedModel feed) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.white),
              title: const Text('Save Post', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.white),
              title: const Text('Report Post', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.of(context).pop();
                await _reportPost(feed);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                await _blockUser(feed.userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredContent(String content, bool canAccess) {
    final result = ContentFilterService.evaluate(content);
    if (!result.isObjectionable) {
      return Text(
        content,
        style: TextStyle(
          color: canAccess ? Colors.white : Colors.white.withValues(alpha: 0.5),
          fontSize: 16,
          height: 1.4,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Objectionable content detected',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            result.filteredText,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () => _showPostOptionsForReportOnly(),
                child: const Text('Flag', style: TextStyle(color: Colors.redAccent)),
              ),
              const Spacer(),
              Text(
                'Filtered automatically',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showPostOptionsForReportOnly() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use post menu to report.'),
        backgroundColor: Color(0xFFE50914),
      ),
    );
  }

  Future<void> _reportPost(FeedModel feed) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Report Post', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Describe the issue (required)',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          )
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        final supabase = Supabase.instance.client;
        final moderation = ModerationService(supabase);
        await moderation.reportFeed(feedId: feed.id, reason: reasonController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. We act within 24 hours.'),
            backgroundColor: Color(0xFFE50914),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    }
  }

  Future<void> _blockUser(String userId) async {
    try {
      await BlockService.blockUser(userId);
      // Try remote block if table exists
      try {
        final supabase = Supabase.instance.client;
        final moderation = ModerationService(supabase);
        await moderation.blockUserRemote(blockedUserId: userId);
      } catch (_) {}
      // Refresh view
      ref.invalidate(feedProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User blocked. Their posts are hidden.'),
          backgroundColor: Color(0xFFE50914),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to block user: $e'),
          backgroundColor: const Color(0xFFE50914),
        ),
      );
    }
  }

  void _submitPost() {
    if (_postController.text.trim().isEmpty) return;
    
    // Implement post submission
    final content = _postController.text.trim();
    ref.read(feedProvider.notifier).createPost(content);
    
    _postController.clear();
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Color(0xFFE50914),
      ),
    );
  }
}