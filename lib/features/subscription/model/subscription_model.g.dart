// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserTierInfoImpl _$$UserTierInfoImplFromJson(Map<String, dynamic> json) =>
    _$UserTierInfoImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentTier: $enumDecode(_$UserTierEnumMap, json['current_tier']),
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      tierProgress: (json['tier_progress'] as num?)?.toInt() ?? 0,
      nextTierThreshold: (json['next_tier_threshold'] as num).toInt(),
      tierBenefits: (json['tier_benefits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserTierInfoImplToJson(_$UserTierInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'current_tier': _$UserTierEnumMap[instance.currentTier]!,
      'total_points': instance.totalPoints,
      'tier_progress': instance.tierProgress,
      'next_tier_threshold': instance.nextTierThreshold,
      'tier_benefits': instance.tierBenefits,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserTierEnumMap = {
  UserTier.gold: 'gold',
  UserTier.platinum: 'platinum',
  UserTier.prestige: 'prestige',
};

_$SubscriptionPlanImpl _$$SubscriptionPlanImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionPlanImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      priceMonthly: (json['price_monthly'] as num?)?.toDouble(),
      priceYearly: (json['price_yearly'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'GHS',
      planType:
          $enumDecodeNullable(_$SubscriptionPlanTypeEnumMap, json['plan_type']),
      tierPointsBonus: (json['tier_points_bonus'] as num?)?.toInt() ?? 0,
      features: json['features'] as Map<String, dynamic>?,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tierLevel: (json['tier_level'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SubscriptionPlanImplToJson(
        _$SubscriptionPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'duration_days': instance.durationDays,
      'price': instance.price,
      'price_monthly': instance.priceMonthly,
      'price_yearly': instance.priceYearly,
      'currency': instance.currency,
      'plan_type': _$SubscriptionPlanTypeEnumMap[instance.planType],
      'tier_points_bonus': instance.tierPointsBonus,
      'features': instance.features,
      'benefits': instance.benefits,
      'tier_level': instance.tierLevel,
      'is_active': instance.isActive,
      'is_popular': instance.isPopular,
      'discount_percentage': instance.discountPercentage,
      'original_price': instance.originalPrice,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$SubscriptionPlanTypeEnumMap = {
  SubscriptionPlanType.trial: 'trial',
  SubscriptionPlanType.weekly: 'weekly',
  SubscriptionPlanType.monthly: 'monthly',
  SubscriptionPlanType.quarterly: 'quarterly',
  SubscriptionPlanType.biannual: 'biannual',
  SubscriptionPlanType.annual: 'annual',
};

_$UserSubscriptionImpl _$$UserSubscriptionImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSubscriptionImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String?,
      tier: json['tier'] as String?,
      billingCycle: json['billing_cycle'] as String?,
      subscriptionType: json['subscription_type'] as String?,
      planType:
          $enumDecodeNullable(_$SubscriptionPlanTypeEnumMap, json['plan_type']),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      status: json['status'] as String,
      paymentReference: json['payment_reference'] as String?,
      paymentMethod: json['payment_method'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isAutoRenew: json['is_auto_renew'] as bool?,
      tierPointsEarned: (json['tier_points_earned'] as num?)?.toInt() ?? 0,
      featuresUnlocked: (json['features_unlocked'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rewardPoints: (json['reward_points'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      subscriptionPlan: json['subscription_plans'] == null
          ? null
          : SubscriptionPlan.fromJson(
              json['subscription_plans'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserSubscriptionImplToJson(
        _$UserSubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'plan_id': instance.planId,
      'tier': instance.tier,
      'billing_cycle': instance.billingCycle,
      'subscription_type': instance.subscriptionType,
      'plan_type': _$SubscriptionPlanTypeEnumMap[instance.planType],
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'payment_reference': instance.paymentReference,
      'payment_method': instance.paymentMethod,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'is_auto_renew': instance.isAutoRenew,
      'tier_points_earned': instance.tierPointsEarned,
      'features_unlocked': instance.featuresUnlocked,
      'reward_points': instance.rewardPoints,
      'referral_code': instance.referralCode,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'subscription_plans': instance.subscriptionPlan,
    };

_$SubscriptionPaymentImpl _$$SubscriptionPaymentImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionPaymentImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subscriptionId: json['subscription_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentReference: json['payment_reference'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      tierPointsAwarded: (json['tier_points_awarded'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SubscriptionPaymentImplToJson(
        _$SubscriptionPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'subscription_id': instance.subscriptionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_reference': instance.paymentReference,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_date': instance.paymentDate.toIso8601String(),
      'tier_points_awarded': instance.tierPointsAwarded,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$PaystackVerificationImpl _$$PaystackVerificationImplFromJson(
        Map<String, dynamic> json) =>
    _$PaystackVerificationImpl(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PaystackVerificationImplToJson(
        _$PaystackVerificationImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
