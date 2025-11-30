import 'package:flutter/material.dart';

import '../model/referral_model.dart';

class MembershipTierCard extends StatelessWidget {
  final List<MembershipTier> tiers;
  final String? currentTierName;
  final int userPoints;

  const MembershipTierCard({
    super.key,
    required this.tiers,
    required this.currentTierName,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Sort tiers by min points
    final sortedTiers = List<MembershipTier>.from(tiers)
      ..sort((a, b) => a.minPoints.compareTo(b.minPoints));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: _getTierColor(currentTierName),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Tier: ${currentTierName ?? 'None'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTierColor(currentTierName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Membership Tiers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Progress indicator for next tier
            if (currentTierName != null && currentTierName != 'Platinum')
              _buildNextTierProgress(context, sortedTiers),

            const SizedBox(height: 16),

            // List of all tiers
            ...sortedTiers.map((tier) => _buildTierItem(context, tier)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextTierProgress(
      BuildContext context, List<MembershipTier> sortedTiers) {
    // Find current tier and next tier
    final currentTierIndex =
        sortedTiers.indexWhere((t) => t.name == currentTierName);
    if (currentTierIndex < 0 || currentTierIndex >= sortedTiers.length - 1) {
      return const SizedBox.shrink();
    }

    final currentTier = sortedTiers[currentTierIndex];
    final nextTier = sortedTiers[currentTierIndex + 1];

    // Calculate progress
    final minPoints = currentTier.minPoints;
    final maxPoints = nextTier.minPoints;
    final pointsRange = maxPoints - minPoints;
    final userProgress = userPoints - minPoints;
    final progressPercent = (userProgress / pointsRange).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$userPoints/${nextTier.minPoints} points to next tier',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercent,
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.white10,
          color: _getTierColor(nextTier.name),
        ),
        const SizedBox(height: 4),
        Text(
          'Next tier: ${nextTier.name}',
          style: TextStyle(
            fontSize: 14,
            color: _getTierColor(nextTier.name),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTierItem(BuildContext context, MembershipTier tier) {
    final isCurrent = tier.name == currentTierName;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? _getTierColor(tier.name).withOpacity(0.1)
            : Colors.transparent,
        border: Border.all(
          color: isCurrent
              ? _getTierColor(tier.name)
              : Colors.white.withValues(alpha: 0.1),
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTierColor(tier.name).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars,
              color: _getTierColor(tier.name),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTierColor(tier.name).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tier.maxPoints != null
                      ? '${tier.minPoints} - ${tier.maxPoints} points'
                      : '${tier.minPoints}+ points',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (tier.benefits != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tier.benefits!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String? tierName) {
    switch (tierName) {
      case 'Bronze':
        return Colors.brown;
      case 'Silver':
        return Colors.blueGrey;
      case 'Gold':
        return Colors.amber.shade700;
      case 'Platinum':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
