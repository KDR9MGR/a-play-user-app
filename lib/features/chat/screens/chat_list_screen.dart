import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:a_play/core/theme/app_theme.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../controller/chat_controller.dart';
import '../model/chat_room_model.dart';
import 'chat_room_screen.dart';
import 'user_search_screen.dart';
import 'friends_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        ref.read(chatControllerProvider.notifier).refreshRooms();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsAsync = ref.watch(chatControllerProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMiddle,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              user?.userMetadata?['username'] ?? user?.email.split('@')[0] ?? 'User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 16),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Colors.grey[900],
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserSearchScreen()),
                  );
                },
                readOnly: true,
              ),
            ),
          ),
          
          // Chat Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Iconsax.global, size: 18),
                  text: 'Global',
                ),
                Tab(
                  icon: Icon(Iconsax.people, size: 18),
                  text: 'Groups',
                ),
                Tab(
                  icon: Icon(Iconsax.user, size: 18),
                  text: 'Friends',
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Global Chat Tab
                _buildGlobalChatTab(chatRoomsAsync, user),
                // Groups Chat Tab
                _buildGroupsChatTab(chatRoomsAsync, user),
                // Friends Chat Tab
                _buildFriendsChatTab(chatRoomsAsync, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalChatTab(AsyncValue<List<ChatRoom>> chatRoomsAsync, user) {
    return chatRoomsAsync.when(
      data: (chatRooms) {
        // Filter for global chats (all public chats)
        final globalChats = chatRooms.where((room) => room.isGroup).toList();
        
        if (globalChats.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.global,
            title: 'No Global Chats',
            subtitle: 'Join the global community and start conversations',
            buttonText: 'Explore Global',
          );
        }
        
        return ListView.builder(
          itemCount: globalChats.length,
          itemBuilder: (context, index) {
            final chatRoom = globalChats[index];
            return ChatRoomTile(
              chatRoom: chatRoom,
              currentUserId: user?.id ?? '',
              onTap: () {
                ref.read(selectedChatRoomProvider.notifier).state = chatRoom;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, user),
    );
  }

  Widget _buildGroupsChatTab(AsyncValue<List<ChatRoom>> chatRoomsAsync, user) {
    return chatRoomsAsync.when(
      data: (chatRooms) {
        // Filter for group chats
        final groupChats = chatRooms.where((room) => room.isGroup).toList();
        
        if (groupChats.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.people,
            title: 'No Groups',
            subtitle: 'Create or join groups to start conversations',
            buttonText: 'Find Groups',
          );
        }
        
        return ListView.builder(
          itemCount: groupChats.length,
          itemBuilder: (context, index) {
            final chatRoom = groupChats[index];
            return ChatRoomTile(
              chatRoom: chatRoom,
              currentUserId: user?.id ?? '',
              onTap: () {
                ref.read(selectedChatRoomProvider.notifier).state = chatRoom;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, user),
    );
  }

  Widget _buildFriendsChatTab(AsyncValue<List<ChatRoom>> chatRoomsAsync, user) {
    return chatRoomsAsync.when(
      data: (chatRooms) {
        // Filter for direct/friend chats (non-group chats)
        final friendChats = chatRooms.where((room) => !room.isGroup).toList();
        
        if (friendChats.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.user,
            title: 'No Friends Chats',
            subtitle: 'Start a conversation with your friends',
            buttonText: 'Find Friends',
          );
        }
        
        return ListView.builder(
          itemCount: friendChats.length,
          itemBuilder: (context, index) {
            final chatRoom = friendChats[index];
            return ChatRoomTile(
              chatRoom: chatRoom,
              currentUserId: user?.id ?? '',
              onTap: () {
                ref.read(selectedChatRoomProvider.notifier).state = chatRoom;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, user),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserSearchScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load chats',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (user != null) {
                ref.read(chatControllerProvider.notifier).refreshRooms();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatRoomTile({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            // Profile Picture
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: chatRoom.avatarUrl != null
                    ? Image.network(
                        chatRoom.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: Icon(
                            chatRoom.isGroup ? Iconsax.people : Iconsax.user,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: Icon(
                          chatRoom.isGroup ? Iconsax.people : Iconsax.user,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom.lastMessageTime != null)
                        Text(
                          _formatTime(chatRoom.lastMessageTime!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (chatRoom.lastMessage != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatRoom.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Online status indicator (placeholder)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(time);
    } else if (difference.inHours > 0) {
      return DateFormat('HH:mm').format(time);
    } else {
      return DateFormat('HH:mm').format(time);
    }
  }
}