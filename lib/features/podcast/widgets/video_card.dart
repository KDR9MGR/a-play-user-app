import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../model/youtube_content.dart';
import '../model/watch_progress.dart';

class VideoCard extends StatelessWidget {
  final YoutubeContent content;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showProgress;
  final double? progressValue;
  final WatchProgress? watchProgress;
  final VoidCallback? onMoreOptions;
  final VoidCallback? onInfo;

  const VideoCard({
    super.key,
    required this.content,
    required this.onTap,
    this.width = 110,
    this.height = 195,
    this.showProgress = true,
    this.progressValue,
    this.watchProgress,
    this.onMoreOptions,
    this.onInfo,
  });

  String get _formattedDuration {
    // In a real app, you'd get duration from YouTube API or content model
    // For now, using a mock duration that looks realistic
    final durations = [
      "5:23", "12:34", "8:45", "15:02", "7:18", 
      "22:41", "9:56", "18:29", "4:37", "13:15"
    ];
    final index = content.videoId.hashCode.abs() % durations.length;
    return durations[index];
  }

  double get _progressValue {
    return watchProgress?.watchPercentage ?? progressValue ?? 0.87; // 87% as shown in design
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          // Main video container
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[900],
            ),
            child: Stack(
              children: [
                // Video thumbnail
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: content.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF4B8B8), // Pink placeholder from design
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF4B8B8),
                        child: const Icon(
                          Icons.video_library,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Play button overlay - centered
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          width: 57,
                          height: 57,
                          decoration: const BoxDecoration(
                            color: Color(0x8A000000), // Semi-transparent black
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 1.8),
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Duration overlay with gradient background
                Positioned(
                  bottom: 39, // Above the progress bar and options
                  left: 0,
                  right: 0,
                  height: 29,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        
                        colors: [
                          Color(0x00000000), // Transparent
                          Color.fromARGB(255, 40, 40, 40), // Black
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Video options container
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 39,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 40, 40, 40), // Dark gray background
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Info icon
                          GestureDetector(
                            onTap: onInfo ?? () {},
                            child: const Icon(
                              Iconsax.info_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          
                          // More options icon
                          GestureDetector(
                            onTap: onMoreOptions ?? () {},
                            child: const Icon(
                              Iconsax.more,
                              color: Colors.white,
                              size: 24,
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

          // Progress bar at the very bottom
          if (showProgress)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Stack(
                  children: [
                    // Progress background
                    Container(
                      width: width,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF999999), // Gray background
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    // Progress fill
                    Container(
                      width: width * _progressValue,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD01319), // Red progress
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
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
}

class GridVideoCard extends StatelessWidget {
  final YoutubeContent content;
  final VoidCallback onTap;

  const GridVideoCard({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: content.thumbnailUrlHigh,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[700],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[700],
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (content.year != null)
            Text(
              content.year.toString(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}