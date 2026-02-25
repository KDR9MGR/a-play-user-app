import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../model/friendship_model.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Map<String, dynamic> _toFriendshipJson(
    Map<String, dynamic> row, {
    Map<String, dynamic>? friendProfile,
  }) {
    final createdAt = row['created_at'];
    final updatedAt = row['updated_at'];

    return {
      'id': row['id']?.toString() ?? '',
      'userId': row['user_id']?.toString() ?? '',
      'friendId': row['friend_id']?.toString() ?? '',
      'status': (row['status'] as String?) ?? 'accepted',
      'createdAt': createdAt is String ? createdAt : DateTime.now().toIso8601String(),
      'updatedAt': updatedAt is String ? updatedAt : DateTime.now().toIso8601String(),
      'friendName': friendProfile?['full_name'] ?? friendProfile?['email'],
      'friendUsername': friendProfile?['full_name'] ?? friendProfile?['email'],
      'friendAvatarUrl': friendProfile?['avatar_url'],
    };
  }

  Future<List<ChatParticipant>> getAllUsers({int limit = 50}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('profiles')
          .select('''
            id,
            full_name,
            avatar_url,
            email
          ''')
          .neq('id', userId)
          .order('full_name', ascending: true)
          .limit(limit);

      return response.map<ChatParticipant>((user) {
        final id = user['id'] as String;
        final username = (user['full_name'] as String?) ?? (user['email'] as String?);

        return ChatParticipant(
          id: id,
          chatRoomId: '',
          userId: id,
          username: username,
          avatarUrl: user['avatar_url'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserRoomParticipations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('chat_participants')
        .select('chat_room_id,last_read_at,left_at')
        .eq('user_id', userId);

    return (response as List).cast<Map<String, dynamic>>().where((row) {
      final leftAt = row['left_at'];
      return leftAt == null;
    }).toList();
  }

  Future<void> markRoomAsRead(String roomId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('chat_participants')
        .update({'last_read_at': DateTime.now().toIso8601String()})
        .eq('chat_room_id', roomId)
        .eq('user_id', userId);
  }

  // CHAT ROOMS
  Future<List<ChatRoom>> getUserChatRooms() async {
    try {
      print('Chat Service: Starting getUserChatRooms...');
      
      // Check authentication first
      final user = _client.auth.currentUser;
      final userId = user?.id;
      
      print('Chat Service: User: $user');
      print('Chat Service: User ID: $userId');
      print('Chat Service: User email: ${user?.email}');
      
      if (userId == null) {
        print('Chat Service: User not authenticated');
        throw Exception('User not authenticated. Please log in to view chat rooms.');
      }

      print('Chat Service: User is authenticated, fetching chat rooms...');
      
      // Query chat rooms that user has access to (RLS will handle filtering)
      final response = await _client
          .from('chat_rooms')
          .select('*')
          .order('updated_at', ascending: false);

      print('Chat Service: Raw response length: ${response.length}');
      
      if (response.isEmpty) {
        print('Chat Service: No chat rooms found for user $userId');
        print('Chat Service: This could mean:');
        print('  1. User is not in any chat room participant_ids');
        print('  2. RLS policies are blocking access');
        print('  3. User needs to be added to chat rooms');
        return [];
      }

      print('Chat Service: Sample room data: ${response.first}');

      final chatRooms = response.map((room) {
        try {
          return ChatRoom.fromJson(Map<String, dynamic>.from(room));
        } catch (e) {
          print('Chat Service: Error parsing room ${room['id']}: $e');
          print('Chat Service: Room data keys: ${room.keys.toList()}');
          rethrow;
        }
      }).toList();

      print('Chat Service: Successfully parsed ${chatRooms.length} chat rooms');
      return chatRooms;
    } catch (e, stackTrace) {
      print('Chat Service Error: $e');
      print('Chat Service Stack trace: $stackTrace');
      
      // Re-throw with more context
      if (e.toString().contains('not authenticated')) {
        throw Exception('Authentication required: Please log in to access chat rooms');
      } else if (e.toString().contains('RLS')) {
        throw Exception('Access denied: You do not have permission to view chat rooms');
      } else {
        throw Exception('Failed to fetch chat rooms: $e');
      }
    }
  }

  Future<ChatRoom> createChatRoom({
    required String name,
    required List<String> participantIds,
    bool isGroup = true,
    String? avatarUrl,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Create the chat room
      final roomResponse = await _client
          .from('chat_rooms')
          .insert({
            'name': name,
            'is_group': isGroup,
            'avatar_url': avatarUrl,
            'participant_ids': participantIds,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final roomId = roomResponse['id'];

      // Add participants to the room
      final participantsData = participantIds.map((participantId) => {
        'chat_room_id': roomId,
        'user_id': participantId,
        'role': participantId == userId ? 'admin' : 'member',
        'joined_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client.from('chat_participants').insert(participantsData);

      return ChatRoom.fromJson(roomResponse);
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  Future<ChatRoom> getOrCreateDirectChatRoom({
    required String otherUserId,
    required String otherDisplayName,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final participantRows = await _client
        .from('chat_participants')
        .select('chat_room_id,user_id,left_at')
        .inFilter('user_id', [userId, otherUserId]);

    final Map<String, Set<String>> roomParticipants = {};
    for (final row in (participantRows as List)) {
      final leftAt = row['left_at'];
      if (leftAt != null) continue;
      final roomId = row['chat_room_id'] as String?;
      final participantId = row['user_id'] as String?;
      if (roomId == null || participantId == null) continue;
      roomParticipants.putIfAbsent(roomId, () => <String>{}).add(participantId);
    }

    final candidateRoomIds = roomParticipants.entries
        .where((entry) => entry.value.contains(userId) && entry.value.contains(otherUserId))
        .map((entry) => entry.key)
        .toList();

    if (candidateRoomIds.isNotEmpty) {
      final rooms = await _client
          .from('chat_rooms')
          .select('*')
          .eq('is_group', false)
          .inFilter('id', candidateRoomIds);

      if ((rooms as List).isNotEmpty) {
        return ChatRoom.fromJson(Map<String, dynamic>.from(rooms.first));
      }
    }

    return createChatRoom(
      name: otherDisplayName,
      participantIds: [userId, otherUserId],
      isGroup: false,
    );
  }

  Future<void> joinChatRoom(String roomId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('chat_participants').insert({
        'chat_room_id': roomId,
        'user_id': userId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to join chat room: $e');
    }
  }

  Future<void> leaveChatRoom(String roomId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('chat_participants')
          .update({'left_at': DateTime.now().toIso8601String()})
          .eq('chat_room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to leave chat room: $e');
    }
  }

  // USER SEARCH
  Future<List<ChatParticipant>> searchUsers(String query) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('profiles')
          .select('''
            id,
            full_name,
            avatar_url,
            email
          ''')
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .neq('id', userId)
          .limit(20);

      return response.map<ChatParticipant>((user) {
        final id = user['id'] as String;
        final username = (user['full_name'] as String?) ?? (user['email'] as String?);

        return ChatParticipant(
          id: id,
          chatRoomId: '',
          userId: id,
          username: username,
          avatarUrl: user['avatar_url'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // MESSAGES
  Future<List<ChatMessage>> getRoomMessages(String roomId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select('''
            *,
            profiles!chat_messages_sender_id_fkey(full_name, email, avatar_url),
            message_reactions(*, profiles!message_reactions_user_id_fkey(full_name, email, avatar_url))
          ''')
          .eq('room_id', roomId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return response.map((message) {
        final messageData = Map<String, dynamic>.from(message);
        
        // Add sender info
        if (message['profiles'] != null) {
          messageData['senderName'] =
              message['profiles']['full_name'] ?? message['profiles']['email'];
          messageData['senderAvatarUrl'] = message['profiles']['avatar_url'];
        }

        // Add reactions
        if (message['message_reactions'] != null) {
          messageData['reactions'] = (message['message_reactions'] as List)
              .map((reaction) {
                final reactionData = Map<String, dynamic>.from(reaction);
                if (reaction['profiles'] != null) {
                  reactionData['userName'] =
                      reaction['profiles']['full_name'] ?? reaction['profiles']['email'];
                }
                return MessageReaction.fromJson(reactionData);
              })
              .toList();
        }

        return ChatMessage.fromJson(messageData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<ChatMessage> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? replyTo,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final messageData = {
        'content': content,
        'sender_id': userId,
        'room_id': roomId,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'reply_to': replyTo,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('chat_messages')
          .insert(messageData)
          .select('''
            *,
            profiles!chat_messages_sender_id_fkey(full_name, email, avatar_url)
          ''')
          .single();

      // Update room's last message
      await _client
          .from('chat_rooms')
          .update({
            'last_message': content,
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId);

      final messageResult = Map<String, dynamic>.from(response);
      if (response['profiles'] != null) {
        messageResult['senderName'] =
            response['profiles']['full_name'] ?? response['profiles']['email'];
        messageResult['senderAvatarUrl'] = response['profiles']['avatar_url'];
      }

      return ChatMessage.fromJson(messageResult);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _client
          .from('chat_messages')
          .update({
            'content': newContent,
            'is_edited': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _client
          .from('chat_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // MESSAGE REACTIONS
  Future<void> addReaction(String messageId, String emoji) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client.from('message_reactions').insert({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .eq('emoji', emoji);
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // FRIENDSHIPS
  Future<List<Friendship>> getUserFriendships() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('friendships')
          .select('id,user_id,friend_id,status,created_at,updated_at')
          .eq('user_id', userId)
          .eq('status', 'accepted')
          .order('created_at', ascending: false);

      final rows = (response as List).cast<Map<String, dynamic>>();
      final friendIds = rows.map((r) => r['friend_id']?.toString()).whereType<String>().toList();
      final profilesResponse = friendIds.isEmpty
          ? <Map<String, dynamic>>[]
          : (await _client
                  .from('profiles')
                  .select('id,full_name,email,avatar_url')
                  .inFilter('id', friendIds) as List)
              .cast<Map<String, dynamic>>();

      final profileById = <String, Map<String, dynamic>>{
        for (final p in profilesResponse) p['id'].toString(): p,
      };

      return rows.map((row) {
        final friendId = row['friend_id']?.toString();
        final friendProfile = friendId == null ? null : profileById[friendId];
        return Friendship.fromJson(_toFriendshipJson(row, friendProfile: friendProfile));
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch friendships: $e');
    }
  }

  Future<Friendship> sendFriendRequest(String friendId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('friendships')
          .upsert({
            'user_id': userId,
            'friend_id': friendId,
            'status': 'accepted',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,friend_id')
          .select('id,user_id,friend_id,status,created_at,updated_at')
          .single();

      final friendProfile = await _client
          .from('profiles')
          .select('id,full_name,email,avatar_url')
          .eq('id', friendId)
          .maybeSingle();

      return Friendship.fromJson(
        _toFriendshipJson(
          Map<String, dynamic>.from(response),
          friendProfile: friendProfile == null ? null : Map<String, dynamic>.from(friendProfile),
        ),
      );
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _client
          .from('friendships')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', friendshipId);
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  Future<void> blockUser(String friendId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('friendships')
          .upsert({
            'user_id': userId,
            'friend_id': friendId,
            'status': 'blocked',
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // REAL-TIME SUBSCRIPTIONS
  RealtimeChannel subscribeToRoomMessages(String roomId, Function(ChatMessage) onMessage) {
    return _client
        .channel('room_messages_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            try {
              final message = ChatMessage.fromJson(payload.newRecord);
              onMessage(message);
            } catch (e) {
              print('Error parsing real-time message: $e');
            }
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToUserRooms(Function(ChatRoom) onRoomUpdate) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return _client
        .channel('user_rooms_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_rooms',
          callback: (payload) {
            try {
              final room = ChatRoom.fromJson(payload.newRecord);
              onRoomUpdate(room);
            } catch (e) {
              print('Error parsing real-time room update: $e');
            }
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToParticipantChangesForUser(
      String userId, void Function(Map<String, dynamic> record, String event) onChange) {
    final channel = _client.channel('participants_$userId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_participants',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        onChange(payload.newRecord, 'insert');
      },
    );
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'chat_participants',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        onChange(payload.newRecord, 'update');
      },
    );
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'chat_participants',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        onChange(payload.oldRecord, 'delete');
      },
    );
    channel.subscribe();
    return channel;
  }

  RealtimeChannel subscribeToAllNewMessages(Function(Map<String, dynamic>) onInsert) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return _client
        .channel('all_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();
  }

  void unsubscribe(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }

  // UTILITY METHODS
  Future<List<ChatParticipant>> getRoomParticipants(String roomId) async {
    try {
      final response = await _client
          .from('chat_participants')
          .select('''
            *,
            profiles:user_id(full_name, email, avatar_url)
          ''')
          .eq('chat_room_id', roomId)
          .or('left_at.is.null,left_at.eq.null');

      return response.map((participant) {
        final participantData = Map<String, dynamic>.from(participant);
        if (participant['profiles'] != null) {
          participantData['username'] =
              participant['profiles']['full_name'] ?? participant['profiles']['email'];
          participantData['avatarUrl'] = participant['profiles']['avatar_url'];
        }
        return ChatParticipant.fromJson(participantData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch room participants: $e');
    }
  }

  Future<ChatRoom> getGlobalChatRoom() async {
    try {
      final response = await _client
          .from('chat_rooms')
          .select()
          .eq('name', 'Global Chat')
          .single();

      return ChatRoom.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch global chat room: $e');
    }
  }
}
