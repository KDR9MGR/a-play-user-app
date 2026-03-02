import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsService {
  final _client = Supabase.instance.client;

  // Follow a user
  Future<void> followUser(String userId) async {
    try {
      await _client.from('follows').insert({
        'follower_id': _client.auth.currentUser!.id,
        'following_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String userId) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', _client.auth.currentUser!.id)
          .eq('following_id', userId);
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // Check if following a user
  Future<bool> isFollowing(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', _client.auth.currentUser!.id)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  // Get list of users the current user is following
  Future<List<Map<String, dynamic>>> getFollowing() async {
    try {
      final response = await _client
          .from('follows')
          .select('''
            following_id,
            created_at,
            profiles!follows_following_id_fkey(
              id,
              avatar_url,
              full_name,
              email
            )
          ''')
          .eq('follower_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get following list: $e');
    }
  }

  // Get list of users following the current user
  Future<List<Map<String, dynamic>>> getFollowers() async {
    try {
      final response = await _client
          .from('follows')
          .select('''
            follower_id,
            created_at,
            profiles!follows_follower_id_fkey(
              id,
              avatar_url,
              full_name,
              email
            )
          ''')
          .eq('following_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get followers list: $e');
    }
  }

  // Get mutual friends (people who follow each other)
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final response = await _client
          .from('friends')
          .select('''
            friend_id,
            created_at,
            profiles!friends_friend_id_fkey(
              id,
              avatar_url,
              full_name,
              email
            )
          ''')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get friends list: $e');
    }
  }

  // Check if two users are mutual friends
  Future<bool> areFriends(String userId) async {
    try {
      final response = await _client
          .from('friends')
          .select('user_id')
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('friend_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check friendship status: $e');
    }
  }

  // Search users (for adding friends)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;
      final response = await _client
          .from('profiles')
          .select('id, avatar_url, full_name, email')
          .neq('id', currentUserId) // Exclude current user
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
