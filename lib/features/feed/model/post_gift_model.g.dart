// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_gift_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostGiftImpl _$$PostGiftImplFromJson(Map<String, dynamic> json) =>
    _$PostGiftImpl(
      id: json['id'] as String,
      feedId: json['feed_id'] as String,
      gifterUserId: json['gifter_user_id'] as String,
      receiverUserId: json['receiver_user_id'] as String,
      pointsAmount: (json['points_amount'] as num).toInt(),
      message: json['message'] as String?,
      giftType: json['gift_type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      gifterName: json['gifter_name'] as String?,
      gifterAvatar: json['gifter_avatar'] as String?,
      receiverName: json['receiver_name'] as String?,
      receiverAvatar: json['receiver_avatar'] as String?,
    );

Map<String, dynamic> _$$PostGiftImplToJson(_$PostGiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feed_id': instance.feedId,
      'gifter_user_id': instance.gifterUserId,
      'receiver_user_id': instance.receiverUserId,
      'points_amount': instance.pointsAmount,
      'message': instance.message,
      'gift_type': instance.giftType,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'gifter_name': instance.gifterName,
      'gifter_avatar': instance.gifterAvatar,
      'receiver_name': instance.receiverName,
      'receiver_avatar': instance.receiverAvatar,
    };

_$GiftPresetImpl _$$GiftPresetImplFromJson(Map<String, dynamic> json) =>
    _$GiftPresetImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      pointsAmount: (json['points_amount'] as num).toInt(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$GiftPresetImplToJson(_$GiftPresetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'emoji': instance.emoji,
      'points_amount': instance.pointsAmount,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$PostGiftSummaryImpl _$$PostGiftSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$PostGiftSummaryImpl(
      totalGifts: (json['total_gifts'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      uniqueGifters: (json['unique_gifters'] as num?)?.toInt() ?? 0,
      giftBreakdown: (json['gift_breakdown'] as List<dynamic>?)
              ?.map((e) => GiftBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userHasGifted: json['user_has_gifted'] as bool? ?? false,
      userGiftType: json['user_gift_type'] as String?,
    );

Map<String, dynamic> _$$PostGiftSummaryImplToJson(
        _$PostGiftSummaryImpl instance) =>
    <String, dynamic>{
      'total_gifts': instance.totalGifts,
      'total_points': instance.totalPoints,
      'unique_gifters': instance.uniqueGifters,
      'gift_breakdown': instance.giftBreakdown,
      'user_has_gifted': instance.userHasGifted,
      'user_gift_type': instance.userGiftType,
    };

_$GiftBreakdownImpl _$$GiftBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$GiftBreakdownImpl(
      giftType: json['gift_type'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$GiftBreakdownImplToJson(_$GiftBreakdownImpl instance) =>
    <String, dynamic>{
      'gift_type': instance.giftType,
      'count': instance.count,
    };

_$GiftResponseImpl _$$GiftResponseImplFromJson(Map<String, dynamic> json) =>
    _$GiftResponseImpl(
      success: json['success'] as bool,
      error: json['error'] as String?,
      giftId: json['gift_id'] as String?,
      pointsGifted: (json['points_gifted'] as num?)?.toInt(),
      remainingPoints: (json['remaining_points'] as num?)?.toInt(),
      currentPoints: (json['current_points'] as num?)?.toInt(),
      requiredPoints: (json['required_points'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GiftResponseImplToJson(_$GiftResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'error': instance.error,
      'gift_id': instance.giftId,
      'points_gifted': instance.pointsGifted,
      'remaining_points': instance.remainingPoints,
      'current_points': instance.currentPoints,
      'required_points': instance.requiredPoints,
    };
