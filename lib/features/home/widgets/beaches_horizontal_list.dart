import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/theme/app_theme.dart';
import 'package:a_play/features/home/model/beach_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:a_play/features/home/widgets/lounges_horizontal_list.dart';
import 'package:google_fonts/google_fonts.dart';

class BeachesHorizontalList extends ConsumerWidget {
  final List<Beach> beaches;
  final String title;
  final bool isLoading;

  const BeachesHorizontalList({
    super.key,
    required this.beaches,
    required this.title,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.parisienne(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (beaches.length > 5)
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.26,
          child: isLoading
              ? _buildLoadingState(context)
              : beaches.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: beaches.length,
                      itemBuilder: (context, index) {
                        final beach = beaches[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < beaches.length - 1 ? 8 : 0,
                          ),
                          child: HorizontalBeachCard(beach: beach),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 16 : 0),
          child: const HorizontalVenueCardSkeleton(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'No beaches available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalBeachCard extends StatelessWidget {
  final Beach beach;

  const HorizontalBeachCard({
    super.key,
    required this.beach,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'beach_${beach.id}',
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: beach.logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(beach.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: beach.logoUrl == null ? Colors.grey[800] : null,
                    ),
                    child: beach.logoUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.beach_access,
                              size: 40,
                              color: Colors.white54,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SvgPicture.asset(
                      'assets/images/app_logo.svg',
                      height: 16,
                      width: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      beach.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}