import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService();
  bool? _pushEnabled;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await _notificationService.isPushEnabled();
    if (mounted) setState(() => _pushEnabled = enabled);
  }

  Future<void> _togglePush(bool value) async {
    setState(() => _isUpdating = true);
    if (value) {
      await _notificationService.enablePush();
    } else {
      await _notificationService.disablePush();
    }
    if (mounted) {
      setState(() {
        _pushEnabled = value;
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _pushEnabled == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      'Booking confirmations, event reminders, messages, and subscription updates',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    value: _pushEnabled!,
                    onChanged: _isUpdating ? null : _togglePush,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'You can also manage notification permissions for A Play in your device Settings app.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
