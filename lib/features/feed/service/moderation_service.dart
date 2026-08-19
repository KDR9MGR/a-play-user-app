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

  /// Removes a block record from the database. Previously there was no way
  /// to actually undo a block - BlockService.unblockUser only ever cleared a
  /// local SharedPreferences cache, never the real user_blocks row, so a
  /// "blocked" user stayed blocked server-side (and on any other device)
  /// forever regardless of what the local list said.
  Future<void> unblockUserRemote({required String blockedUserId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    await _supabase
        .from('user_blocks')
        .delete()
        .eq('blocker_id', userId)
        .eq('blocked_id', blockedUserId);
  }

  /// Lists the current user's blocked accounts, joined with public profile
  /// info for display. This (not the local-only BlockService list) is the
  /// authoritative source - it's what actually governs blocking everywhere
  /// else in the app. Two queries rather than a PostgREST embed: user_blocks
  /// only has a real FK to auth.users, not to the public_profiles view, so
  /// there's no embeddable relationship PostgREST can resolve directly.
  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final blocks = await _supabase
        .from('user_blocks')
        .select('blocked_id, created_at')
        .eq('blocker_id', userId)
        .order('created_at', ascending: false);
    final blockedIds = (blocks as List).map((b) => b['blocked_id'] as String).toList();
    if (blockedIds.isEmpty) return [];

    final profiles = await _supabase
        .from('public_profiles')
        .select('id, full_name, avatar_url, email')
        .inFilter('id', blockedIds);
    final profileById = {for (final p in profiles as List) p['id'] as String: p};

    return blockedIds
        .map((id) => profileById[id])
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}