import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class YoutubePlayerController with ChangeNotifier {
  final String initialVideoId;
  final YoutubePlayerFlags flags;
  final List<VoidCallback> _listeners = [];
  
  YoutubePlayerController({
    required this.initialVideoId,
    bool autoPlay = true,
    this.flags = const YoutubePlayerFlags(),
  });

  // Add a listener method that can handle function callbacks
  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove a listener method
  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Call all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Navigation methods
  void toggleFullScreenMode() {
    // Stub implementation
    _notifyListeners();
  }

  void play() {
    // Stub implementation
    _notifyListeners();
  }

  void pause() {
    // Stub implementation
    _notifyListeners();
  }

  void load(String videoId) {
    // Stub implementation
    _notifyListeners();
  }

  void mute() {
    // Stub implementation
    _notifyListeners();
  }

  void unMute() {
    // Stub implementation
    _notifyListeners();
  }

  void seekTo(Duration position) {
    // Stub implementation
    _notifyListeners();
  }
  
  // Clean up resources
  @override
  void dispose() {
    _listeners.clear();
    super.dispose();
  }
  
  // Stub for the controller that used to include InAppWebViewController
  final dynamic webViewController = null;
}

class YoutubePlayerFlags {
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
  final bool useHybridComposition;

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
    this.useHybridComposition = true,
  });
} 