// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferralImpl _$$ReferralImplFromJson(Map<String, dynamic> json) =>
    _$ReferralImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      referralCode: json['referral_code'] as String,
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ReferralImplToJson(_$ReferralImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'referral_code': instance.referralCode,
      'referral_count': instance.referralCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$ReferralHistoryImpl _$$ReferralHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralHistoryImpl(
      id: json['id'] as String,
      userId: json['referred_user_id'] as String,
      referrerId: json['referrer_user_id'] as String,
      pointsEarned: (json['points_earned'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ReferralHistoryImplToJson(
        _$ReferralHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'referred_user_id': instance.userId,
      'referrer_user_id': instance.referrerId,
      'points_earned': instance.pointsEarned,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$PointTransactionImpl _$$PointTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$PointTransactionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      points: (json['points'] as num).toInt(),
      transactionType: json['transaction_type'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PointTransactionImplToJson(
        _$PointTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'points': instance.points,
      'transaction_type': instance.transactionType,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

_$MembershipTierImpl _$$MembershipTierImplFromJson(Map<String, dynamic> json) =>
    _$MembershipTierImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      minPoints: (json['min_points'] as num).toInt(),
      maxPoints: (json['max_points'] as num?)?.toInt(),
      benefits: json['benefits'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MembershipTierImplToJson(
        _$MembershipTierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'min_points': instance.minPoints,
      'max_points': instance.maxPoints,
      'benefits': instance.benefits,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$UserChallengeImpl _$$UserChallengeImplFromJson(Map<String, dynamic> json) =>
    _$UserChallengeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      challengeType: json['challenge_type'] as String,
      targetCount: (json['target_count'] as num).toInt(),
      periodDays: (json['period_days'] as num).toInt(),
      rewardPoints: (json['reward_points'] as num).toInt(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserChallengeImplToJson(_$UserChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'challenge_type': instance.challengeType,
      'target_count': instance.targetCount,
      'period_days': instance.periodDays,
      'reward_points': instance.rewardPoints,
      'active': instance.active,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$UserChallengeProgressImpl _$$UserChallengeProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$UserChallengeProgressImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      challenge: json['challenge'] == null
          ? null
          : UserChallenge.fromJson(json['challenge'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserChallengeProgressImplToJson(
        _$UserChallengeProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'challenge_id': instance.challengeId,
      'current_count': instance.currentCount,
      'start_date': instance.startDate.toIso8601String(),
      'completed': instance.completed,
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'challenge': instance.challenge,
    };

_$PointRedemptionImpl _$$PointRedemptionImplFromJson(
        Map<String, dynamic> json) =>
    _$PointRedemptionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pointsSpent: (json['points_spent'] as num).toInt(),
      rewardType: json['reward_type'] as String,
      rewardValue: (json['reward_value'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      redemptionCode: json['redemption_code'] as String?,
      affiliateId: json['affiliate_id'] as String?,
      settlementId: json['settlement_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      redeemedAt: json['redeemed_at'] == null
          ? null
          : DateTime.parse(json['redeemed_at'] as String),
    );

Map<String, dynamic> _$$PointRedemptionImplToJson(
        _$PointRedemptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'points_spent': instance.pointsSpent,
      'reward_type': instance.rewardType,
      'reward_value': instance.rewardValue,
      'description': instance.description,
      'status': instance.status,
      'redemption_code': instance.redemptionCode,
      'affiliate_id': instance.affiliateId,
      'settlement_id': instance.settlementId,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'redeemed_at': instance.redeemedAt?.toIso8601String(),
    };

_$AffiliateImpl _$$AffiliateImplFromJson(Map<String, dynamic> json) =>
    _$AffiliateImpl(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      category: json['category'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      address: json['address'] as String?,
      pointValueGhs: (json['point_value_ghs'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AffiliateImplToJson(_$AffiliateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_name': instance.businessName,
      'category': instance.category,
      'contact_name': instance.contactName,
      'contact_phone': instance.contactPhone,
      'contact_email': instance.contactEmail,
      'address': instance.address,
      'point_value_ghs': instance.pointValueGhs,
      'is_active': instance.isActive,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TimeLimitedOfferImpl _$$TimeLimitedOfferImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeLimitedOfferImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TimeLimitedOfferImplToJson(
        _$TimeLimitedOfferImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'multiplier': instance.multiplier,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'active': instance.active,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
