import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Frequently Asked Questions',
            children: [
              _buildExpandableFAQ(
                context,
                question: 'How do I book an event?',
                answer: 'To book an event, simply browse through our events list, select the event you\'re interested in, and click the "Book Now" button. Follow the payment process to confirm your booking.',
              ),
              _buildExpandableFAQ(
                context,
                question: 'Can I cancel my booking?',
                answer: 'Yes, you can cancel your booking up to 24 hours before the event starts. Please note that cancellation fees may apply depending on the event\'s policy.',
              ),
              _buildExpandableFAQ(
                context,
                question: 'How do I get my tickets?',
                answer: 'After successful booking, your tickets will be available in the "My Tickets" section of the app. You can also receive them via email.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Contact Support',
            children: [
              _buildContactTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@aplayworld.com',
                onTap: () {
                  // TODO: Implement email support
                },
              ),
              _buildContactTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Phone Support',
                subtitle: '+1 (234) 567-8900',
                onTap: () {
                  // TODO: Implement phone support
                },
              ),
              _buildContactTile(
                context,
                icon: Icons.chat_outlined,
                title: 'Live Chat',
                subtitle: 'Available 24/7',
                onTap: () {
                  // TODO: Implement live chat
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
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

  Widget _buildExpandableFAQ(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 