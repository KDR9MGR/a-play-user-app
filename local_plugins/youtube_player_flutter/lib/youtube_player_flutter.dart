library youtube_player_flutter;

import 'dart:async';
import 'package:flutter/material.dart';

class YoutubePlayerController {
  String _currentVideoId;
  final YoutubePlayerFlags flags;
  final StreamController<YoutubePlayerValue> _stateController = StreamController.broadcast();
  YoutubePlayerValue _currentValue = const YoutubePlayerValue();
  YoutubePlayerMetaData _metadata = const YoutubePlayerMetaData();
  final List<VoidCallback> _listeners = [];

  YoutubePlayerController({
    required String initialVideoId,
    this.flags = const YoutubePlayerFlags(),
  }) : _currentVideoId = initialVideoId;

  YoutubePlayerValue get value => _currentValue;
  YoutubePlayerMetaData get metadata => _metadata;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void _updateValue(YoutubePlayerValue newValue) {
    _currentValue = newValue;
    _stateController.add(newValue);
    _notifyListeners();
  }

  void dispose() {
    _stateController.close();
    _listeners.clear();
  }

  void toggleFullScreenMode() {
    _updateValue(_currentValue.copyWith(
      isFullScreen: !_currentValue.isFullScreen,
    ));
  }

  void play() {
    _updateValue(_currentValue.copyWith(isPlaying: true));
  }

  void pause() {
    _updateValue(_currentValue.copyWith(isPlaying: false));
  }

  void load(String videoId) {
    _currentVideoId = videoId;
  }

  void mute() {}

  void unMute() {}

  void seekTo(Duration position) {}

  void setWebViewController() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _updateValue(_currentValue.copyWith(isReady: true));
      _metadata = const YoutubePlayerMetaData(duration: Duration(minutes: 10));
    });
  }

  String get videoId => _currentVideoId;
}

class YoutubePlayerValue {
  const YoutubePlayerValue({
    this.isReady = false,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.position = Duration.zero,
  });

  final bool isReady;
  final bool isPlaying;
  final bool isFullScreen;
  final Duration position;

  YoutubePlayerValue copyWith({
    bool? isReady,
    bool? isPlaying,
    bool? isFullScreen,
    Duration? position,
  }) {
    return YoutubePlayerValue(
      isReady: isReady ?? this.isReady,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      position: position ?? this.position,
    );
  }
}

class YoutubePlayerMetaData {
  const YoutubePlayerMetaData({
    this.duration = Duration.zero,
  });

  final Duration duration;
}

class YoutubePlayerFlags {
  const YoutubePlayerFlags({
    this.autoPlay = true,
    this.mute = false,
    this.disableDragSeek = false,
    this.enableCaption = true,
    this.hideControls = false,
    this.hideThumbnail = false,
    this.forceHD = false,
    this.loop = false,
    this.startAt = 0,
    this.endAt,
    this.captionLanguage = 'en',
  });

  final bool autoPlay;
  final bool mute;
  final bool disableDragSeek;
  final bool enableCaption;
  final bool hideControls;
  final bool hideThumbnail;
  final bool forceHD;
  final bool loop;
  final int startAt;
  final int? endAt;
  final String captionLanguage;
}

class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({
    Key? key,
    required this.controller,
    this.width,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onEnded,
    this.showVideoProgressIndicator = false,
    this.progressIndicatorColor,
    this.progressColors,
  }) : super(key: key);

  final YoutubePlayerController controller;
  final double? width;
  final double aspectRatio;
  final VoidCallback? onReady;
  final Function(dynamic)? onEnded;
  final bool showVideoProgressIndicator;
  final Color? progressIndicatorColor;
  final ProgressBarColors? progressColors;

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _isPlayerReady = true;
    widget.controller.setWebViewController();
    widget.onReady?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressBarColors {
  final Color playedColor;
  final Color handleColor;
  
  const ProgressBarColors({
    required this.playedColor,
    required this.handleColor,
  });
}

class YoutubePlayerBuilder extends StatelessWidget {
  const YoutubePlayerBuilder({
    Key? key,
    required this.player,
    required this.builder,
    this.onExitFullScreen,
  }) : super(key: key);

  final YoutubePlayer player;
  final Widget Function(BuildContext, Widget) builder;
  final VoidCallback? onExitFullScreen;

  @override
  Widget build(BuildContext context) {
    return builder(context, player);
  }
}
