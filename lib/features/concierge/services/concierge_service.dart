
import 'package:a_play/features/chat/service/chat_service.dart';
import 'package:a_play/features/concierge/model/concierge_model.dart';
import 'package:a_play/features/concierge/model/concierge_request_tracking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ConciergeService {
  final SupabaseClient _supabase;
  final ChatService _chatService;

  ConciergeService(this._supabase) : _chatService = ChatService();

  Future<ConciergeRequest> createRequest({
    required String category,
    required String serviceName,
    required String description,
    bool isUrgent = false,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user can create concierge request
      final canCreate = await canCreateRequest(user.id);
      if (!canCreate['allowed']) {
        throw Exception(canCreate['reason']);
      }

      const conciergeUserId = 'f5a7e3b0-1b7c-4b6e-8b0c-0b7c4b6e8b0c';

      final chatRoom = await _chatService.createChatRoom(
        name: 'Concierge Request: $serviceName',
        participantIds: [user.id, conciergeUserId],
        isGroup: false,
      );

      final response = await _supabase.from('concierge_requests').insert({
        'category': category,
        'service_name': serviceName,
        'description': description,
        'is_urgent': isUrgent,
        'additional_details': additionalDetails,
        'chat_room_id': chatRoom.id,
      }).select().single();

      // Track request for monthly limits (for Gold tier)
      await _trackMonthlyRequest(user.id);

      return ConciergeRequest.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create concierge request: $e');
    }
  }

  /// Check if user can create a concierge request based on subscription tier
  Future<Map<String, dynamic>> canCreateRequest(String userId) async {
    try {
      // Get user's active subscription
      final subscriptionResponse = await _supabase
          .from('user_subscriptions')
          .select('tier, plan_id, status')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (subscriptionResponse == null) {
        return {
          'allowed': false,
          'reason': 'Concierge service requires an active subscription. Please upgrade to Gold, Platinum, or Black tier.',
        };
      }

      final tier = subscriptionResponse['tier'] as String;

      // Free tier has no concierge access
      if (tier == 'Free') {
        return {
          'allowed': false,
          'reason': 'Concierge service is not available for Free tier. Please upgrade to Gold, Platinum, or Black.',
        };
      }

      // Get subscription plan features
      final planId = subscriptionResponse['plan_id'] as String;
      final planResponse = await _supabase
          .from('subscription_plans')
          .select('features')
          .eq('id', planId)
          .single();

      final features = planResponse['features'] as Map<String, dynamic>;

      // Check if plan includes concierge access
      if (features['concierge_access'] != true) {
        return {
          'allowed': false,
          'reason': 'Your subscription tier does not include concierge service. Please upgrade to a higher tier.',
        };
      }

      // For Gold tier, check monthly limits (3 requests/month)
      if (tier == 'Gold') {
        final requestsThisMonth = await _getMonthlyRequestCount(userId);
        if (requestsThisMonth >= 3) {
          return {
            'allowed': false,
            'reason': 'You have reached your monthly limit of 3 concierge requests. Upgrade to Platinum for unlimited requests.',
            'limit': 3,
            'used': requestsThisMonth,
          };
        }

        return {
          'allowed': true,
          'tier': tier,
          'limit': 3,
          'used': requestsThisMonth,
          'remaining': 3 - requestsThisMonth,
        };
      }

      // Platinum and Black have unlimited access
      return {
        'allowed': true,
        'tier': tier,
        'limit': null, // Unlimited
      };
    } catch (e) {
      debugPrint('Error checking concierge request eligibility: $e');
      return {
        'allowed': false,
        'reason': 'Unable to verify subscription status. Please try again.',
      };
    }
  }

  /// Get the number of concierge requests made this month
  Future<int> _getMonthlyRequestCount(String userId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final response = await _supabase
          .from('concierge_requests')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', firstDayOfMonth.toIso8601String())
          .lte('created_at', lastDayOfMonth.toIso8601String())
          .not('status', 'eq', 'cancelled');

      return response.length;
    } catch (e) {
      debugPrint('Error getting monthly request count: $e');
      return 0;
    }
  }

  /// Track monthly request for analytics
  Future<void> _trackMonthlyRequest(String userId) async {
    try {
      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      // Check if tracking record exists for this month
      final existingRecord = await _supabase
          .from('concierge_request_tracking')
          .select()
          .eq('user_id', userId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle();

      if (existingRecord != null) {
        // Increment count
        await _supabase
            .from('concierge_request_tracking')
            .update({
              'request_count': (existingRecord['request_count'] as int) + 1,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingRecord['id']);
      } else {
        // Create new tracking record
        await _supabase.from('concierge_request_tracking').insert({
          'user_id': userId,
          'month': month,
          'year': year,
          'request_count': 1,
        });
      }
    } catch (e) {
      debugPrint('Error tracking monthly request: $e');
      // Don't throw - tracking failure shouldn't prevent request creation
    }
  }

  Future<List<ConciergeRequest>> getUserRequests() async {
    try {
      final response = await _supabase
          .from('concierge_requests')
          .select()
          .order('created_at', ascending: false);

      return response
          .map((json) => ConciergeRequest.fromJson(json))
          .toList()
          .cast<ConciergeRequest>();
    } catch (e) {
      throw Exception('Failed to fetch user requests: $e');
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _supabase
          .from('concierge_requests')
          .update({'status': 'cancelled'})
          .match({'id': requestId} as Map<String, Object>);
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }

  // Admin Methods
  Future<List<ConciergeRequest>> getAllRequests({
    RequestStatus? statusFilter,
    bool? urgentOnly,
    String? categoryFilter,
  }) async {
    try {
      var query = _supabase.from('concierge_requests').select();

      final filters = <String, Object>{};
      
      if (statusFilter != null) {
        filters['status'] = statusFilter.name;
      }
      if (urgentOnly == true) {
        filters['is_urgent'] = true;
      }
      if (categoryFilter != null) {
        filters['category'] = categoryFilter;
      }

      if (filters.isNotEmpty) {
        query = query.match(filters);
      }

      final response = await query.order('created_at', ascending: false);

      return response
          .map((json) => ConciergeRequest.fromJson(json))
          .toList()
          .cast<ConciergeRequest>();
    } catch (e) {
      throw Exception('Failed to fetch all requests: $e');
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus newStatus,
  ) async {
    try {
      await _supabase
          .from('concierge_requests')
          .update({'status': newStatus.name})
          .match({'id': requestId} as Map<String, Object>);
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  Future<void> updateRequestDetails(
    String requestId, {
    String? description,
    bool? isUrgent,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final updates = <String, Object>{};
      if (description != null) updates['description'] = description;
      if (isUrgent != null) updates['is_urgent'] = isUrgent;
      if (additionalDetails != null) {
        updates['additional_details'] = additionalDetails;
      }

      if (updates.isEmpty) return;

      await _supabase
          .from('concierge_requests')
          .update(updates)
          .match({'id': requestId} as Map<String, Object>);
    } catch (e) {
      throw Exception('Failed to update request details: $e');
    }
  }

  /// Get the monthly tracking record for a user
  /// Returns null if no tracking record exists for the current month
  Future<ConciergeRequestTracking?> getMonthlyTracking(String userId) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('concierge_request_tracking')
          .select()
          .eq('user_id', userId)
          .eq('month', now.month)
          .eq('year', now.year)
          .maybeSingle();

      if (response == null) return null;
      return ConciergeRequestTracking.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching monthly tracking: $e');
      return null;
    }
  }

  /// Get tracking history for a user
  Future<List<ConciergeRequestTracking>> getTrackingHistory(String userId, {int? limit}) async {
    try {
      var query = _supabase
          .from('concierge_request_tracking')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: false)
          .order('month', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ConciergeRequestTracking.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tracking history: $e');
    }
  }
} 
