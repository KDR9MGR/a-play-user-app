import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/youtube_content.dart';
import '../model/watch_progress.dart';
import '../service/watch_progress_service.dart';
import '../../../core/services/auth_service.dart';
import 'video_card.dart';

class ContinueWatchingSection extends ConsumerWidget {
  final Function(YoutubeContent, int?) onVideoTap;

  const ContinueWatchingSection({
    super.key,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: WatchProgressService().getContinueWatchingWithContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final continueWatchingData = snapshot.data ?? [];

        if (continueWatchingData.isEmpty) {
          return const SizedBox.shrink(); // Don't show section if no continue watching content
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<String?>(
                future: AuthService.getCurrentUserName(),
                builder: (context, snapshot) {
                  final userName = snapshot.data ?? 'User';
                  return Text(
                    'Continue Watching for $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: continueWatchingData.length > 10 ? 10 : continueWatchingData.length,
                itemBuilder: (context, index) {
                  final item = continueWatchingData[index];
                  final progress = item['progress'] as WatchProgress;
                  final contentData = item['content'] as Map<String, dynamic>;
                  
                  // Convert content data to YoutubeContent
                  final content = YoutubeContent.fromJson(contentData);
                  
                  return VideoCard(
                    content: content,
                    onTap: () => onVideoTap(content, progress.watchedDuration),
                    height: 90,
                    showProgress: true,
                    watchProgress: progress,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Continue Watching',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Continue Watching',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white54,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to load continue watching',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}