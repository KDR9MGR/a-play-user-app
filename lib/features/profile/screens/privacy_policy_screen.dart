import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, including your name, email address, phone number, and profile picture when you create an account.',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, communicate with you, and personalize your experience.',
            ),
            _buildSection(
              'Data Storage',
              'Your data is stored securely using Supabase infrastructure. We implement appropriate technical and organizational measures to protect your personal information.',
            ),
            _buildSection(
              'Third-Party Services',
              'We may share your information with third-party service providers who assist us in providing our services, such as payment processing and analytics.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, correct, or delete your personal information. You can manage your data through your profile settings or contact us for assistance.',
            ),
            _buildSection(
              'Updates to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.aplayworld.com/privacy-policy'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Policy Online'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}