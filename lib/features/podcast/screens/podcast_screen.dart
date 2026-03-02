import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/youtube_content.dart';
import '../controller/youtube_content_controller.dart';
import '../provider/category_provider.dart';
import '../widgets/podcast_header.dart';
import '../widgets/podcast_tab_bar.dart';
import '../widgets/featured_content.dart';
import '../widgets/content_section.dart';
import '../widgets/continue_watching_section.dart';
import 'video_player_screen.dart';

class PodcastScreen extends ConsumerStatefulWidget {
  const PodcastScreen({super.key});

  @override
  ConsumerState<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<PodcastScreen> {
  int selectedIndex = 0;

  // Provider for YouTube content controller
  late final youtubeContentProvider =
      AsyncNotifierProvider<YoutubeContentController, YoutubeContentSections>(
    () => YoutubeContentController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background gradient from status bar to bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Content with proper status bar padding
          SafeArea(
            child: Column(
              children: [
                const PodcastHeader(),
                PodcastTabBar(
                  selectedIndex: selectedIndex,
                  onTabSelected: _onTabSelected,
                ),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTabSelected(int index, String categoryId) {
    setState(() => selectedIndex = index);
    // Update selected category for filtering
    ref.read(selectedCategoryProvider.notifier).state = categoryId;
  }

  Widget _buildContent() {
    return Consumer(
      builder: (context, ref, child) {
        final contentAsync = ref.watch(youtubeContentProvider);
        final selectedCategory = ref.watch(selectedCategoryProvider);

        return contentAsync.when(
          data: (sections) {
            // If a specific category is selected, show filtered content
            if (selectedIndex > 0) {
              return _buildCategoryView(selectedCategory);
            }

            // Default view with all sections
            return _buildHomeView(sections);
          },
          loading: () => _buildLoadingView(),
          error: (error, stack) => _buildErrorView(error),
        );
      },
    );
  }

  Widget _buildHomeView(YoutubeContentSections sections) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeaturedContent(
            featuredContent: sections.featured,
            onPlayVideo: _playVideo,
            onAddToWatchlist: _addToWatchlist,
          ),
          const SizedBox(height: 16),
          ContinueWatchingSection(
            onVideoTap: _playVideoWithProgress,
          ),
          const SizedBox(height: 28),
          ContentSection(
            title: 'Your Next Watch',
            content: sections.trending,
            onVideoTap: _playVideo,
            maxItems: 10,
          ),
          const SizedBox(height: 28),
          ContentSection(
            title: 'Trending Now',
            content: sections.action,
            onVideoTap: _playVideo,
            maxItems: 8,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildCategoryView(String categoryName) {
    return FutureBuilder<List<YoutubeContent>>(
      future: ref
          .read(youtubeContentProvider.notifier)
          .getContentByCategory(categoryName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingView();
        }

        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error);
        }

        final content = snapshot.data ?? [];

        return CategoryContent(
          categoryName: categoryName,
          content: content,
          onVideoTap: _playVideo,
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Loading content...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load content',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(youtubeContentProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods for video interaction
  void _playVideo(YoutubeContent content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(content: content),
      ),
    );
  }

  void _playVideoWithProgress(YoutubeContent content, int? startTime) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          content: content,
          startTime: startTime,
        ),
      ),
    );
  }

  void _addToWatchlist(YoutubeContent content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${content.title}" added to My List'),
        backgroundColor: const Color(0xFF16213E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
