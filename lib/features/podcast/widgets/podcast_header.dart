import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class PodcastHeader extends StatelessWidget {
  const PodcastHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0), // Extra top padding
        child: Row(
        children: [
          BackButton(
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),

          // Greeting Text
          Expanded(
            child: FutureBuilder<String?>(
              future: AuthService.getCurrentUserName(),
              builder: (context, snapshot) {
                final userName = snapshot.data ?? 'User';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  //Chnaged font
                );
              },
            ),
          ),

          // Action Icons
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white70),
            tooltip: 'Search',
          ),
        ],
        ),
      ),
    );
  }
}
