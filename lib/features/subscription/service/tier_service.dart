import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/subscription_model.dart';

class TierService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Points thresholds for each tier
  static const Map<UserTier, int> tierThresholds = {
    UserTier.gold: 0,
    UserTier.platinum: 1000,
    UserTier.prestige: 3000,
  };

  // Points earned for different actions
  static const Map<String, int> actionPoints = {
    'subscription_weekly': 50,
    'subscription_monthly': 200,
    'subscription_quarterly': 650,
    'subscription_biannual': 1400,
    'subscription_annual': 3000,
    'content_watch': 5,
    'content_like': 2,
    'content_share': 10,
    'content_comment': 3,
    'referral_success': 100,
    'profile_complete': 50,
    'daily_login': 1,
  };

  Future<UserTierInfo?> getUserTierInfo(String userId) async {
    try {
      final response = await _supabase
          .from('user_tiers')
          .select()
          .eq('user_id', userId)
          .single();

      return UserTierInfo.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user tier info: $e');
      }
      // Create new tier info for user if doesn't exist
      return await createUserTierInfo(userId);
    }
  }

  Future<UserTierInfo> createUserTierInfo(String userId) async {
    final newTierInfo = UserTierInfo.newUser(userId);
    
    final response = await _supabase
        .from('user_tiers')
        .insert(newTierInfo.toJson())
        .select()
        .single();

    return UserTierInfo.fromJson(response);
  }

  Future<UserTierInfo> addPoints(String userId, String action, {int? customPoints}) async {
    final currentTier = await getUserTierInfo(userId);
    if (currentTier == null) return await createUserTierInfo(userId);

    final pointsToAdd = customPoints ?? actionPoints[action] ?? 0;
    final newTotalPoints = currentTier.totalPoints + pointsToAdd;
    
    // Determine new tier
    final newTier = _calculateTier(newTotalPoints);
    final nextTierThreshold = _getNextTierThreshold(newTier);
    
    final updatedTierInfo = currentTier.copyWith(
      totalPoints: newTotalPoints,
      currentTier: newTier,
      tierProgress: newTotalPoints - tierThresholds[newTier]!,
      nextTierThreshold: nextTierThreshold,
      tierBenefits: _getTierBenefits(newTier),
      updatedAt: DateTime.now(),
    );

    final response = await _supabase
        .from('user_tiers')
        .update(updatedTierInfo.toJson())
        .eq('user_id', userId)
        .select()
        .single();

    // Check if tier upgraded and send notification
    if (newTier != currentTier.currentTier) {
      await _handleTierUpgrade(userId, currentTier.currentTier, newTier);
    }

    return UserTierInfo.fromJson(response);
  }

  Future<void> _handleTierUpgrade(String userId, UserTier oldTier, UserTier newTier) async {
    // Create tier upgrade notification
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'type': 'tier_upgrade',
      'title': 'Tier Upgraded!',
      'message': 'Congratulations! You\'ve been upgraded to ${_getTierDisplayName(newTier)} tier.',
      'data': {
        'old_tier': oldTier.name,
        'new_tier': newTier.name,
        'benefits': _getTierBenefits(newTier),
      },
      'created_at': DateTime.now().toIso8601String(),
    });

    // Award tier upgrade bonus points
    final bonusPoints = _getTierUpgradeBonus(newTier);
    if (bonusPoints > 0) {
      await addPoints(userId, 'tier_upgrade', customPoints: bonusPoints);
    }
  }

  UserTier _calculateTier(int totalPoints) {
    if (totalPoints >= tierThresholds[UserTier.prestige]!) {
      return UserTier.prestige;
    } else if (totalPoints >= tierThresholds[UserTier.platinum]!) {
      return UserTier.platinum;
    } else {
      return UserTier.gold;
    }
  }

  int _getNextTierThreshold(UserTier currentTier) {
    switch (currentTier) {
      case UserTier.gold:
        return tierThresholds[UserTier.platinum]!;
      case UserTier.platinum:
        return tierThresholds[UserTier.prestige]!;
      case UserTier.prestige:
        return tierThresholds[UserTier.prestige]!; // Max tier
    }
  }

  List<String> _getTierBenefits(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return [
          'Basic podcast access',
          'Standard quality streaming',
          'Monthly newsletter',
          'Basic customer support',
        ];
      case UserTier.platinum:
        return [
          'Premium podcast access',
          'HD quality streaming',
          'Weekly newsletter',
          'Early access to new content',
          'Ad-free experience',
          'Priority customer support',
          '10% discount on merchandise',
        ];
      case UserTier.prestige:
        return [
          'Exclusive premium content',
          '4K quality streaming',
          'Daily newsletter',
          'VIP early access',
          'Ad-free experience',
          'Direct creator messaging',
          'Exclusive events access',
          'VIP customer support',
          '20% discount on merchandise',
          'Monthly exclusive meetups',
          'Beta feature access',
        ];
    }
  }

  String _getTierDisplayName(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 'Gold';
      case UserTier.platinum:
        return 'Platinum';
      case UserTier.prestige:
        return 'Prestige';
    }
  }

  int _getTierUpgradeBonus(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return 0;
      case UserTier.platinum:
        return 100;
      case UserTier.prestige:
        return 300;
    }
  }

  Future<List<UserTierInfo>> getTopUsers({int limit = 10}) async {
    final response = await _supabase
        .from('user_tiers')
        .select()
        .order('total_points', ascending: false)
        .limit(limit);

    return response.map((json) => UserTierInfo.fromJson(json)).toList();
  }

  Future<int> getUserRanking(String userId) async {
    final userTier = await getUserTierInfo(userId);
    if (userTier == null) return 0;

    final response = await _supabase
        .from('user_tiers')
        .select('user_id')
        .gt('total_points', userTier.totalPoints);

    return response.length + 1;
  }

  Future<Map<String, dynamic>> getTierStats(String userId) async {
    final userTier = await getUserTierInfo(userId);
    if (userTier == null) return {};

    final ranking = await getUserRanking(userId);
    final totalUsers = await _supabase.from('user_tiers').select('id').count();
    
    return {
      'current_tier': userTier.currentTier.name,
      'total_points': userTier.totalPoints,
      'tier_progress': userTier.tierProgress,
      'next_threshold': userTier.nextTierThreshold,
      'ranking': ranking,
      'total_users': totalUsers,
      'benefits': userTier.tierBenefits,
      'progress_percentage': (userTier.tierProgress / (userTier.nextTierThreshold - tierThresholds[userTier.currentTier]!)) * 100,
    };
  }

  Future<bool> hasFeatureAccess(String userId, String feature) async {
    final userTier = await getUserTierInfo(userId);
    if (userTier == null) return false;

    final tierFeatures = _getTierFeatures(userTier.currentTier);
    return tierFeatures.contains(feature);
  }

  List<String> _getTierFeatures(UserTier tier) {
    switch (tier) {
      case UserTier.gold:
        return [
          'basic_content',
          'standard_quality',
          'monthly_newsletter',
        ];
      case UserTier.platinum:
        return [
          'basic_content',
          'premium_content',
          'hd_quality',
          'ad_free',
          'early_access',
          'weekly_newsletter',
          'priority_support',
          'merchandise_discount_10',
        ];
      case UserTier.prestige:
        return [
          'basic_content',
          'premium_content',
          'exclusive_content',
          '4k_quality',
          'ad_free',
          'early_access',
          'vip_access',
          'creator_messaging',
          'exclusive_events',
          'daily_newsletter',
          'vip_support',
          'merchandise_discount_20',
          'exclusive_meetups',
          'beta_features',
        ];
    }
  }

  Future<void> processSubscriptionTierPoints(String userId, SubscriptionPlanType planType) async {
    String action = '';
    switch (planType) {
      case SubscriptionPlanType.trial:
        action = 'subscription_trial';
        break;
      case SubscriptionPlanType.weekly:
        action = 'subscription_weekly';
        break;
      case SubscriptionPlanType.monthly:
        action = 'subscription_monthly';
        break;
      case SubscriptionPlanType.quarterly:
        action = 'subscription_quarterly';
        break;
      case SubscriptionPlanType.biannual:
        action = 'subscription_biannual';
        break;
      case SubscriptionPlanType.annual:
        action = 'subscription_annual';
        break;
    }

    await addPoints(userId, action);
  }

  Future<List<Map<String, dynamic>>> getTierLeaderboard({int limit = 50}) async {
    final response = await _supabase
        .from('user_tiers')
        .select('''
          *,
          profiles!inner(
            id,
            username,
            avatar_url,
            full_name
          )
        ''')
        .order('total_points', ascending: false)
        .limit(limit);

    return response.map((item) {
      final tierInfo = UserTierInfo.fromJson(item);
      final profile = item['profiles'];
      
      return {
        'rank': response.indexOf(item) + 1,
        'user_id': tierInfo.userId,
        'username': profile['username'] ?? 'User ${response.indexOf(item) + 1}',
        'full_name': profile['full_name'],
        'avatar_url': profile['avatar_url'],
        'tier': tierInfo.currentTier.name,
        'total_points': tierInfo.totalPoints,
        'tier_display': _getTierDisplayName(tierInfo.currentTier),
      };
    }).toList();
  }
} 
