import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationService {
  final SupabaseClient _supabase;
  ModerationService(this._supabase);

  Future<void> reportFeed({required String feedId, required String reason}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    await _supabase.from('feed_reports').insert({
      'feed_id': feedId,
      'reporter_id': userId,
      'reason': reason,
      'status': 'pending',
    });
  }

  Future<void> blockUserRemote({required String blockedUserId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    await _supabase.from('user_blocks').upsert({
      'blocker_id': userId,
      'blocked_id': blockedUserId,
    }, onConflict: 'blocker_id,blocked_id');
  }
}