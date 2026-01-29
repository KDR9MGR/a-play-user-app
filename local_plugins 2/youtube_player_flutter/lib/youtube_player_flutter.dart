library youtube_player_flutter;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
export 'src/utils/youtube_player_controller.dart';
export 'src/player/youtube_player.dart';
export 'src/widgets/widgets.dart';

class YoutubePlayerController {
  String _currentVideoId;
  final YoutubePlayerFlags flags;
  final StreamController<YoutubePlayerValue> _stateController = StreamController.broadcast();
  YoutubePlayerValue _currentValue = const YoutubePlayerValue();
  YoutubePlayerMetaData _metadata = const YoutubePlayerMetaData();
  final List<VoidCallback> _listeners = [];
  WebViewController? _webViewController;

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
    _webViewController?.runJavaScript('player.playVideo();');
    _updateValue(_currentValue.copyWith(isPlaying: true));
  }

  void pause() {
    _webViewController?.runJavaScript('player.pauseVideo();');
    _updateValue(_currentValue.copyWith(isPlaying: false));
  }

  void load(String videoId) {
    _currentVideoId = videoId;
    _webViewController?.runJavaScript('player.loadVideoById("$videoId");');
  }

  void mute() {
    _webViewController?.runJavaScript('player.mute();');
  }

  void unMute() {
    _webViewController?.runJavaScript('player.unMute();');
  }

  void seekTo(Duration position) {
    final seconds = position.inSeconds;
    _webViewController?.runJavaScript('player.seekTo($seconds, true);');
  }

  void setWebViewController(WebViewController controller) {
    _webViewController = controller;
    // Initialize player state as ready
    Future.delayed(const Duration(milliseconds: 1000), () {
      _updateValue(_currentValue.copyWith(isReady: true));
      _metadata = const YoutubePlayerMetaData(duration: Duration(minutes: 10)); // Default duration
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
    super.key,
    required this.controller,
    this.width,
    this.aspectRatio = 16 / 9,
    this.onReady,
    this.onEnded,
    this.showVideoProgressIndicator = false,
    this.progressIndicatorColor,
    this.progressColors,
  });

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
  late WebViewController _webViewController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!_isPlayerReady) {
              _isPlayerReady = true;
              widget.controller.setWebViewController(_webViewController);
              widget.onReady?.call();
            }
          },
        ),
      )
      ..loadHtmlString(_buildYouTubePlayerHtml());
  }

  String _buildYouTubePlayerHtml() {
    final videoId = widget.controller.videoId;
    final autoPlay = widget.controller.flags.autoPlay ? 1 : 0;
    final mute = widget.controller.flags.mute ? 1 : 0;
    final loop = widget.controller.flags.loop ? 1 : 0;
    final controls = widget.controller.flags.hideControls ? 0 : 1;
    final startTime = widget.controller.flags.startAt;

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { margin: 0; padding: 0; background: #000; }
            #player { width: 100%; height: 100vh; }
        </style>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '$videoId',
                    playerVars: {
                        'autoplay': $autoPlay,
                        'mute': $mute,
                        'loop': $loop,
                        'controls': $controls,
                        'start': $startTime,
                        'modestbranding': 1,
                        'rel': 0,
                        'showinfo': 0,
                        'iv_load_policy': 3,
                        'enablejsapi': 1,
                        'origin': window.location.origin
                    },
                    events: {
                        'onReady': onPlayerReady,
                        'onStateChange': onPlayerStateChange,
                        'onError': onPlayerError
                    }
                });
            }

            function onPlayerReady(event) {
                console.log('Player ready');
            }

            function onPlayerStateChange(event) {
                if (event.data == YT.PlayerState.ENDED) {
                    console.log('Video ended');
                } else if (event.data == YT.PlayerState.PLAYING) {
                    console.log('Video playing');
                } else if (event.data == YT.PlayerState.PAUSED) {
                    console.log('Video paused');
                }
            }

            function onPlayerError(event) {
                console.log('Player error: ' + event.data);
            }

            // Expose functions to Flutter
            window.flutter_inappwebview = window.flutter_inappwebview || {};
            window.flutter_inappwebview.callHandler = window.flutter_inappwebview.callHandler || function() {};
        </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: WebViewWidget(controller: _webViewController),
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
    super.key,
    required this.player,
    required this.builder,
    this.onExitFullScreen,
  });

  final YoutubePlayer player;
  final Widget Function(BuildContext, Widget) builder;
  final VoidCallback? onExitFullScreen;

  @override
  Widget build(BuildContext context) {
    return builder(context, player);
  }
}