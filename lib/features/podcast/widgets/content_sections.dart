import 'package:flutter/material.dart';
import '../model/youtube_content.dart';
import '../screens/video_player_screen.dart';

class ContentSections extends StatelessWidget {
  final List<YoutubeContent> content;

  const ContentSections({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Continue Watching Section
        _buildSection(
          context,
          title: 'Continue Watching for Saurabh Saini',
          items: content.take(5).toList(),
          isCircular: true,
        ),
        const SizedBox(height: 40),
        // Your Next Watch Section
        _buildSection(
          context,
          title: 'Your Next Watch',
          items: content.skip(5).take(6).toList(),
          isCircular: false,
        ),
        const SizedBox(height: 40),
        // International TV Shows Section
        _buildSection(
          context,
          title: 'International TV Shows Dubbed in Hindi',
          items: content.skip(10).take(6).toList(),
          isCircular: false,
        ),
        const SizedBox(height: 40),
        // Crime Dramas Section
        _buildSection(
          context,
          title: 'Relentless Crime Dramas',
          items: content.skip(15).take(6).toList(),
          isCircular: false,
        ),
        const SizedBox(height: 100), // Bottom spacing
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<YoutubeContent> items,
    required bool isCircular,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isCircular ? 120 : 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < items.length - 1 ? 12 : 0,
                ),
                child: isCircular
                    ? _buildCircularItem(context, items[index], index)
                    : _buildRectangularItem(context, items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCircularItem(
      BuildContext context, YoutubeContent item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              content: item,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: item.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      item.thumbnailUrlMedium,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
            ),
          ),
          // Play button overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Episode indicator
          if (index < 3)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'S1: E${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRectangularItem(BuildContext context, YoutubeContent item) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                content: item,
              ),
            ),
          );
        },
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade800,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.thumbnailUrl.isNotEmpty
                ? Image.network(
                    item.thumbnailUrlHigh,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white54,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  ),
          ),
        ));
  }
}
