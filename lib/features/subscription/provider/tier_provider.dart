import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/subscription_model.dart';
import '../service/tier_service.dart';

// Tier Service Provider
final tierServiceProvider = Provider<TierService>((ref) {
  return TierService();
});

// User Tier Info Provider
final userTierProvider = FutureProvider.family<UserTierInfo?, String>((ref, userId) async {
  final tierService = ref.read(tierServiceProvider);
  return await tierService.getUserTierInfo(userId);
});

// User Tier Notifier for state management
class UserTierNotifier extends AsyncNotifier<UserTierInfo?> {
  String? userId;

  @override
  Future<UserTierInfo?> build() async {
    // This will be set externally when creating the provider
    if (userId == null) return null;
    
    final tierService = ref.read(tierServiceProvider);
    return await tierService.getUserTierInfo(userId!);
  }

  Future<void> addPoints(String action, {int? customPoints}) async {
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    
    try {
      final tierService = ref.read(tierServiceProvider);
      
      final updatedTier = await tierService.addPoints(userId!, action, customPoints: customPoints);
      state = AsyncValue.data(updatedTier);
      
      // Refresh related providers
      ref.invalidate(tierStatsProvider(userId!));
      ref.invalidate(tierLeaderboardProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    
    try {
      final tierService = ref.read(tierServiceProvider);
      
      final tierInfo = await tierService.getUserTierInfo(userId!);
      state = AsyncValue.data(tierInfo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void setUserId(String newUserId) {
    userId = newUserId;
  }
}

final userTierNotifierProvider = AsyncNotifierProvider<UserTierNotifier, UserTierInfo?>(() {
  return UserTierNotifier();
});

// Tier Stats Provider
final tierStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final tierService = ref.read(tierServiceProvider);
  return await tierService.getTierStats(userId);
});

// Tier Leaderboard Provider
final tierLeaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final tierService = ref.read(tierServiceProvider);
  return await tierService.getTierLeaderboard(limit: 50);
});

// User Ranking Provider
final userRankingProvider = FutureProvider.family<int, String>((ref, userId) async {
  final tierService = ref.read(tierServiceProvider);
  return await tierService.getUserRanking(userId);
});

// Feature Access Provider
final featureAccessProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final tierService = ref.read(tierServiceProvider);
  return await tierService.hasFeatureAccess(params['userId']!, params['feature']!);
});

// Tier Benefits Provider
final tierBenefitsProvider = Provider.family<List<String>, UserTier>((ref, tier) {
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
});

// Tier Progress Provider
final tierProgressProvider = Provider.family<double, UserTierInfo>((ref, tierInfo) {
  if (tierInfo.currentTier == UserTier.prestige) {
    return 1.0; // Max tier reached
  }
  
  final currentTierThreshold = TierService.tierThresholds[tierInfo.currentTier]!;
  final progress = tierInfo.tierProgress.toDouble();
  final maxProgress = (tierInfo.nextTierThreshold - currentTierThreshold).toDouble();
  
  return maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;
});

// Points Actions Provider (for quick access to point values)
final pointsActionsProvider = Provider<Map<String, int>>((ref) {
  return TierService.actionPoints;
});

// Tier Thresholds Provider
final tierThresholdsProvider = Provider<Map<UserTier, int>>((ref) {
  return TierService.tierThresholds;
});

// Process Subscription Tier Points
final processSubscriptionTierPointsProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final tierService = ref.read(tierServiceProvider);
  await tierService.processSubscriptionTierPoints(params['userId'], params['planType']);
  
  // Refresh user tier info
  ref.invalidate(userTierProvider(params['userId']));
});

// Current User Tier Provider (simplified for UI)
final currentUserTierProvider = FutureProvider.family<UserTier, String>((ref, userId) async {
  final tierInfo = await ref.watch(userTierProvider(userId).future);
  return tierInfo?.currentTier ?? UserTier.gold;
});

// Next Tier Info Provider
final nextTierInfoProvider = Provider.family<Map<String, dynamic>, UserTierInfo>((ref, tierInfo) {
  UserTier? nextTier;
  int pointsNeeded = 0;
  
  switch (tierInfo.currentTier) {
    case UserTier.gold:
      nextTier = UserTier.platinum;
      pointsNeeded = tierInfo.nextTierThreshold - tierInfo.totalPoints;
      break;
    case UserTier.platinum:
      nextTier = UserTier.prestige;
      pointsNeeded = tierInfo.nextTierThreshold - tierInfo.totalPoints;
      break;
    case UserTier.prestige:
      nextTier = null; // Max tier
      pointsNeeded = 0;
      break;
  }
  
  return {
    'next_tier': nextTier,
    'points_needed': pointsNeeded,
    'is_max_tier': nextTier == null,
    'progress_percentage': ref.watch(tierProgressProvider(tierInfo)) * 100,
  };
});

// Tier Color Provider (for UI styling)
final tierColorsProvider = Provider.family<Map<String, dynamic>, UserTier>((ref, tier) {
  switch (tier) {
    case UserTier.gold:
      return {
        'primary': 0xFFFFD700,
        'secondary': 0xFFFFA500,
        'gradient': [0xFFFFD700, 0xFFFFA500],
        'name': 'Gold',
        'icon': 'emoji_events',
      };
    case UserTier.platinum:
      return {
        'primary': 0xFFE5E4E2,
        'secondary': 0xFFD3D3D3,
        'gradient': [0xFFE5E4E2, 0xFFD3D3D3],
        'name': 'Platinum',
        'icon': 'workspace_premium',
      };
    case UserTier.prestige:
      return {
        'primary': 0xFF9C27B0,
        'secondary': 0xFF673AB7,
        'gradient': [0xFF9C27B0, 0xFF673AB7],
        'name': 'Prestige',
        'icon': 'military_tech',
      };
  }
});

// Daily Login Points Provider
final dailyLoginPointsProvider = FutureProvider.family<bool, String>((ref, userId) async {
  // Check if user has already received daily login points today
  // This would typically check a database or cache
  return false; // Default to not claimed
});

// Tier Achievements Provider
final tierAchievementsProvider = Provider.family<List<Map<String, dynamic>>, UserTierInfo>((ref, tierInfo) {
  final achievements = <Map<String, dynamic>>[];
  
  // Points milestones
  final pointMilestones = [100, 500, 1000, 2000, 3000, 5000];
  for (final milestone in pointMilestones) {
    achievements.add({
      'id': 'points_$milestone',
      'title': '$milestone Points',
      'description': 'Earn $milestone total points',
      'completed': tierInfo.totalPoints >= milestone,
      'progress': (tierInfo.totalPoints / milestone).clamp(0.0, 1.0),
      'type': 'points',
      'reward': milestone ~/ 10, // Bonus points as reward
    });
  }
  
  // Tier achievements
  achievements.addAll([
    {
      'id': 'reach_platinum',
      'title': 'Platinum Member',
      'description': 'Reach Platinum tier',
      'completed': tierInfo.currentTier.index >= UserTier.platinum.index,
      'progress': tierInfo.currentTier.index >= UserTier.platinum.index ? 1.0 : 0.5,
      'type': 'tier',
      'reward': 100,
    },
    {
      'id': 'reach_prestige',
      'title': 'Prestige Elite',
      'description': 'Reach the highest Prestige tier',
      'completed': tierInfo.currentTier == UserTier.prestige,
      'progress': tierInfo.currentTier == UserTier.prestige ? 1.0 : 0.3,
      'type': 'tier',
      'reward': 500,
    },
  ]);
  
  return achievements;
}); 