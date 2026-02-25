import 'package:flutter/material.dart';

class LegalLinksPage extends StatelessWidget {
  const LegalLinksPage({super.key});

  static const _links = [
    {
      'title': 'A Play Website',
      'subtitle': 'aplayworld.com',
      'url': 'https://www.aplayworld.com/',
    },
    {
      'title': 'Terms & Conditions',
      'subtitle': 'Legal terms for using A Play',
      'url': 'https://www.aplayworld.com/terms-and-conditions',
    },
    {
      'title': 'Privacy Policy',
      'subtitle': 'How we handle your data',
      'url': 'https://www.aplayworld.com/privacy-policy',
    },
    {
      'title': 'Refund Policy',
      'subtitle': 'Cancellations and refunds',
      'url': 'https://www.aplayworld.com/refund-policy',
    },
    {
      'title': 'FAQ',
      'subtitle': 'Common questions answered',
      'url': 'https://www.aplayworld.com/faq',
    },
    {
      'title': 'Contact',
      'subtitle': 'Get in touch with support',
      'url': 'https://www.aplayworld.com/contact',
    },
    {
      'title': 'Apple Standard EULA',
      'subtitle': 'App Store End User License Agreement',
      'url': 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal & Policies'),
      ),
      body: ListView.separated(
        itemCount: _links.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _links[index];
          return ListTile(
            title: Text(item['title']!),
            subtitle: Text(item['subtitle']!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          );
        },
      ),
    );
  }
}
