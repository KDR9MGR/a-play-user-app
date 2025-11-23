import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'About',
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
            // App Logo or Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            
            // App Name and Version
            Center(
              child: Column(
                children: [
                  const Text(
                    'A Play',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            _buildSection(
              'About A Play',
              'A Play is your all-in-one entertainment booking platform. Book movie tickets, reserve tables at restaurants, and get access to exclusive events - all in one place.',
            ),
            
            _buildSection(
              'Our Mission',
              'We aim to make entertainment booking seamless and enjoyable. Our platform connects you with the best venues and experiences in your city.',
            ),
            
            _buildSection(
              'Contact Us',
              'Have questions or suggestions? Reach out to us at:\nsupport@aplay.com',
            ),
            
            const SizedBox(height: 24),
            
            // Social Links
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.language, 'Website'),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.mail, 'Email'),
                  const SizedBox(width: 16),
                  _buildSocialButton(Icons.phone, 'Support'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Copyright
            Center(
              child: Text(
                '© ${DateTime.now().year} A Play. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
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

  Widget _buildSocialButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 