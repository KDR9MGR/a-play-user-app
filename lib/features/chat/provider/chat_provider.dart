import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/chat_controller.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../model/friendship_model.dart';

// Provider instances for all chat controllers
final chatRoomsProvider = AsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
  () => ChatRoomsNotifier(),
);

final chatMessagesProvider = AsyncNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  () => ChatMessagesNotifier(),
);

final friendshipsProvider = AsyncNotifierProvider<FriendshipsNotifier, List<Friendship>>(
  () => FriendshipsNotifier(),
);

final roomParticipantsProvider = AsyncNotifierProvider<RoomParticipantsNotifier, List<ChatParticipant>>(
  () => RoomParticipantsNotifier(),
);

final globalChatRoomProvider = AsyncNotifierProvider<GlobalChatRoomNotifier, ChatRoom?>(
  () => GlobalChatRoomNotifier(),
);

// State providers for UI management
final selectedChatRoomProvider = StateProvider<ChatRoom?>((ref) => null);
final chatInputProvider = StateProvider<String>((ref) => '');
final isTypingProvider = StateProvider<bool>((ref) => false);

// Provider for current chat tab (Global, Groups, Friends)
final selectedChatTabProvider = StateProvider<ChatTab>((ref) => ChatTab.global);

enum ChatTab {
  global,
  groups, 
  friends,
}

extension ChatTabExtension on ChatTab {
  String get title {
    switch (this) {
      case ChatTab.global:
        return 'Global';
      case ChatTab.groups:
        return 'Groups';
      case ChatTab.friends:
        return 'Friends';
    }
  }
  
  String get description {
    switch (this) {
      case ChatTab.global:
        return 'Chat with everyone';
      case ChatTab.groups:
        return 'Group conversations';
      case ChatTab.friends:
        return 'Private messages';
    }
  }
}