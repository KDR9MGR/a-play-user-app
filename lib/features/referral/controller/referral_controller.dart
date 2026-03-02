import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/referral_model.dart';
import '../service/referral_service.dart';

// Service provider
final referralServiceProvider = Provider<ReferralService>((ref) {
  return ReferralService();
});

// Referral provider
final referralProvider = StateNotifierProvider<ReferralNotifier, AsyncValue<Referral?>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return ReferralNotifier(referralService, ref);
});

class ReferralNotifier extends StateNotifier<AsyncValue<Referral?>> {
  final ReferralService _referralService;
  final Ref _ref;

  ReferralNotifier(this._referralService, this._ref) : super(const AsyncLoading()) {
    _fetchUserReferral();
  }

  Future<void> _fetchUserReferral() async {
    try {
      state = const AsyncLoading();
      final referral = await _referralService.getUserReferral();
      state = AsyncData(referral);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> applyReferralCode(String code) async {
    try {
      await _referralService.applyReferralCode(code);
      // Refresh user points after applying referral code
      _ref.refresh(userPointsProvider);
    } catch (e) {
      // Handle error (could update state or just let the service handle it)
      rethrow;
    }
  }
}

// User Points provider
final userPointsProvider = StateNotifierProvider<UserPointsNotifier, AsyncValue<UserPoints?>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return UserPointsNotifier(referralService, ref);
});

class UserPointsNotifier extends StateNotifier<AsyncValue<UserPoints?>> {
  final ReferralService _referralService;
  final Ref _ref;

  UserPointsNotifier(this._referralService, this._ref) : super(const AsyncLoading()) {
    _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    try {
      state = const AsyncLoading();
      final points = await _referralService.getUserPoints();
      state = AsyncData(points);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> redeemPoints(int points, String purpose) async {
    try {
      await _referralService.redeemPoints(points, purpose);
      _fetchUserPoints(); // Refresh points after redemption
      _ref.refresh(pointTransactionsProvider); // Refresh transactions as well
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
  
  // Record daily login
  Future<bool> recordDailyLogin() async {
    try {
      final result = await _referralService.recordDailyLogin();
      if (result) {
        _fetchUserPoints(); // Refresh points if awarded
        _ref.refresh(pointTransactionsProvider);
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Award points for event booking
  Future<void> awardBookingPoints(double amountSpent) async {
    try {
      await _referralService.awardBookingPoints(amountSpent);
      _fetchUserPoints();
      _ref.refresh(pointTransactionsProvider);
      _ref.refresh(userChallengesProvider); // Refresh challenges progress
    } catch (e) {
      rethrow;
    }
  }
  
  // Award points for weekly subscription
  Future<void> awardSubscriptionPoints() async {
    try {
      await _referralService.awardSubscriptionPoints();
      _fetchUserPoints();
      _ref.refresh(pointTransactionsProvider);
      _ref.refresh(userChallengesProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // Award points for rating events
  Future<void> awardRatingPoints(String eventId) async {
    try {
      await _referralService.awardRatingPoints(eventId);
      _fetchUserPoints();
      _ref.refresh(pointTransactionsProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // Transfer points to another user
  Future<void> transferPoints(String recipientId, int points, String note) async {
    try {
      await _referralService.transferPoints(recipientId, points, note);
      _fetchUserPoints();
      _ref.refresh(pointTransactionsProvider);
    } catch (e) {
      rethrow;
    }
  }
  
  // Search user by username for transfers
  Future<Map<String, dynamic>> searchUserByUsername(String username) async {
    try {
      return await _referralService.searchUserByUsername(username);
    } catch (e) {
      rethrow;
    }
  }
}

// Point Transactions provider
final pointTransactionsProvider = StateNotifierProvider<PointTransactionsNotifier, AsyncValue<List<PointTransaction>>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return PointTransactionsNotifier(referralService);
});

class PointTransactionsNotifier extends StateNotifier<AsyncValue<List<PointTransaction>>> {
  final ReferralService _referralService;

  PointTransactionsNotifier(this._referralService) : super(const AsyncLoading()) {
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      state = const AsyncLoading();
      final transactions = await _referralService.getPointTransactions();
      state = AsyncData(transactions);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Membership Tiers provider
final membershipTiersProvider = StateNotifierProvider<MembershipTiersNotifier, AsyncValue<List<MembershipTier>>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return MembershipTiersNotifier(referralService);
});

class MembershipTiersNotifier extends StateNotifier<AsyncValue<List<MembershipTier>>> {
  final ReferralService _referralService;
  
  MembershipTiersNotifier(this._referralService) : super(const AsyncLoading()) {
    _fetchMembershipTiers();
  }
  
  Future<void> _fetchMembershipTiers() async {
    try {
      state = const AsyncLoading();
      final tiers = await _referralService.getMembershipTiers();
      state = AsyncData(tiers);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Time-limited offers provider
final timeOffersProvider = StateNotifierProvider<TimeOffersNotifier, AsyncValue<List<TimeLimitedOffer>>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return TimeOffersNotifier(referralService);
});

class TimeOffersNotifier extends StateNotifier<AsyncValue<List<TimeLimitedOffer>>> {
  final ReferralService _referralService;
  
  TimeOffersNotifier(this._referralService) : super(const AsyncLoading()) {
    _fetchTimeOffers();
  }
  
  Future<void> _fetchTimeOffers() async {
    try {
      state = const AsyncLoading();
      final offers = await _referralService.getActiveTimeOffers();
      state = AsyncData(offers);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// User Challenges provider
final userChallengesProvider = StateNotifierProvider<UserChallengesNotifier, AsyncValue<List<UserChallengeProgress>>>((ref) {
  final referralService = ref.watch(referralServiceProvider);
  return UserChallengesNotifier(referralService);
});

class UserChallengesNotifier extends StateNotifier<AsyncValue<List<UserChallengeProgress>>> {
  final ReferralService _referralService;
  
  UserChallengesNotifier(this._referralService) : super(const AsyncLoading()) {
    _fetchUserChallenges();
  }
  
  Future<void> _fetchUserChallenges() async {
    try {
      state = const AsyncLoading();
      final challenges = await _referralService.getUserChallenges();
      state = AsyncData(challenges);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
} 