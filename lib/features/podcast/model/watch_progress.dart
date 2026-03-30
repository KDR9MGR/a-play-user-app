import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch_progress.freezed.dart';
part 'watch_progress.g.dart';

@freezed
class WatchProgress with _$WatchProgress {
  const factory WatchProgress({
    required String id,
    required String userId,
    required String contentId,
    required String videoId,
    required int watchedDuration, // in seconds
    required int totalDuration, // in seconds
    required DateTime lastWatched,
    @Default(false) bool isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WatchProgress;

  factory WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);
      
  const WatchProgress._();
  
  // Calculate watch percentage (0.0 to 1.0)
  double get watchPercentage {
    if (totalDuration <= 0) return 0.0;
    return (watchedDuration / totalDuration).clamp(0.0, 1.0);
  }
  
  // Check if video is recently started (less than 5% watched)
  bool get isRecentlyStarted {
    return watchPercentage < 0.05;
  }
  
  // Check if video is almost finished (more than 90% watched)
  bool get isAlmostFinished {
    return watchPercentage > 0.90;
  }
  
  // Get formatted remaining time
  String get remainingTimeFormatted {
    final remaining = totalDuration - watchedDuration;
    if (remaining <= 0) return 'Finished';
    
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    } else {
      return '${minutes}m left';
    }
  }
  
  // Get formatted watched time
  String get watchedTimeFormatted {
    final hours = watchedDuration ~/ 3600;
    final minutes = (watchedDuration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m watched';
    } else {
      return '${minutes}m watched';
    }
  }
}