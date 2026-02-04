import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/referral_model.dart';
import 'package:uuid/uuid.dart';

class ReferralService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get the current user ID
  String? get _userId => _client.auth.currentUser?.id;

  // Check if user is a subscriber
  Future<bool> _isUserSubscriber() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return false;
      }
      
      // Check if user has an active subscription
      final response = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get user's referral code
  Future<Referral?> getUserReferral() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is a subscriber
      final isSubscriber = await _isUserSubscriber();
      if (!isSubscriber) {
        // Return null for non-subscribers instead of throwing an exception
        return null;
      }

      final response = await _client
          .from('referrals')
          .select()
          .eq('user_id', userId)
          .single();

      return Referral.fromJson(response);
    } catch (e) {
      if (e.toString().contains('row not found')) {
        // Check if user is still a subscriber before creating referral code
        final isSubscriber = await _isUserSubscriber();
        if (!isSubscriber) {
          return null;
        }
        // Create a new referral code if one doesn't exist and user is a subscriber
        return await _createReferralCode();
      }
      throw Exception('Failed to fetch referral: $e');
    }
  }

  // Create a new referral code
  Future<Referral> _createReferralCode() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate a unique referral code (use user id as base)
      final referralCode = 'REF${userId.substring(0, 8).toUpperCase()}';

      final response = await _client.from('referrals').insert({
        'user_id': userId,
        'referral_code': referralCode,
        'referral_count': 0,
      }).select().single();

      return Referral.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create referral code: $e');
    }
  }

  // Apply someone else's referral code
  Future<void> applyReferralCode(String code) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // The RPC function will handle all the logic
      await _client.rpc('apply_referral_code', params: {
        'p_referral_code': code,
        'p_user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to apply referral code: $e');
    }
  }

  // Get user's points
  Future<UserPoints?> getUserPoints() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // The RPC function will handle all the logic
      final response = await _client
          .rpc('get_user_points_with_tier', params: {'p_user_id': userId})
          .select()
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserPoints.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user points: $e');
    }
  }

  // Create new user points record
  Future<UserPoints> _createUserPoints() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client.from('user_points').insert({
        'user_id': userId,
        'total_points': 0,
        'available_points': 0,
        'used_points': 0,
      }).select().single();

      final tier = await _getUserMembershipTier(0);
      final points = UserPoints.fromJson(response);

      return UserPoints(
        id: points.id,
        userId: points.userId,
        totalPoints: points.totalPoints,
        availablePoints: points.availablePoints,
        usedPoints: points.usedPoints,
        lastUpdated: points.lastUpdated,
        membershipTierName: tier?['name'],
      );
    } catch (e) {
      throw Exception('Failed to create user points: $e');
    }
  }

  // Get user's membership tier based on points
  Future<Map<String, dynamic>?> _getUserMembershipTier(int points) async {
    try {
      final response = await _client
          .from('membership_tiers')
          .select()
          .lte('min_points', points)
          .or('max_points.gte.$points,max_points.is.null')
          .order('min_points', ascending: false)
          .limit(1)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get all membership tiers
  Future<List<MembershipTier>> getMembershipTiers() async {
    try {
      final response = await _client
          .from('membership_tiers')
          .select()
          .order('min_points');
      
      return (response as List)
          .map((json) => MembershipTier.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch membership tiers: $e');
    }
  }

  // Redeem points
  Future<void> redeemPoints(int points, String purpose) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user has enough points
      final userPoints = await getUserPoints();
      if (userPoints == null || userPoints.availablePoints < points) {
        throw Exception('Not enough points available');
      }

      // Add a redemption transaction
      await _addPointsTransaction(userId, -points, 'redemption',
          'Points redeemed for $purpose');
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  // Add points transaction with optional additional metadata
  Future<void> _addPointsTransaction(
      String userId, int points, String type, String description, {Map<String, dynamic>? additionalMetadata}) async {
    try {
      // Check for active time-limited offers
      double multiplier = 1.0;
      String offerName = '';
      
      final offers = await _getActiveTimeOffers();
      if (offers.isNotEmpty && points > 0) {
        // Only apply multiplier to positive points (earning, not redeeming)
        multiplier = offers.first.multiplier;
        offerName = offers.first.name;
        points = (points * multiplier).round();
        description += ' ($offerName: ${multiplier}x points)';
      }

      Map<String, dynamic> metadata = {
        'multiplier': multiplier,
        'offer_name': offerName,
      };
      
      // Add any additional metadata
      if (additionalMetadata != null) {
        metadata.addAll(additionalMetadata);
      }

      // Generate a UUID for the id field
      final id = const Uuid().v4();

      await _client.from('point_transactions').insert({
        'id': id,
        'user_id': userId,
        'points': points,
        'transaction_type': type,
        'description': description,
        'metadata': metadata
      });

      // The points are automatically updated by a database trigger
    } catch (e) {
      throw Exception('Failed to add points transaction: $e');
    }
  }

  // Get user's point transactions
  Future<List<PointTransaction>> getPointTransactions() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('point_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PointTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }
  
  // Record daily login and award points
  Future<bool> recordDailyLogin() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if already logged in today
      final today = DateTime.now().toUtc().toString().split(' ')[0]; // YYYY-MM-DD
      
      final existingLogin = await _client
          .from('user_daily_logins')
          .select()
          .eq('user_id', userId)
          .eq('login_date', today)
          .maybeSingle();
      
      if (existingLogin != null) {
        if (existingLogin['points_awarded'] == true) {
          // Already awarded points today
          return false;
        }
        
        // Record exists but points not awarded yet
        await _client
            .from('user_daily_logins')
            .update({'points_awarded': true})
            .eq('id', existingLogin['id']);
      } else {
        // First login today
        await _client.from('user_daily_logins').insert({
          'user_id': userId,
          'login_date': today,
          'points_awarded': true,
        });
      }
      
      // Award 5 points for daily login
      await _addPointsTransaction(
        userId, 
        5, 
        'daily_login', 
        'Daily login reward'
      );
      
      return true;
    } catch (e) {
      throw Exception('Failed to record daily login: $e');
    }
  }
  
  // Award points for event booking (1 point per GH₵100 spent)
  Future<void> awardBookingPoints(double amountSpent) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Calculate points - 1 point per GH₵100
      final pointsEarned = (amountSpent / 100).floor();
      if (pointsEarned <= 0) return;
      
      await _addPointsTransaction(
        userId,
        pointsEarned,
        'booking',
        'Points for booking (GH₵${amountSpent.toStringAsFixed(2)})'
      );
      
      // Update user challenges related to bookings
      await _updateChallengeProgress('booking');
    } catch (e) {
      throw Exception('Failed to award booking points: $e');
    }
  }
  
  // Award points for weekly premium subscription
  Future<void> awardSubscriptionPoints() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Award 50 points for weekly premium subscription
      await _addPointsTransaction(
        userId,
        50,
        'subscription',
        'Weekly premium subscription'
      );
      
      // Check if this user was referred by someone
      final referralHistory = await _client
          .from('referral_history')
          .select()
          .eq('referred_user_id', userId)
          .maybeSingle();
      
      // If this is the user's first subscription after being referred, award points to both users
      if (referralHistory != null && referralHistory['points_earned'] == 0) {
        final referrerId = referralHistory['referrer_user_id'];
        
        // Award 100 points to referrer
        await _addPointsTransaction(
          referrerId, 
          100, 
          'referral',
          'Someone you referred subscribed to premium'
        );
        
        // Award 50 points to the referred user (this user)
        await _addPointsTransaction(
          userId, 
          50, 
          'referral',
          'You subscribed after using a referral code'
        );
        
        // Update referral history to mark points as earned
        await _client
            .from('referral_history')
            .update({'points_earned': 50})
            .eq('referred_user_id', userId);
      }
      
      // Update subscription streak challenge
      await _updateChallengeProgress('subscription');
    } catch (e) {
      throw Exception('Failed to award subscription points: $e');
    }
  }
  
  // Award points for rating/reviewing events
  Future<void> awardRatingPoints(String eventId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if already rated this event
      final existingRating = await _client
          .from('point_transactions')
          .select()
          .eq('user_id', userId)
          .eq('transaction_type', 'rating')
          .eq('metadata->event_id', eventId)
          .maybeSingle();
      
      if (existingRating != null) {
        throw Exception('You have already received points for rating this event');
      }
      
      // Award 10 points for rating
      await _addPointsTransaction(
        userId,
        10,
        'rating',
        'Rating an event',
        additionalMetadata: {'event_id': eventId}
      );
    } catch (e) {
      throw Exception('Failed to award rating points: $e');
    }
  }
  
  // Get active time-limited offers
  Future<List<TimeLimitedOffer>> _getActiveTimeOffers() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      
      final response = await _client
          .from('time_limited_offers')
          .select()
          .eq('active', true)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('multiplier', ascending: false);
      
      return (response as List)
          .map((json) => TimeLimitedOffer.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get active time-limited offers for display
  Future<List<TimeLimitedOffer>> getActiveTimeOffers() async {
    return _getActiveTimeOffers();
  }
  
  // Get active challenges for the user
  Future<List<UserChallengeProgress>> getUserChallenges() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // First get all available challenges
      final challenges = await _client
          .from('user_challenges')
          .select()
          .eq('active', true);
      
      // Get user progress
      final progress = await _client
          .from('user_challenge_progress')
          .select('*, challenge:challenge_id(*)')
          .eq('user_id', userId);
      
      final List<UserChallengeProgress> result = (progress as List)
          .map((json) => UserChallengeProgress.fromJson(json))
          .toList();
      
      // Add any challenges that the user hasn't started yet
      final existingChallengeIds = result
          .map((progress) => progress.challengeId)
          .toSet();
      
      for (final challenge in challenges) {
        if (!existingChallengeIds.contains(challenge['id'])) {
          // Create a new progress entry for this challenge
          final newProgress = await _client
              .from('user_challenge_progress')
              .insert({
                'user_id': userId,
                'challenge_id': challenge['id'],
                'current_count': 0,
                'start_date': DateTime.now().toUtc().toIso8601String(),
                'completed': false,
              })
              .select('*, challenge:challenge_id(*)')
              .single();
          
          result.add(UserChallengeProgress.fromJson(newProgress));
        }
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to fetch user challenges: $e');
    }
  }
  
  // Update challenge progress for the user
  Future<void> _updateChallengeProgress(String challengeType) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get relevant challenges
      final challengeProgress = await _client
          .from('user_challenge_progress ucp')
          .select('*, challenge:user_challenges!inner(*)')
          .eq('user_id', userId)
          .eq('completed', false)
          .eq('user_challenges.challenge_type', challengeType);
      
      // Process each challenge
      for (final progress in challengeProgress) {
        final challenge = progress['challenge'];
        final progressId = progress['id'];
        final currentCount = progress['current_count'] + 1;
        final targetCount = challenge['target_count'];
        final periodDays = challenge['period_days'];
        final startDate = DateTime.parse(progress['start_date']);
        
        // Check if challenge period has expired
        final now = DateTime.now().toUtc();
        final daysSinceStart = now.difference(startDate).inDays;
        
        if (daysSinceStart > periodDays) {
          // Period expired, reset challenge
          await _client
              .from('user_challenge_progress')
              .update({
                'current_count': 1, // Set to 1 for the current action
                'start_date': now.toIso8601String(),
              })
              .eq('id', progressId);
        } else if (currentCount >= targetCount) {
          // Challenge completed
          await _client
              .from('user_challenge_progress')
              .update({
                'current_count': currentCount,
                'completed': true,
                'completed_at': now.toIso8601String(),
              })
              .eq('id', progressId);
          
          // Award points for completing the challenge
          await _addPointsTransaction(
            userId,
            challenge['reward_points'],
            'challenge',
            'Completed challenge: ${challenge['name']}'
          );
        } else {
          // Update progress
          await _client
              .from('user_challenge_progress')
              .update({
                'current_count': currentCount,
              })
              .eq('id', progressId);
        }
      }
    } catch (e) {
      // Log but don't throw, to prevent disrupting the main flow
      if (kDebugMode) {
        print('Failed to update challenge progress: $e');
      }
    }
  }
  
  // Transfer points to another user
  Future<void> transferPoints(String recipientId, int points, String note) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      if (userId == recipientId) {
        throw Exception('Cannot transfer points to yourself');
      }
      
      // Check if sender has enough points
      final userPoints = await getUserPoints();
      if (userPoints == null || userPoints.availablePoints < points) {
        throw Exception('Insufficient points for transfer');
      }
      
      // Get sender's name
      final senderProfile = await _client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      
      final senderName = senderProfile?['full_name'] ?? 'User';
      
      // Check if recipient exists
      final recipient = await _client
          .from('profiles')
          .select('id, full_name')
          .eq('id', recipientId)
          .maybeSingle();
      
      if (recipient == null) {
        throw Exception('Recipient user not found');
      }
      final recipientName = recipient['full_name'] ?? 'User';
      
      final now = DateTime.now().toUtc();
      final transferId = const Uuid().v4();
      
      // Create transfer transaction for sender (debit)
      await _client.from('point_transactions').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'points': -points,
        'transaction_type': 'transfer_out',
        'description': 'Points transferred to $recipientName',
        'created_at': now.toIso8601String(),
        'metadata': {
          'transfer_id': transferId,
          'recipient_id': recipientId,
          'recipient_name': recipientName,
          'note': note.isNotEmpty ? note : null,
        },
      });
      
      // Create transfer transaction for recipient (credit)
      await _client.from('point_transactions').insert({
        'id': const Uuid().v4(),
        'user_id': recipientId,
        'points': points,
        'transaction_type': 'transfer_in',
        'description': 'Points received from $senderName',
        'created_at': now.toIso8601String(),
        'metadata': {
          'transfer_id': transferId,
          'sender_id': userId,
          'sender_name': senderName,
          'note': note.isNotEmpty ? note : null,
        },
      });
      
    } catch (e) {
      throw Exception('Transfer failed: $e');
    }
  }
  
  // Search user by username for transfers
  Future<Map<String, dynamic>> searchUserByUsername(String username) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final query = username.trim();
      final looksLikeUuid = RegExp(r'^[0-9a-fA-F-]{32,36}$').hasMatch(query);

      final builder = _client.from('profiles').select('id, full_name, avatar_url');

      final user = looksLikeUuid
          ? await builder.eq('id', query).neq('id', userId).maybeSingle()
          : await builder
              .ilike('full_name', '%$query%')
              .neq('id', userId)
              .limit(1)
              .maybeSingle();
      
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('User search failed: $e');
    }
  }
} 
