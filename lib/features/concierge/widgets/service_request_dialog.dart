
import 'package:a_play/features/chat/model/chat_room_model.dart';
import 'package:a_play/features/chat/screens/chat_room_screen.dart';
import 'package:a_play/features/chat/service/chat_service.dart';
import 'package:a_play/features/concierge/providers/concierge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ServiceRequestDialog extends ConsumerStatefulWidget {
  final String serviceType;
  final String serviceName;
  final List<String> features;

  const ServiceRequestDialog({
    super.key,
    required this.serviceType,
    required this.serviceName,
    required this.features,
  });

  @override
  ConsumerState<ServiceRequestDialog> createState() => _ServiceRequestDialogState();
}

class _ServiceRequestDialogState extends ConsumerState<ServiceRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late List<bool> _selectedFeatures;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedFeatures = List<bool>.filled(widget.features.length, false);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final selectedFeatures = widget.features
          .asMap()
          .entries
          .where((entry) => _selectedFeatures[entry.key])
          .map((entry) => entry.value)
          .toList();

      final request = await ref.read(createConciergeRequestProvider(
        category: widget.serviceType,
        serviceName: widget.serviceName,
        description: _descriptionController.text,
        additionalDetails: {
          'selectedFeatures': selectedFeatures,
        },
      ).future);

      final chatRoom = await ref.read(chatServiceProvider).getChatRoom(request.chatRoomId!);

      if (mounted) {
        Navigator.of(context).pop(true);
        context.push('/chat/${chatRoom.id}', extra: chatRoom);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.serviceName),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ...widget.features.asMap().entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.value),
                value: _selectedFeatures[entry.key],
                onChanged: (value) {
                  setState(() {
                    _selectedFeatures[entry.key] = value!;
                  });
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRequest,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Submit'),
        ),
      ],
    );
  }
}
