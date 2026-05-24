// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WatchProgressImpl _$$WatchProgressImplFromJson(Map<String, dynamic> json) =>
    _$WatchProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      videoId: json['videoId'] as String,
      watchedDuration: (json['watchedDuration'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      lastWatched: DateTime.parse(json['lastWatched'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WatchProgressImplToJson(_$WatchProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'videoId': instance.videoId,
      'watchedDuration': instance.watchedDuration,
      'totalDuration': instance.totalDuration,
      'lastWatched': instance.lastWatched.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
