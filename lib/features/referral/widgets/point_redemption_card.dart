import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PointRedemptionCard extends StatelessWidget {
  final Future<void> Function(int points, String purpose) onRedeem;

  const PointRedemptionCard({
    super.key,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use your points for exclusive benefits',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // List of redemption options
            _buildRedemptionOption(
              context,
              title: 'GH₵500 Discount',
              points: 500,
              icon: Iconsax.discount_shape,
              color: Colors.green,
            ),
            const Divider(),
            _buildRedemptionOption(
              context,
              title: '1 Free Premium Week',
              points: 1000,
              icon: Iconsax.crown_1,
              color: Colors.purple,
            ),
            const Divider(),
            _buildRedemptionOption(
              context,
              title: 'Free VIP Upgrade',
              points: 2500,
              icon: Iconsax.medal_star,
              color: Colors.amber,
            ),
            const Divider(),
            _buildRedemptionOption(
              context,
              title: 'Access to Top Events',
              points: 5000,
              icon: Iconsax.ticket,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionOption(
    BuildContext context, {
    required String title,
    required int points,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(title),
      subtitle: Text('$points points'),
      trailing: ElevatedButton(
        onPressed: () {
          _confirmRedemption(
            context, 
            points: points, 
            title: title,
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Redeem'),
      ),
    );
  }

  void _confirmRedemption(
    BuildContext context, {
    required int points,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text('Are you sure you want to redeem $points points for $title?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await onRedeem(points, title);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully redeemed for $title')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to redeem: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
} 
