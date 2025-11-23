import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class YouTubeApiService {
  // You'll need to add your YouTube Data API key here
  // Get it from: https://console.developers.google.com/
  static const String _apiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Extract video ID from various YouTube URL formats
  static String? extractVideoId(String url) {
    final regexes = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]+)'),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }

    // If no pattern matches, check if it's already a video ID
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
      return url;
    }

    return null;
  }

  /// Fetch video metadata from YouTube API
  /// Note: This requires a YouTube Data API key
  Future<YouTubeVideoMetadata?> getVideoMetadata(String videoIdOrUrl) async {
    try {
      final videoId = extractVideoId(videoIdOrUrl);
      if (videoId == null) {
        debugPrint('Invalid YouTube URL or video ID: $videoIdOrUrl');
        return null;
      }

      // For demo purposes, return mock data if no API key is set
      if (_apiKey == 'YOUR_YOUTUBE_API_KEY_HERE') {
        return _getMockVideoMetadata(videoId);
      }

      final url = Uri.parse('$_baseUrl/videos?part=snippet,contentDetails&id=$videoId&key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          return YouTubeVideoMetadata.fromJson(item);
        }
      } else {
        debugPrint('YouTube API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching YouTube metadata: $e');
    }
    return null;
  }

  /// Mock data for demonstration when API key is not configured
  YouTubeVideoMetadata _getMockVideoMetadata(String videoId) {
    return YouTubeVideoMetadata(
      id: videoId,
      title: 'YouTube Video - $videoId',
      description: 'Auto-fetched video description will appear here when YouTube API is configured.',
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      duration: 'PT5M30S', // 5 minutes 30 seconds in ISO 8601 format
      publishedAt: DateTime.now().toIso8601String(),
      channelTitle: 'YouTube Channel',
      tags: ['video', 'content'],
    );
  }

  /// Generate thumbnail URLs for different resolutions
  static Map<String, String> getThumbnailUrls(String videoId) {
    return {
      'default': 'https://img.youtube.com/vi/$videoId/default.jpg', // 120x90
      'medium': 'https://img.youtube.com/vi/$videoId/mqdefault.jpg', // 320x180
      'high': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg', // 480x360
      'standard': 'https://img.youtube.com/vi/$videoId/sddefault.jpg', // 640x480
      'maxres': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg', // 1280x720
    };
  }
}

class YouTubeVideoMetadata {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String duration;
  final String publishedAt;
  final String channelTitle;
  final List<String> tags;

  YouTubeVideoMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.publishedAt,
    required this.channelTitle,
    required this.tags,
  });

  factory YouTubeVideoMetadata.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    
    // Get the best available thumbnail
    String thumbnailUrl = '';
    if (thumbnails['maxresdefault'] != null) {
      thumbnailUrl = thumbnails['maxresdefault']['url'];
    } else if (thumbnails['high'] != null) {
      thumbnailUrl = thumbnails['high']['url'];
    } else if (thumbnails['medium'] != null) {
      thumbnailUrl = thumbnails['medium']['url'];
    } else if (thumbnails['default'] != null) {
      thumbnailUrl = thumbnails['default']['url'];
    }

    return YouTubeVideoMetadata(
      id: json['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: thumbnailUrl,
      duration: json['contentDetails']?['duration'] ?? '',
      publishedAt: snippet['publishedAt'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      tags: List<String>.from(snippet['tags'] ?? []),
    );
  }

  /// Parse ISO 8601 duration to readable format
  String get readableDuration {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    
    if (match == null) return duration;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get parsed published date
  DateTime? get publishedDate {
    try {
      return DateTime.parse(publishedAt);
    } catch (e) {
      return null;
    }
  }
} 