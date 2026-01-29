import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'d love to hear from you. Our team is always here to help!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Contact Information
            _buildContactSection(
              context,
              title: 'Contact Information',
              children: [
                _buildContactTile(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Office Address',
                  details: '123 EventModel Street\nCity, State 12345\nCountry',
                ),
                _buildContactTile(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Numbers',
                  details: 'Main: +1 (234) 567-8900\nSupport: +1 (234) 567-8901',
                ),
                _buildContactTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Addresses',
                  details: 'General: info@aplayworld.com\nSupport: support@aplayworld.com',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Business Hours
            _buildContactSection(
              context,
              title: 'Business Hours',
              children: [
                _buildHoursTile(
                  context,
                  days: 'Monday - Friday',
                  hours: '9:00 AM - 6:00 PM',
                ),
                _buildHoursTile(
                  context,
                  days: 'Saturday',
                  hours: '10:00 AM - 4:00 PM',
                ),
                _buildHoursTile(
                  context,
                  days: 'Sunday',
                  hours: 'Closed',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Social Media
            _buildContactSection(
              context,
              title: 'Connect With Us',
              children: [
                _buildSocialMediaTile(
                  context,
                  icon: Icons.facebook,
                  platform: 'Facebook',
                  handle: '@aplayworld',
                  onTap: () {
                    // TODO: Implement Facebook link
                  },
                ),
                _buildSocialMediaTile(
                  context,
                  icon: Icons.telegram,
                  platform: 'Twitter',
                  handle: '@aplayworld',
                  onTap: () {
                    // TODO: Implement Twitter link
                  },
                ),
                _buildSocialMediaTile(
                  context,
                  icon: Icons.photo_camera_outlined,
                  platform: 'Instagram',
                  handle: '@aplayworld',
                  onTap: () {
                    // TODO: Implement Instagram link
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String details,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursTile(
    BuildContext context, {
    required String days,
    required String hours,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        title: Text(days),
        trailing: Text(
          hours,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaTile(
    BuildContext context, {
    required IconData icon,
    required String platform,
    required String handle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(platform),
        subtitle: Text(handle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 