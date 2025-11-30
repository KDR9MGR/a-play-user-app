import 'package:flutter/material.dart';

import '../model/youtube_content.dart';
import 'video_card.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final List<YoutubeContent> content;
  final Function(YoutubeContent) onVideoTap;
  final bool showProgress;
  final int maxItems;

  const ContentSection({
    super.key,
    required this.title,
    required this.content,
    required this.onVideoTap,
    this.showProgress = false,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayContent = content.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (content.length > maxItems)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to see all content
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayContent.length,
            itemBuilder: (context, index) {
              final videoContent = displayContent[index];
              return VideoCard(
                content: videoContent,
                onTap: () => onVideoTap(videoContent),
                height: showProgress
                    ? 80
                    : MediaQuery.of(context).size.height * 0.25,
                showProgress: showProgress,
                progressValue: showProgress ? 0.3 + (index * 0.2) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryContent extends StatelessWidget {
  final String categoryName;
  final List<YoutubeContent> content;
  final Function(YoutubeContent) onVideoTap;

  const CategoryContent({
    super.key,
    required this.categoryName,
    required this.content,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No content found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categoryName == 'all'
                  ? 'No videos available at the moment.'
                  : 'No videos in $categoryName category.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              categoryName == 'all'
                  ? 'All Content'
                  : categoryName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: content.length,
            itemBuilder: (context, index) {
              return GridVideoCard(
                content: content[index],
                onTap: () => onVideoTap(content[index]),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
