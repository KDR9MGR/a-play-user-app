import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/youtube_content.dart';

class FeaturedContent extends StatelessWidget {
  final List<YoutubeContent> featuredContent;
  final Function(YoutubeContent) onPlayVideo;
  final Function(YoutubeContent) onAddToWatchlist;

  const FeaturedContent({
    super.key,
    required this.featuredContent,
    required this.onPlayVideo,
    required this.onAddToWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredContent.isEmpty) {
      return const SizedBox.shrink();
    }

    final featured = featuredContent.first;

    return Container(
      margin: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: featured.coverImage != null || featured.videoId.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(
                  featured.coverImage ?? featured.thumbnailUrl,
                ),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle image loading errors silently
                },
              )
            : null,
        color: featured.coverImage == null && featured.videoId.isEmpty 
            ? Colors.grey[800] 
            : null,
      ),
      child: Stack(
        children: [
          if (featured.coverImage == null && featured.videoId.isEmpty)
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.white54,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featured.title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (featured.description != null)
                Text(
                  featured.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (featured.category != null || featured.maturityRating != null)
                Text(
                  [
                    featured.category,
                    featured.maturityRating,
                    featured.year?.toString()
                  ].where((element) => element != null).join(' • '),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onPlayVideo(featured),
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label:
                          const Text('Play', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAddToWatchlist(featured),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('My List',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}
