import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

// User Tier System
enum UserTier {
  @JsonValue('gold')
  gold,
  @JsonValue('platinum') 
  platinum,
  @JsonValue('prestige')
  prestige,
}

@freezed
class UserTierInfo with _$UserTierInfo {
  const factory UserTierInfo({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'current_tier') required UserTier currentTier,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'tier_progress') @Default(0) int tierProgress,
    @JsonKey(name: 'next_tier_threshold') required int nextTierThreshold,
    @JsonKey(name: 'tier_benefits') List<String>? tierBenefits,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserTierInfo;

  factory UserTierInfo.fromJson(Map<String, dynamic> json) => 
      _$UserTierInfoFromJson(json);

  // Helper methods for tier management
  factory UserTierInfo.newUser(String userId) {
    return UserTierInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      currentTier: UserTier.gold,
      totalPoints: 0,
      tierProgress: 0,
      nextTierThreshold: 1000, // Points needed for Platinum
      tierBenefits: _getTierBenefits(UserTier.gold),
      createdAt: DateTime.now(),
    );
  }

  static List<String> _getTierBenefits(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return ['Basic podcast access', 'Standard quality streaming', 'Monthly newsletter'];
      case UserTier.platinum:
        return ['Premium podcast access', 'HD quality streaming', 'Weekly newsletter', 'Early access to new content', 'Ad-free experience'];
      case UserTier.prestige:
        return ['Exclusive premium content', '4K quality streaming', 'Daily newsletter', 'VIP early access', 'Ad-free experience', 'Direct creator messaging', 'Exclusive events access'];
    }
  }
}

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'duration_days') required int durationDays,
    required double price,
    @Default('GHS') String currency,
    @JsonKey(name: 'plan_type') required SubscriptionPlanType planType,
    @JsonKey(name: 'tier_points_bonus') @Default(0) int tierPointsBonus,
    Map<String, dynamic>? features,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'is_popular') @Default(false) bool isPopular,
    @JsonKey(name: 'discount_percentage') double? discountPercentage,
    @JsonKey(name: 'original_price') double? originalPrice,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionPlanFromJson(json);

  // Predefined subscription plans as per client requirements
  static List<SubscriptionPlan> get defaultPlans => [
    // 3-Day Free Trial
    SubscriptionPlan(
      id: 'trial_plan',
      name: '3-Day Free Trial',
      description: 'Experience all premium features completely free',
      durationDays: 3,
      price: 0.0,
      planType: SubscriptionPlanType.trial,
      tierPointsBonus: 25,
      features: const {
        'premium_content': true,
        'hd_streaming': true,
        'offline_download': true,
        'ad_free': true,
        'is_trial': true,
      },
      isActive: true,
      isPopular: true,
      createdAt: DateTime.now(),
    ),
    SubscriptionPlan(
      id: 'weekly_plan',
      name: 'Weekly Access',
      description: 'Perfect for trying out our premium features',
      durationDays: 7,
      price: 20.0,
      planType: SubscriptionPlanType.weekly,
      tierPointsBonus: 50,
      features: const {
        'premium_content': true,
        'hd_streaming': true,
        'offline_download': false,
        'ad_free': false,
      },
      isActive: true,
      createdAt: DateTime.now(),
    ),
         SubscriptionPlan(
       id: 'monthly_plan', 
       name: 'Monthly Premium',
       description: 'Most popular choice for regular users',
       durationDays: 30,
       price: 69.99,
       planType: SubscriptionPlanType.monthly,
       tierPointsBonus: 200,
       isPopular: true,
       features: const {
         'premium_content': true,
         'hd_streaming': true,
         'offline_download': true,
         'ad_free': true,
       },
       isActive: true,
       createdAt: DateTime.now(),
     ),
     SubscriptionPlan(
       id: 'quarterly_plan',
       name: '3-Month Bundle',
       description: 'Save more with our quarterly plan',
       durationDays: 90,
       price: 199.99,
       originalPrice: 209.97,
       discountPercentage: 5.0,
       planType: SubscriptionPlanType.quarterly,
       tierPointsBonus: 650,
       features: const {
         'premium_content': true,
         'hd_streaming': true,
         'offline_download': true,
         'ad_free': true,
         'exclusive_content': true,
       },
       isActive: true,
       createdAt: DateTime.now(),
     ),
     SubscriptionPlan(
       id: 'biannual_plan',
       name: '6-Month Premium',
       description: 'Best value for serious podcast enthusiasts',
       durationDays: 180,
       price: 400.99,
       originalPrice: 419.94,
       discountPercentage: 4.5,
       planType: SubscriptionPlanType.biannual,
       tierPointsBonus: 1400,
       features: const {
         'premium_content': true,
         'hd_streaming': true,
         'offline_download': true,
         'ad_free': true,
         'exclusive_content': true,
         'priority_support': true,
       },
       isActive: true,
       createdAt: DateTime.now(),
     ),
     SubscriptionPlan(
       id: 'annual_plan',
       name: 'Annual Ultimate',
       description: 'Ultimate experience with maximum savings',
       durationDays: 365,
       price: 73.99,
       currency: 'USD',
       planType: SubscriptionPlanType.annual,
       tierPointsBonus: 3000,
       features: const {
         'premium_content': true,
         'hd_streaming': true,
         'offline_download': true,
         'ad_free': true,
         'exclusive_content': true,
         'priority_support': true,
         'early_access': true,
         'creator_meetups': true,
       },
       isActive: true,
       createdAt: DateTime.now(),
     ),
  ];
}

enum SubscriptionPlanType {
  @JsonValue('trial')
  trial,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('biannual')
  biannual,
  @JsonValue('annual')
  annual,
}

@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'subscription_type') required String subscriptionType,
    @JsonKey(name: 'plan_type') required SubscriptionPlanType planType,
    required double amount,
    required String currency,
    required String status,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'is_auto_renew') required bool isAutoRenew,
    @JsonKey(name: 'tier_points_earned') @Default(0) int tierPointsEarned,
    @JsonKey(name: 'features_unlocked') List<String>? featuresUnlocked,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) => 
      _$UserSubscriptionFromJson(json);
}

// Extension methods for UserSubscription
extension UserSubscriptionExtension on UserSubscription {
  bool get isTrial => planType == SubscriptionPlanType.trial;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => status == 'active' && !isExpired;
}

// Extension for static methods
extension UserSubscriptionStaticExtension on UserSubscription {
  // Check if user has used their free trial
  static Future<bool> hasUsedTrial(String userId) async {
    // This would be implemented in the service layer
    return false;
  }
}

@freezed
class SubscriptionPayment with _$SubscriptionPayment {
  const factory SubscriptionPayment({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    required double amount,
    required String currency,
    @JsonKey(name: 'payment_reference') required String paymentReference,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'payment_status') required String paymentStatus,
    @JsonKey(name: 'payment_date') required DateTime paymentDate,
    @JsonKey(name: 'tier_points_awarded') @Default(0) int tierPointsAwarded,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SubscriptionPayment;

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionPaymentFromJson(json);
}

// PayStack verification response model
@freezed
class PaystackVerification with _$PaystackVerification {
  const factory PaystackVerification({
    required bool status,
    required String message,
    Map<String, dynamic>? data,
  }) = _PaystackVerification;

  factory PaystackVerification.fromJson(Map<String, dynamic> json) => 
      _$PaystackVerificationFromJson(json);
      
  // Add a fallback factory method for when the model isn't generated yet
  factory PaystackVerification.fallback(Map<String, dynamic> json) {
    return PaystackVerification(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown response',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}