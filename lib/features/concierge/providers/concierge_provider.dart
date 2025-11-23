import 'package:a_play/features/concierge/model/concierge_model.dart';
import 'package:a_play/features/concierge/services/concierge_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'concierge_provider.g.dart';

@riverpod
ConciergeService conciergeService(ConciergeServiceRef ref) {
  final supabase = Supabase.instance.client;
  return ConciergeService(supabase);
}

// User Providers
@riverpod
Future<ConciergeRequest> createConciergeRequest(
  CreateConciergeRequestRef ref, {
  required String category,
  required String serviceName,
  required String description,
  bool isUrgent = false,
  Map<String, dynamic>? additionalDetails,
}) async {
  final service = ref.watch(conciergeServiceProvider);
  return service.createRequest(
    category: category,
    serviceName: serviceName,
    description: description,
    isUrgent: isUrgent,
    additionalDetails: additionalDetails,
  );
}

@riverpod
Future<List<ConciergeRequest>> userConciergeRequests(
  UserConciergeRequestsRef ref,
) async {
  final service = ref.watch(conciergeServiceProvider);
  return service.getUserRequests();
}

@riverpod
Future<void> cancelConciergeRequest(
  CancelConciergeRequestRef ref,
  String requestId,
) async {
  final service = ref.watch(conciergeServiceProvider);
  await service.cancelRequest(requestId);
}

// Admin Providers
@riverpod
Future<List<ConciergeRequest>> allConciergeRequests(
  AllConciergeRequestsRef ref, {
  RequestStatus? statusFilter,
  bool? urgentOnly,
  String? categoryFilter,
}) async {
  final service = ref.watch(conciergeServiceProvider);
  return service.getAllRequests(
    statusFilter: statusFilter,
    urgentOnly: urgentOnly,
    categoryFilter: categoryFilter,
  );
}

@riverpod
Future<void> updateConciergeRequestStatus(
  UpdateConciergeRequestStatusRef ref,
  String requestId,
  RequestStatus newStatus,
) async {
  final service = ref.watch(conciergeServiceProvider);
  await service.updateRequestStatus(requestId, newStatus);
}

@riverpod
Future<void> updateConciergeRequestDetails(
  UpdateConciergeRequestDetailsRef ref,
  String requestId, {
  String? description,
  bool? isUrgent,
  Map<String, dynamic>? additionalDetails,
}) async {
  final service = ref.watch(conciergeServiceProvider);
  await service.updateRequestDetails(
    requestId,
    description: description,
    isUrgent: isUrgent,
    additionalDetails: additionalDetails,
  );
} 