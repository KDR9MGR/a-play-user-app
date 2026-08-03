import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../model/referral_model.dart';

class MyRedemptionsCard extends StatelessWidget {
  final List<PointRedemption> redemptions;

  const MyRedemptionsCard({
    super.key,
    required this.redemptions,
  });

  @override
  Widget build(BuildContext context) {
    if (redemptions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'You have not redeemed any rewards yet.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < redemptions.length; i++) ...[
              _buildRedemptionTile(context, redemptions[i]),
              if (i != redemptions.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionTile(BuildContext context, PointRedemption redemption) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _statusColor(redemption.status).withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          redemption.affiliateId != null ? Iconsax.shop : Iconsax.gift,
          color: _statusColor(redemption.status),
          size: 20,
        ),
      ),
      title: Text(
        redemption.description.isNotEmpty
            ? redemption.description
            : redemption.rewardType,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (redemption.redemptionCode != null)
            Row(
              children: [
                Text(
                  'Code: ${redemption.redemptionCode}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: redemption.redemptionCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Iconsax.copy, size: 14),
                  ),
                ),
              ],
            ),
          Text(
            _statusLabel(redemption),
            style: TextStyle(
              fontSize: 12,
              color: _statusColor(redemption.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      trailing: Text(
        '-${redemption.pointsSpent}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.red,
        ),
      ),
      isThreeLine: redemption.redemptionCode != null,
    );
  }

  String _statusLabel(PointRedemption redemption) {
    final status = redemption.status[0].toUpperCase() +
        redemption.status.substring(1);
    if (redemption.expiresAt != null && redemption.status == 'pending') {
      return '$status • Expires ${DateFormat.yMMMd().format(redemption.expiresAt!)}';
    }
    return status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'redeemed':
      case 'settled':
        return Colors.green;
      case 'expired':
      case 'cancelled':
        return Colors.grey;
      case 'pending':
      default:
        return Colors.amber.shade700;
    }
  }
}
