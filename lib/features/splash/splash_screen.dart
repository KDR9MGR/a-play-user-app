import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../authentication/presentation/providers/auth_provider.dart';

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

      // Add timeout to prevent hanging
      await _controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Video initialization timeout, using fallback');
          throw Exception('Video initialization timeout');
        },
      );
      
      if (!mounted) return;

      // Ensure video is ready before playing
      setState(() {
        _isVideoInitialized = true;
      });

      await _controller.setLooping(false);
      await _controller.setVolume(1.0);
      await _controller.play();
      
      // Start checking video progress
      _controller.addListener(_checkVideoProgress);
      
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
      Future.delayed(const Duration(seconds: 2), _checkAuthAndNavigate);
    }
  }

  void _checkVideoProgress() {
    if (!mounted || _hasNavigated) return;
    
    final value = _controller.value;
    if (value.isInitialized && (value.position >= value.duration || (value.position.inMilliseconds > 0 && !value.isPlaying && value.isCompleted))) {
       _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    try {
      // Add small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Check authentication state
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.value != null;

      if (!mounted) return;

      // Navigate based on auth state:
      // - If authenticated: go to home
      // - If not authenticated: go to sign-in (where user can also choose guest access)
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/sign-in');
      }
    } catch (e) {
      debugPrint('Error in splash screen: $e');
      if (!mounted) return;

      // On error, navigate to sign-in screen for safety
      context.go('/sign-in');
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
          child: SvgPicture.asset(
            'assets/images/app_logo.svg',
            fit: BoxFit.contain,
            width: 120,
            height: 120,
            // ignore: deprecated_member_use
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
