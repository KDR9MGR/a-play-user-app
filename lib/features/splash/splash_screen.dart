import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _useVideoFallback = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/videos/splash.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      // Add timeout to prevent hanging during debug
      await _controller.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Video initialization timeout, using fallback');
          _useFallback();
          return;
        },
      );
      
      // Check if video is actually playing
      await _controller.play();
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_controller.value.isPlaying && mounted) {
        await _controller.setLooping(false);
        await _controller.setVolume(1.0);
        
        setState(() => _isVideoInitialized = true);
        
        // Start checking auth state when video starts playing
        _controller.addListener(_checkVideoProgress);
      } else {
        // Video isn't playing, use fallback
        _useFallback();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      _useFallback();
    }
  }

  void _useFallback() {
    if (mounted && !_hasNavigated) {
      setState(() {
        _useVideoFallback = true;
        _isVideoInitialized = true;
      });
      
      // Start delayed navigation with shorter timeout for debug
      Future.delayed(const Duration(seconds: 1), _checkAuthAndNavigate);
    }
  }

  void _checkVideoProgress() {
    if (!_hasNavigated && _controller.value.position >= _controller.value.duration) {
      _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    try {
      // Add small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Always navigate to home - guest browsing is allowed (Apple App Store requirement 5.1.1)
      // The app will show login prompts for account-based features (Bookings, Concierge, Feed)
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint('Error in splash screen: $e');
      if (!mounted) return;

      // Navigate to home even on error - guest browsing should work
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_useVideoFallback) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset(
            'assets/images/app_logo.svg',
            fit: BoxFit.contain,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to app name if image fails
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'A Play',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: _getVideoScale(context),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getVideoScale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final videoRatio = _controller.value.aspectRatio;
    final screenRatio = size.width / size.height;

    final scale = videoRatio < screenRatio 
        ? screenRatio / videoRatio 
        : videoRatio / screenRatio;

    return scale;
  }
} 