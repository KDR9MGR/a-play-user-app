import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EulaConsentDialog extends StatelessWidget {
  const EulaConsentDialog({super.key});

  static const String _prefsKey = 'eulaAccepted_v1';

  static Future<bool> ensureConsent(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_prefsKey) ?? false;
    if (accepted) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const EulaConsentDialog(),
    );

    if (result == true) {
      await prefs.setBool(_prefsKey, true);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'End User License Agreement',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To continue, you must agree to our End User License Agreement (EULA).',
              style: const TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            const Text(
              'Key points:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            const Text('• No tolerance for objectionable content or abusive users.',
                style: TextStyle(color: Colors.white70)),
            const Text('• Content filtering is enabled to reduce exposure to objectionable material.',
                style: TextStyle(color: Colors.white70)),
            const Text('• Users can flag objectionable content and block abusive users.',
                style: TextStyle(color: Colors.white70)),
            const Text('• Reports are reviewed within 24 hours; offending content is removed and users may be ejected.',
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 12),
            const Text(
              'By tapping Agree, you acknowledge these terms and agree to abide by them.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Apple EULA'),
                ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.aplayworld.com/terms-and-conditions'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Terms & Conditions'),
                ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.aplayworld.com/privacy-policy'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
          child: const Text('Agree'),
        ),
      ],
    );
  }
}