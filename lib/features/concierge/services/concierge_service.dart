
import 'package:a_play/features/chat/service/chat_service.dart';
import 'package:a_play/features/concierge/model/concierge_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConciergeService {
  final SupabaseClient _supabase;
  final ChatService _chatService;

  ConciergeService(this._supabase) : _chatService = ChatService(_supabase);

  // User Methods
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

      // TODO: Replace with actual concierge user ID
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

      return ConciergeRequest.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create concierge request: $e');
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
} 
