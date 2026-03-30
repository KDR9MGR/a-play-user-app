import 'package:flutter/material.dart';

// Stub implementations for various widgets used in YoutubePlayer

// Progress bar widgets
class CurrentPosition extends StatelessWidget {
  const CurrentPosition({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('0:00', style: TextStyle(color: Colors.white));
  }
}

class RemainingDuration extends StatelessWidget {
  const RemainingDuration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('-0:00', style: TextStyle(color: Colors.white));
  }
}

class PlaybackSpeedButton extends StatelessWidget {
  const PlaybackSpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: const Text('1x', style: TextStyle(color: Colors.white)),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final bool isExpanded;
  final ProgressBarColors colors;

  const ProgressBar({
    super.key,
    this.isExpanded = false,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LinearProgressIndicator(
        value: 0.0,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: Colors.grey[700],
      ),
    );
  }
}

// Colors for progress bar
class ProgressBarColors {
  final Color playedColor;
  final Color handleColor;
  
  const ProgressBarColors({
    required this.playedColor,
    required this.handleColor,
  });
} 