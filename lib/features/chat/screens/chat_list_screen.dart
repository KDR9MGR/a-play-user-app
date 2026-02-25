import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:a_play/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../provider/chat_provider.dart' hide friendshipsProvider;
import '../controller/chat_controller.dart';
import '../model/chat_room_model.dart';
import '../model/friendship_model.dart';
import 'chat_room_screen.dart';
import 'user_search_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _globalSearchController = TextEditingController();
  String _globalQuery = '';

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
    _globalSearchController.dispose();
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
      floatingActionButton: user == null
          ? null
          : AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index != 1) return const SizedBox.shrink();
                return FloatingActionButton(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                    );
                  },
                  child: const Icon(Iconsax.people),
                );
              },
            ),
      body: Column(
        children: [
          // Search Bar
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index != 0) return const SizedBox(height: 16);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _globalSearchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.grey[900],
                      hintText: 'Search users',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _globalQuery = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          
          // Chat Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
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
                _buildGlobalUsersTab(user),
                // Groups Chat Tab
                _buildGroupsChatTab(chatRoomsAsync, user),
                // Friends Chat Tab
                _buildFriendsTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalUsersTab(user) {
    final usersAsync = ref.watch(globalUsersProvider(_globalQuery));
    final friendshipsAsync = ref.watch(friendshipsProvider);
    final currentUserId = user?.id as String?;

    if (currentUserId == null) {
      return _buildEmptyState(
        icon: Iconsax.user,
        title: 'Sign in to chat',
        subtitle: 'Sign in to message users and add friends.',
        buttonText: 'Sign In',
        onPressed: () => context.push('/sign-in'),
      );
    }

    return usersAsync.when(
      data: (users) {
        final friendships = friendshipsAsync.maybeWhen(
          data: (value) => value,
          orElse: () => const <Friendship>[],
        );

        if (users.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.search_normal,
            title: 'No users found',
            subtitle: 'Try a different search.',
            buttonText: 'Search',
            onPressed: () {
              _globalSearchController.clear();
              setState(() {
                _globalQuery = '';
              });
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final u = users[index];
            final isFriend = friendships.any(
              (f) => f.friendId == u.userId && f.status == 'accepted',
            );

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                  child: u.avatarUrl == null
                      ? const Icon(Iconsax.user, color: Colors.white, size: 18)
                      : null,
                ),
                title: Text(
                  u.username ?? 'User',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.message, color: Colors.white),
                      onPressed: () async {
                        final room = await ref.read(chatServiceProvider).getOrCreateDirectChatRoom(
                              otherUserId: u.userId,
                              otherDisplayName: u.username ?? 'Chat',
                            );
                        ref.read(chatControllerProvider.notifier).refreshRooms();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ChatRoomScreen(chatRoom: room)),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isFriend ? Iconsax.tick_circle : Iconsax.user_add,
                        color: isFriend ? Colors.green : Colors.white,
                      ),
                      onPressed: isFriend
                          ? null
                          : () async {
                              await ref.read(friendshipsProvider.notifier).sendFriendRequest(u.userId);
                              await ref.read(friendshipsProvider.notifier).refreshFriendships();
                            },
                    ),
                  ],
                ),
              ),
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

  Widget _buildFriendsTab(user) {
    final currentUserId = user?.id as String?;
    if (currentUserId == null) {
      return _buildEmptyState(
        icon: Iconsax.user,
        title: 'Sign in to chat',
        subtitle: 'Sign in to message users and add friends.',
        buttonText: 'Sign In',
        onPressed: () => context.push('/sign-in'),
      );
    }

    final friendshipsAsync = ref.watch(friendshipsProvider);
    return friendshipsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _buildEmptyState(
            icon: Iconsax.user,
            title: 'No Friends',
            subtitle: 'Add users from Global to see them here.',
            buttonText: 'Find Users',
            onPressed: () => _tabController.animateTo(0),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final f = friends[index];
            final name = f.friendName ?? f.friendUsername ?? 'User';
            final avatarUrl = f.friendAvatarUrl;

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? const Icon(Iconsax.user, color: Colors.white, size: 18)
                      : null,
                ),
                title: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Iconsax.message, color: Colors.white),
                  onPressed: () async {
                    final room = await ref.read(chatServiceProvider).getOrCreateDirectChatRoom(
                          otherUserId: f.friendId,
                          otherDisplayName: name,
                        );
                    ref.read(chatControllerProvider.notifier).refreshRooms();
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ChatRoomScreen(chatRoom: room)),
                      );
                    }
                  },
                ),
              ),
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
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 2),
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
            onPressed: onPressed ??
                () {
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

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one user')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final participantIds = <String>[user.id, ..._selectedUserIds];
      final chatRoom = await ref.read(chatControllerProvider.notifier).createRoom(
            name: name,
            participantIds: participantIds,
            isGroup: true,
          );

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ChatRoomScreen(chatRoom: chatRoom)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      backgroundColor: AppTheme.backgroundMiddle,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'New Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: user == null ? null : _createGroup,
            child: Text(
              'Create',
              style: TextStyle(
                color: user == null ? Colors.white38 : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _groupNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value.trim();
                  });
                },
              ),
            ),
          ),
          if (_selectedUserIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_selectedUserIds.length} selected',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: resultsAsync.when(
              data: (users) {
                final filtered = users.where((u) => u.userId != user?.id).toList();

                if (_query.isEmpty) {
                  return const Center(
                    child: Text(
                      'Search for users to add',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final searchUser = filtered[index];
                    final selected = _selectedUserIds.contains(searchUser.userId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        backgroundImage: searchUser.avatarUrl != null
                            ? NetworkImage(searchUser.avatarUrl!)
                            : null,
                        child: searchUser.avatarUrl == null
                            ? const Icon(Iconsax.user, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        searchUser.username ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Checkbox(
                        value: selected,
                        activeColor: AppTheme.primary,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedUserIds.add(searchUser.userId);
                            } else {
                              _selectedUserIds.remove(searchUser.userId);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedUserIds.remove(searchUser.userId);
                          } else {
                            _selectedUserIds.add(searchUser.userId);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to search users: $error',
                  style: TextStyle(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
          color: AppTheme.primary.withValues(alpha: 0.2),
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
