import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:a_play/features/club_booking/screens/club_details_screen.dart';
import 'package:go_router/go_router.dart';

class ClubsGrid extends ConsumerWidget {
  final List<Club> clubs;

  const ClubsGrid({
    super.key,
    required this.clubs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return ClubCard(club: club);
      },
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubDetailsScreen(club: club),
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: 'club_${club.id}',
            child: AspectRatio(
              aspectRatio: 1 / 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  image: DecorationImage(
                    image: NetworkImage(club.logoUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
