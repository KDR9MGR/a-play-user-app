import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../model/friendship_model.dart';
import '../service/chat_service.dart';

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

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
      return await _chatService.getRoomMessages(roomId);
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
          return [newMessage, ...messages];
        }
        return messages;
      });
    });
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
      state = state.whenData((messages) => [message, ...messages]);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
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