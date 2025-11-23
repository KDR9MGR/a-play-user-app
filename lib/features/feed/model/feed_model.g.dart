// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedModelImpl _$$FeedModelImplFromJson(Map<String, dynamic> json) =>
    _$FeedModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      eventId: json['event_id'] as String?,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FeedModelImplToJson(_$FeedModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'event_id': instance.eventId,
      'is_liked': instance.isLiked,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$FeedCommentImpl _$$FeedCommentImplFromJson(Map<String, dynamic> json) =>
    _$FeedCommentImpl(
      id: json['id'] as String,
      feedId: json['feed_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FeedCommentImplToJson(_$FeedCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feed_id': instance.feedId,
      'user_id': instance.userId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$FeedLikeImpl _$$FeedLikeImplFromJson(Map<String, dynamic> json) =>
    _$FeedLikeImpl(
      id: json['id'] as String,
      feedId: json['feed_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$FeedLikeImplToJson(_$FeedLikeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feed_id': instance.feedId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
    };
