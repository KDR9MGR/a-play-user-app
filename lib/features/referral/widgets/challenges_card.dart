import 'package:a_play/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../model/referral_model.dart';

class ChallengesCard extends StatelessWidget {
  final List<UserChallengeProgress> challenges;

  const ChallengesCard({
    super.key,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No active challenges at the moment.'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.award, size: 24),
                SizedBox(width: 8),
                Text(
                  'Bonus Challenges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete challenges to earn bonus points',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...challenges
                .map((challenge) => _buildChallengeItem(context, challenge)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeItem(
      BuildContext context, UserChallengeProgress progress) {
    // Early return if challenge data is missing
    if (progress.challenge == null) {
      return const SizedBox.shrink();
    }

    final challenge = progress.challenge!;
    final isCompleted = progress.completed;
    final progressPercent = progress.currentCount / challenge.targetCount;

    // Challenge type icons
    IconData typeIcon;
    Color typeColor;
    switch (challenge.challengeType) {
      case 'booking':
        typeIcon = Iconsax.ticket;
        typeColor = Colors.purple;
        break;
      case 'subscription':
        typeIcon = Iconsax.crown_1;
        typeColor = Colors.amber;
        break;
      default:
        typeIcon = Iconsax.medal;
        typeColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.black38,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isCompleted ? Colors.green : typeColor).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Iconsax.tick_square : typeIcon,
                  color: isCompleted ? Colors.green : typeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (challenge.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          challenge.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${challenge.rewardPoints} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressPercent.clamp(0.0, 1.0),
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: isCompleted ? Colors.green : typeColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${progress.currentCount}/${challenge.targetCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.verify5,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Challenge completed on ${_formatDate(progress.completedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.timer_1,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getRemainingDays(progress.startDate, challenge.periodDays)} days left to complete',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getRemainingDays(DateTime startDate, int periodDays) {
    final endDate = startDate.add(Duration(days: periodDays));
    final now = DateTime.now();
    final remaining = endDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
