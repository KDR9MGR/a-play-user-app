import 'package:flutter/material.dart';
import '../model/youtube_content.dart';

class VideoPlayerDialog extends StatelessWidget {
  final YoutubeContent content;

  const VideoPlayerDialog({
    super.key,
    required this.content,
  });

  static void show(BuildContext context, YoutubeContent content) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text(
        'Play Video',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (content.description != null) ...[
            const SizedBox(height: 8),
            Text(
              content.description!,
              style: const TextStyle(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Video ID: ${content.videoId}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Open YouTube video or navigate to video player
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Play on YouTube', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}