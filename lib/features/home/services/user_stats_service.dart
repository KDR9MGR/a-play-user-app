import 'package:supabase_flutter/supabase_flutter.dart';

class UserStatsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get user's profile and points info from the view
      final userResponse = await _supabase
          .from('profiles_with_points')
          .select('full_name, avatar_url, is_premium, total_points, available_points, used_points')
          .eq('id', userId)
          .limit(1)
          .maybeSingle();

      final userPoints = (userResponse?['total_points'] as num?)?.toInt() ?? 0;
      final availablePoints = (userResponse?['available_points'] as num?)?.toInt() ?? 0;

      // Get total bookings count and calculate events attended
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id, status, amount, event_date')
          .eq('user_id', userId);

      final bookings = bookingsResponse as List<dynamic>;
      
      // Calculate stats
      final totalBookings = bookings.length;
      final completedBookings = bookings.where((b) => b['status'] == 'confirmed').length;
      final eventsAttended = bookings.where((b) => 
        b['status'] == 'confirmed' && 
        
        b['event_date'] != null && 
        DateTime.parse(b['event_date']).isBefore(DateTime.now())
      ).length;

      // Get membership tier based on points
      final membershipTier = await _getMembershipTier(userPoints);
      final tierProgress = await _calculateTierProgress(userPoints);

      final result = {
        'fullName': userResponse?['full_name'] ?? 'User',
        'avatarUrl': userResponse?['avatar_url'],
        'isPremium': userResponse?['is_premium'] ?? false,
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'eventsAttended': eventsAttended,
        'rewardPoints': userPoints,
        'availablePoints': availablePoints,
        'membershipTier': membershipTier['name'] ?? 'Bronze',
        'tierProgress': tierProgress['progress'] ?? 0.0,
        'pointsToNextTier': tierProgress['pointsToNext'] ?? 0,
        'nextTierName': tierProgress['nextTierName'] ?? 'Silver',
      };
      
      
      return result;
    } catch (e) {
      print('Error fetching user stats: $e');
      // Return default values if there's an error
      return {
        'fullName': 'User',
        'avatarUrl': null,
        'isPremium': false,
        'totalBookings': 0,
        'completedBookings': 0,
        'eventsAttended': 0,
        'rewardPoints': 0,
        'availablePoints': 0,
        'membershipTier': 'Bronze',
        'tierProgress': 0.0,
        'pointsToNextTier': 1000,
        'nextTierName': 'Silver',
      };
    }
  }

  Future<Map<String, dynamic>> _getMembershipTier(int userPoints) async {
    try {
      final tiersResponse = await _supabase
          .from('membership_tiers')
          .select('name, min_points, max_points')
          .order('min_points', ascending: true)
          .limit(10);

      final tiers = tiersResponse as List<dynamic>;
      
      for (final tier in tiers) {
        final minPoints = (tier['min_points'] as num).toInt();
        final maxPoints = (tier['max_points'] as num?)?.toInt();
        
        if (userPoints >= minPoints && (maxPoints == null || userPoints <= maxPoints)) {
          return tier;
        }
      }
      
      // Default to Bronze if no tier found
      return {'name': 'Bronze', 'min_points': 0, 'max_points': 1000};
    } catch (e) {
      return {'name': 'Bronze', 'min_points': 0, 'max_points': 1000};
    }
  }

  Future<Map<String, dynamic>> _calculateTierProgress(int userPoints) async {
    try {
      final tiersResponse = await _supabase
          .from('membership_tiers')
          .select('name, min_points, max_points')
          .order('min_points', ascending: true)
          .limit(10);

      final tiers = tiersResponse as List<dynamic>;
      
      
      // Find current tier and next tier
      Map<String, dynamic>? currentTier;
      Map<String, dynamic>? nextTier;
      
      // First find the current tier
      for (final tier in tiers) {
        final minPoints = (tier['min_points'] as num).toInt();
        final maxPoints = (tier['max_points'] as num?)?.toInt();
        
        if (userPoints >= minPoints && (maxPoints == null || userPoints <= maxPoints)) {
          currentTier = tier;
          break;
        }
      }
      
      // Then find the next tier (first tier with min_points > userPoints)
      for (final tier in tiers) {
        final minPoints = (tier['min_points'] as num).toInt();
        
        if (minPoints > userPoints) {
          nextTier = tier;
          break;
        }
      }
      
      if (currentTier == null) {
        return {
          'progress': 0.0,
          'pointsToNext': 1001,
          'nextTierName': 'Silver',
        };
      }
      
      if (nextTier == null) {
        // User is at the highest tier (Platinum)
        return {
          'progress': 1.0,
          'pointsToNext': 0,
          'nextTierName': 'Max Level',
        };
      }
      
      final currentMin = (currentTier['min_points'] as num).toInt();
      final currentMax = (currentTier['max_points'] as num?)?.toInt() ?? 0;
      final nextMin = (nextTier['min_points'] as num).toInt();
      
      // Calculate progress within current tier based on points.md formula
      // Example: User has 990 points in Bronze (0-1000)
      // Progress = 990 / 1000 = 0.99 (99% through Bronze)
      // Points to next = 1001 - 990 = 11 points to Silver
      final pointsInCurrentTier = userPoints - currentMin;
      final tierRange = currentMax > 0 ? (currentMax - currentMin + 1) : (nextMin - currentMin);
      final progress = tierRange > 0 ? pointsInCurrentTier / tierRange : 0.0;
      final pointsToNext = nextMin - userPoints;
      
      
      return {
        'progress': progress.clamp(0.0, 1.0),
        'pointsToNext': pointsToNext > 0 ? pointsToNext : 0,
        'nextTierName': nextTier['name'],
      };
    } catch (e) {
      return {
        'progress': 0.0,
        'pointsToNext': 1001,
        'nextTierName': 'Silver',
      };
    }
  }
}