import 'package:flutter/material.dart';
import 'package:a_play/services/concierge_service.dart';

class ServiceRequestDialog extends StatefulWidget {
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
  State<ServiceRequestDialog> createState() => _ServiceRequestDialogState();
}

class _ServiceRequestDialogState extends State<ServiceRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  List<bool> _selectedFeatures = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedFeatures = List.generate(widget.features.length, (index) => false);
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

      await ConciergeService().submitRequest(
        serviceType: widget.serviceType,
        serviceName: widget.serviceName,
        requestDetails: {
          'description': _descriptionController.text,
          'selectedFeatures': selectedFeatures,
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request ${widget.serviceName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Select Required Features:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...widget.features.asMap().entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: _selectedFeatures[entry.key],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedFeatures[entry.key] = value ?? false;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  hintText: 'Please provide any specific requirements...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide some details about your request';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 