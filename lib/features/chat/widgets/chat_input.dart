import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../authentication/presentation/providers/auth_provider.dart';
import '../controller/chat_controller.dart';
import '../model/chat_room_model.dart';

class ChatInput extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onMessageSent;

  const ChatInput({
    super.key,
    required this.chatRoom,
    this.onMessageSent,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      print('ERROR: User is null when trying to send message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages')),
      );
      return;
    }

    print('Sending message from user: ${user.id} to room: ${widget.chatRoom.id}');

    // Clear input immediately for better UX
    _messageController.clear();
    setState(() {
      _isTyping = false;
    });

    try {
      // Send message
      await ref.read(messageControllerProvider.notifier).sendMessage(
        roomId: widget.chatRoom.id,
        content: content,
      );

      // Callback for scrolling
      widget.onMessageSent?.call();
    } catch (e) {
      print('ERROR sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
      // Restore message in input
      _messageController.text = content;
      setState(() {
        _isTyping = content.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: Icon(Iconsax.attach_circle, color: Colors.grey[400]),
              onPressed: () {
                // TODO: Implement file attachment
              },
            ),
            
            // Message input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocus,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            Container(
              decoration: BoxDecoration(
                color: _isTyping ? Colors.blue[600] : Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isTyping ? Iconsax.send_1 : Iconsax.microphone,
                  color: Colors.white,
                ),
                onPressed: _isTyping ? _sendMessage : () {
                  // TODO: Implement voice message recording
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}