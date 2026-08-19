import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../feed/service/moderation_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _moderationService = ModerationService(Supabase.instance.client);
  late Future<List<Map<String, dynamic>>> _blockedUsersFuture;

  @override
  void initState() {
    super.initState();
    _blockedUsersFuture = _moderationService.getBlockedUsers();
  }

  void _refresh() {
    setState(() {
      _blockedUsersFuture = _moderationService.getBlockedUsers();
    });
  }

  Future<void> _confirmUnblock(String userId, String displayName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Unblock User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Unblock $displayName? They will be able to message and interact with you again.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _moderationService.unblockUserRemote(blockedUserId: userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unblocked'), backgroundColor: Colors.green),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unblock: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Blocked Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _blockedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final blockedUsers = snapshot.data ?? [];
          if (blockedUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.security_user, size: 56, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No blocked users',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: blockedUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              final name = (user['full_name'] as String?)?.trim();
              final displayName = (name != null && name.isNotEmpty) ? name : (user['email'] as String? ?? 'Unknown user');
              final avatarUrl = user['avatar_url'] as String?;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null ? const Icon(Iconsax.profile_circle, color: Colors.white54) : null,
                  ),
                  title: Text(displayName, style: const TextStyle(color: Colors.white)),
                  trailing: OutlinedButton(
                    onPressed: () => _confirmUnblock(user['id'] as String, displayName),
                    child: const Text('Unblock'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
