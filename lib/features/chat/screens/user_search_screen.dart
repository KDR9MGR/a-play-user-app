import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../controller/chat_controller.dart';
import 'chat_room_screen.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(userSearchProvider);
    final searchResults = ref.watch(searchResultsProvider(searchQuery));
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(userSearchProvider.notifier).state = value;
              },
            ),
          ),

          // Search results
          Expanded(
            child: searchResults.when(
              data: (users) {
                if (searchQuery.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for users to chat with',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.user_search,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final searchUser = users[index];
                    
                    // Don't show current user in search results
                    if (searchUser.userId == user?.id) return const SizedBox.shrink();

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
                      trailing: const Icon(
                        Iconsax.message,
                        color: Colors.grey,
                      ),
                      onTap: () async {
                        if (user == null) return;

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        // Create or get direct message chat room
                        final chatRoom = await ref
                            .read(chatControllerProvider.notifier)
                            .createRoom(
                              name: searchUser.username ?? 'Chat',
                              participantIds: [user.id, searchUser.userId],
                              isGroup: false,
                            );

                        // Close loading dialog
                        if (context.mounted) Navigator.of(context).pop();

                        if (context.mounted) {
                          // Navigate to chat room
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
                            ),
                          );
                        } else if (context.mounted) {
                          // Show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to create chat'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                      'Failed to search users',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}