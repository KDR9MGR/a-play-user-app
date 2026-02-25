import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../model/friendship_model.dart';
import '../service/chat_service.dart';

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final globalUsersProvider = FutureProvider.family<List<ChatParticipant>, String>((ref, query) async {
  final chatService = ref.read(chatServiceProvider);
  if (query.trim().isEmpty) {
    return chatService.getAllUsers();
  }
  return chatService.searchUsers(query.trim());
});

class UnreadMessagesCountNotifier extends AsyncNotifier<int> {
  late ChatService _chatService;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _participantsChannel;
  String? _userId;
  final Map<String, DateTime?> _lastReadByRoomId = {};
  final Set<String> _roomIds = {};
  KeepAliveLink? _keepAliveLink;
  bool _disposeRegistered = false;

  @override
  Future<int> build() async {
    _chatService = ref.read(chatServiceProvider);
    _userId = Supabase.instance.client.auth.currentUser?.id;
    if (_userId == null) return 0;

    if (_keepAliveLink == null) {
      _keepAliveLink = ref.keepAlive();
    }
    if (!_disposeRegistered) {
      _disposeRegistered = true;
      ref.onDispose(() {
        final chan = _messagesChannel;
        if (chan != null) {
          _chatService.unsubscribe(chan);
          _messagesChannel = null;
        }
        _keepAliveLink?.close();
        _keepAliveLink = null;
      });
    }

    List<Map<String, dynamic>> participations;
    try {
      participations = await _chatService.getUserRoomParticipations();
    } catch (_) {
      participations = [];
    }
    _roomIds
      ..clear()
      ..addAll(
        participations
            .map((p) => p['chat_room_id'])
            .whereType<String>()
            .toList(),
      );

    _lastReadByRoomId
      ..clear()
      ..addEntries(
        participations.map((p) {
          final roomId = p['chat_room_id'] as String?;
          final lastReadRaw = p['last_read_at'];
          DateTime? lastReadAt;
          if (lastReadRaw is String) {
            lastReadAt = DateTime.tryParse(lastReadRaw);
          }
          return MapEntry(roomId ?? '', lastReadAt);
        }).where((e) => e.key.isNotEmpty),
      );

    try {
      final globalRoom = await _chatService.getGlobalChatRoom();
      if (_roomIds.add(globalRoom.id)) {
        _lastReadByRoomId.putIfAbsent(globalRoom.id, () => null);
      }
    } catch (_) {}

    _messagesChannel = _chatService.subscribeToAllNewMessages((record) {
      final roomId = record['room_id'] as String?;
      final senderId = record['sender_id'] as String?;
      final createdAtRaw = record['created_at'];

      if (roomId == null || senderId == null) return;
      if (senderId == _userId) return;
      if (!_roomIds.contains(roomId)) return;

      DateTime? createdAt;
      if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw);
      }
      final lastReadAt = _lastReadByRoomId[roomId];
      if (createdAt != null && lastReadAt != null && !createdAt.isAfter(lastReadAt)) {
        return;
      }

      state = state.whenData((current) {
        if (current >= 100) return 100;
        return current + 1;
      });
    });

    _participantsChannel = _chatService.subscribeToParticipantChangesForUser(_userId!, (record, event) async {
      final rid = record['chat_room_id'] as String?;
      if (rid == null) return;
      if (event == 'delete') {
        _roomIds.remove(rid);
        _lastReadByRoomId.remove(rid);
      } else {
        final leftAt = record['left_at'];
        if (leftAt == null) {
          _roomIds.add(rid);
          DateTime? lastRead;
          final lastReadRaw = record['last_read_at'];
          if (lastReadRaw is String) {
            lastRead = DateTime.tryParse(lastReadRaw);
          }
          _lastReadByRoomId[rid] = lastRead;
        } else {
          _roomIds.remove(rid);
          _lastReadByRoomId.remove(rid);
        }
      }
      final newTotal = await _fetchUnreadCountCapped();
      state = AsyncValue.data(newTotal);
    });

    ref.onDispose(() {
      if (_messagesChannel != null) {
        _chatService.unsubscribe(_messagesChannel!);
      }
      if (_participantsChannel != null) {
        _chatService.unsubscribe(_participantsChannel!);
      }
    });

    return _fetchUnreadCountCapped();
  }

  Future<int> _fetchUnreadCountCapped() async {
    final userId = _userId;
    if (userId == null) return 0;

    var total = 0;
    for (final roomId in _roomIds) {
      final remaining = 100 - total;
      if (remaining <= 0) break;

      final lastReadAt = _lastReadByRoomId[roomId];
      var query = Supabase.instance.client
          .from('chat_messages')
          .select('id,created_at,sender_id')
          .eq('room_id', roomId)
          .neq('sender_id', userId);

      if (lastReadAt != null) {
        query = query.gt('created_at', lastReadAt.toIso8601String());
      }

      final data = await query.order('created_at', ascending: false).limit(remaining);
      total += (data as List).length;
    }

    return total;
  }
}

