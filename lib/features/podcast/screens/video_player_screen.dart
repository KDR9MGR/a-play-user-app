import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:go_router/go_router.dart';
import '../model/youtube_content.dart';
import '../model/watch_progress.dart';
import '../service/watch_progress_service.dart';
import 'dart:async';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final YoutubeContent content;
  final int? startTime; // Start time in seconds

  const VideoPlayerScreen({
    super.key,
    required this.content,
    this.startTime,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final WatchProgressService _watchProgressService = WatchProgressService();
  Timer? _progressTimer;
  bool _isFullScreen = false;
  WatchProgress? _currentProgress;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadWatchProgress();
  }

  void _initializePlayer() {
    // Extract video ID from YouTube URL if needed
    String videoId = widget.content.videoId;
    if (videoId.isEmpty && widget.content.youtubeUrl != null) {
      videoId = _extractVideoIdFromUrl(widget.content.youtubeUrl!);
    }
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
        hideControls: false,
        forceHD: false,
        startAt: 0,
      ),
    );
    
    // Listen for player ready state before seeking
    _controller.addListener(() {
      if (_controller.value.isReady && widget.startTime != null) {
        _controller.seekTo(Duration(seconds: widget.startTime!));
      }
    });

    _controller.addListener(_onPlayerStateChange);
  }
  
  /// Extract YouTube video ID from URL
  String _extractVideoIdFromUrl(String url) {
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? url;
  }

  void _loadWatchProgress() async {
    final progress = await _watchProgressService.getWatchProgress(
      widget.content.id,
      widget.content.videoId,
    );
    
    if (mounted) {
      setState(() {
        _currentProgress = progress;
      });
    }
  }

  void _onPlayerStateChange() {
    if (_controller.value.isPlaying) {
      _startProgressTracking();
    } else {
      _stopProgressTracking();
    }

    // Handle fullscreen changes
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateWatchProgress();
    });
  }

  void _stopProgressTracking() {
    _progressTimer?.cancel();
    _updateWatchProgress(); // Save current progress when paused
  }

  void _updateWatchProgress() async {
    if (!_controller.value.isReady) return;

    final currentPosition = _controller.value.position.inSeconds;
    final totalDuration = _controller.metadata.duration.inSeconds;

    if (totalDuration > 0 && currentPosition > 0) {
      final progress = await _watchProgressService.updateWatchProgress(
        contentId: widget.content.id,
        videoId: widget.content.videoId,
        watchedDuration: currentPosition,
        totalDuration: totalDuration,
      );

      if (mounted && progress != null) {
        setState(() {
          _currentProgress = progress;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
     
        onReady: () {
          debugPrint('Video player ready for: ${widget.content.title}');
          // Seek to start time if provided after player is ready
          if (widget.startTime != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _controller.seekTo(Duration(seconds: widget.startTime!));
            });
          }
        },
        onEnded: (data) {
          debugPrint('Video ended: ${widget.content.title}');
          _watchProgressService.markAsCompleted(
            widget.content.id,
            widget.content.videoId.isNotEmpty ? widget.content.videoId : _extractVideoIdFromUrl(widget.content.youtubeUrl ?? ''),
          );
          Navigator.of(context).pop();
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // Custom App Bar (only in portrait mode)
              if (!_isFullScreen) _buildCustomAppBar(),
              
              // Video Player
              player,
              
              // Video Info and Controls (only in portrait mode)
              if (!_isFullScreen) 
                Expanded(
                  child: _buildVideoInfo(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar() {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back',
            ),
            Expanded(
              child: Text(
                widget.content.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _addToFavorites();
              },
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              tooltip: 'Add to favorites',
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _shareVideo();
              },
              icon: const Icon(Icons.share, color: Colors.white),
              tooltip: 'Share',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    final videoId = widget.content.videoId.isNotEmpty 
        ? widget.content.videoId 
        : _extractVideoIdFromUrl(widget.content.youtubeUrl ?? '');
        
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Title
            Text(
              widget.content.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            // Video Meta Info
            Wrap(
              spacing: 8,
              children: [
                if (widget.content.year != null)
                  _buildMetaChip(widget.content.year.toString()),
                if (widget.content.category != null)
                  _buildMetaChip(widget.content.category!),
                if (widget.content.maturityRating != null)
                  _buildMetaChip(widget.content.maturityRating!),
                _buildMetaChip(widget.content.contentType.toUpperCase()),
              ],
            ),
            
            // Watch Progress Info
            if (_currentProgress != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.red, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Continue watching',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentProgress!.watchedTimeFormatted} • ${(_currentProgress!.watchPercentage * 100).toInt()}% complete',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'Like',
                    onPressed: _likeVideo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    label: 'My List',
                    onPressed: _addToWatchlist,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: _shareVideo,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Description
            if (widget.content.description != null && widget.content.description!.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.content.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Video Details
            const Text(
              'Video Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Video ID', videoId),
                  _buildDetailRow('Content Type', widget.content.contentType),
                  if (widget.content.youtubeUrl != null)
                    _buildDetailRow('YouTube URL', widget.content.youtubeUrl!),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _addToFavorites() {
    // TODO: Implement add to favorites
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _shareVideo() {
    // TODO: Implement share functionality
    final url = widget.content.youtubeUrl ?? widget.content.youtubeWatchUrl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $url'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _likeVideo() {
    // TODO: Implement like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video liked!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _addToWatchlist() {
    // TODO: Implement add to watchlist
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to My List'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}