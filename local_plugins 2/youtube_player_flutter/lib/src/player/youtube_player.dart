import 'package:flutter/material.dart';
import '../utils/youtube_player_controller.dart';
import '../widgets/widgets.dart';

class YoutubePlayer extends StatelessWidget {
  final YoutubePlayerController controller;
  final double? width;
  final double aspectRatio;
  final VoidCallback? onReady;
  final Function(dynamic)? onEnded;
  final bool showVideoProgressIndicator;
  final Color? progressIndicatorColor;
  final ProgressBarColors? progressColors;
  final List<Widget>? bottomActions;

  const YoutubePlayer({
    super.key,
    required this.controller,
    this.width,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onEnded,
    this.showVideoProgressIndicator = false,
    this.progressIndicatorColor,
    this.progressColors,
    this.bottomActions,
  });

  // Static method to get thumbnail of a video
  static String getThumbnail({
    required String videoId,
    String quality = 'medium',
    bool webp = false,
  }) {
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          children: [
            Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'YouTube Player - Stub Implementation',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (showVideoProgressIndicator && progressColors != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: 0.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColors!.playedColor,
                  ),
                  backgroundColor: Colors.grey[700],
                ),
              ),
            if (bottomActions != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  color: Colors.black45,
                  child: Row(
                    children: bottomActions!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// YoutubePlayerBuilder
class YoutubePlayerBuilder extends StatelessWidget {
  final Widget player;
  final Widget Function(BuildContext, Widget) builder;

  const YoutubePlayerBuilder({
    super.key,
    required this.player,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, player);
  }
}

// Stub class for raw player
class RawYoutubePlayer extends StatelessWidget {
  final String source;
  final Function? onWebViewCreated;

  const RawYoutubePlayer({
    super.key,
    required this.source,
    this.onWebViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text('YouTube Player - Stub Implementation', style: TextStyle(color: Colors.white)),
      ),
    );
  }
} 