// Chat Rooms Controller
class ChatRoomsNotifier extends AsyncNotifier<List<ChatRoom>> {
  late ChatService _chatService;
  RealtimeChannel? _roomUpdatesChannel;

  @override
  Future<List<ChatRoom>> build() async {
    _chatService = ref.read(chatServiceProvider);
    _setupRealtimeSubscription();
    return _fetchRooms();
  }

  Future<List<ChatRoom>> _fetchRooms() async {
    try {
      return await _chatService.getUserChatRooms();
    } catch (e) {
      throw Exception('Failed to fetch chat rooms: $e');
    }
  }

  void _setupRealtimeSubscription() {
    _roomUpdatesChannel = _chatService.subscribeToUserRooms((updatedRoom) {
      state = state.whenData((rooms) {
        final updatedRooms = rooms.map((room) {
          return room.id == updatedRoom.id ? updatedRoom : room;
        }).toList();
        return updatedRooms;
      });
    });
  }

  Future<void> refreshRooms() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRooms());
  }

  Future<ChatRoom> createRoom({
    required String name,
    required List<String> participantIds,
    bool isGroup = true,
    String? avatarUrl,
  }) async {
    try {
      final newRoom = await _chatService.createChatRoom(
        name: name,
        participantIds: participantIds,
        isGroup: isGroup,
        avatarUrl: avatarUrl,
      );

      // Add the new room to the current state
      state = state.whenData((rooms) => [newRoom, ...rooms]);
      
      return newRoom;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await _chatService.joinChatRoom(roomId);
      await refreshRooms();
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _chatService.leaveChatRoom(roomId);
      state = state.whenData((rooms) => 
        rooms.where((room) => room.id != roomId).toList()
      );
    } catch (e) {
      throw Exception('Failed to leave room: $e');
    }
  }

  void dispose() {
    if (_roomUpdatesChannel != null) {
      _chatService.unsubscribe(_roomUpdatesChannel!);
    }
  }
}

// Chat Messages Controller
class ChatMessagesNotifier extends AsyncNotifier<List<ChatMessage>> {
  late ChatService _chatService;
  String? _currentRoomId;
  RealtimeChannel? _messagesChannel;

  @override
  Future<List<ChatMessage>> build() async {
    _chatService = ref.read(chatServiceProvider);
    return [];
  }

  Future<void> loadMessages(String roomId, {bool refresh = false}) async {
    if (_currentRoomId != roomId || refresh) {
      _currentRoomId = roomId;
      _setupRealtimeSubscription(roomId);
      
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchMessages(roomId));
    }
  }

  Future<List<ChatMessage>> _fetchMessages(String roomId) async {
    try {
      final messages = await _chatService.getRoomMessages(roomId);
      return _sortMessages(messages);
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  void _setupRealtimeSubscription(String roomId) {
    // Unsubscribe from previous channel
    if (_messagesChannel != null) {
      _chatService.unsubscribe(_messagesChannel!);
    }

    _messagesChannel = _chatService.subscribeToRoomMessages(roomId, (newMessage) {
      state = state.whenData((messages) {
        // Check if message already exists to avoid duplicates
        final messageExists = messages.any((m) => m.id == newMessage.id);
        if (!messageExists) {
          return _sortMessages([...messages, newMessage]);
        }
        return messages;
      });

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId != null && newMessage.senderId != currentUserId) {
        _chatService.markRoomAsRead(roomId);
        ref.invalidate(unreadMessagesCountProvider);
      }
    });

    _chatService.markRoomAsRead(roomId);
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? replyTo,
  }) async {
    try {
      final message = await _chatService.sendMessage(
        roomId: roomId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        replyTo: replyTo,
      );

      // Update local state immediately for better UX
      state = state.whenData((messages) => _sortMessages([...messages, message]));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  List<ChatMessage> _sortMessages(List<ChatMessage> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) {
      final timeCompare = a.createdAt.compareTo(b.createdAt);
      if (timeCompare != 0) return timeCompare;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _chatService.editMessage(messageId, newContent);
      
      // Update local state
      state = state.whenData((messages) {
        return messages.map((message) {
          if (message.id == messageId) {
            return message.copyWith(
              content: newContent,
              isEdited: true,
              updatedAt: DateTime.now(),
            );
          }
          return message;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      
      // Remove from local state
      state = state.whenData((messages) => 
        messages.where((message) => message.id != messageId).toList()
      );
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      await _chatService.addReaction(messageId, emoji);
      
      // Update local state with new reaction
      state = state.whenData((messages) {
        return messages.map((message) {
          if (message.id == messageId) {
            final newReaction = MessageReaction(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              messageId: messageId,
              userId: Supabase.instance.client.auth.currentUser?.id ?? '',
              emoji: emoji,
              createdAt: DateTime.now(),
            );
            
            return message.copyWith(
              reactions: [...message.reactions, newReaction],
            );
          }
          return message;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    try {
      await _chatService.removeReaction(messageId, emoji);
      
      // Update local state by removing reaction
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      state = state.whenData((messages) {
        return messages.map((message) {
          if (message.id == messageId) {
            final updatedReactions = message.reactions
                .where((reaction) => 
                  !(reaction.emoji == emoji && reaction.userId == currentUserId))
                .toList();
            
            return message.copyWith(reactions: updatedReactions);
          }
          return message;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  void dispose() {
    if (_messagesChannel != null) {
      _chatService.unsubscribe(_messagesChannel!);
    }
  }
}

// Friendships Controller
class FriendshipsNotifier extends AsyncNotifier<List<Friendship>> {
  late ChatService _chatService;

  @override
  Future<List<Friendship>> build() async {
    _chatService = ref.read(chatServiceProvider);
    return _fetchFriendships();
  }

  Future<List<Friendship>> _fetchFriendships() async {
    try {
      return await _chatService.getUserFriendships();
    } catch (e) {
      throw Exception('Failed to fetch friendships: $e');
    }
  }

  Future<void> refreshFriendships() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFriendships());
  }

  Future<Friendship> sendFriendRequest(String friendId) async {
    try {
      final friendship = await _chatService.sendFriendRequest(friendId);
      
      // Add to local state if accepted
      if (friendship.status == 'accepted') {
        state = state.whenData((friendships) => [friendship, ...friendships]);
      }
      
      return friendship;
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _chatService.acceptFriendRequest(friendshipId);
      await refreshFriendships();
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  Future<void> blockUser(String friendId) async {
    try {
      await _chatService.blockUser(friendId);
      
      // Remove from local state
      state = state.whenData((friendships) => 
        friendships.where((f) => f.friendId != friendId).toList()
      );
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }
}

// Room Participants Controller
class RoomParticipantsNotifier extends AsyncNotifier<List<ChatParticipant>> {
  late ChatService _chatService;

  @override
  Future<List<ChatParticipant>> build() async {
    _chatService = ref.read(chatServiceProvider);
    return [];
  }

  Future<void> loadParticipants(String roomId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      _chatService.getRoomParticipants(roomId)
    );
  }
}

// Global Chat Room Controller
class GlobalChatRoomNotifier extends AsyncNotifier<ChatRoom?> {
  late ChatService _chatService;

  @override
  Future<ChatRoom?> build() async {
    _chatService = ref.read(chatServiceProvider);
    return _fetchGlobalRoom();
  }

  Future<ChatRoom?> _fetchGlobalRoom() async {
    try {
      return await _chatService.getGlobalChatRoom();
    } catch (e) {
      print('Failed to fetch global chat room: $e');
      return null;
    }
  }
}

// Provider definitions
final chatControllerProvider = AsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(() {
  return ChatRoomsNotifier();
});

final messageControllerProvider = AsyncNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(() {
  return ChatMessagesNotifier();
});

final friendshipsProvider = AsyncNotifierProvider<FriendshipsNotifier, List<Friendship>>(() {
  return FriendshipsNotifier();
});

final roomParticipantsProvider = AsyncNotifierProvider<RoomParticipantsNotifier, List<ChatParticipant>>(() {
  return RoomParticipantsNotifier();
});

final globalChatRoomProvider = AsyncNotifierProvider<GlobalChatRoomNotifier, ChatRoom?>(() {
  return GlobalChatRoomNotifier();
});

// User Search Provider
final userSearchProvider = StateProvider<String>((ref) => '');

// Search Results Provider
final searchResultsProvider = FutureProvider.family<List<ChatParticipant>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final chatService = ref.read(chatServiceProvider);
  return await chatService.searchUsers(query);
});

final unreadMessagesCountProvider =
    AsyncNotifierProvider<UnreadMessagesCountNotifier, int>(() {
  return UnreadMessagesCountNotifier();
});
