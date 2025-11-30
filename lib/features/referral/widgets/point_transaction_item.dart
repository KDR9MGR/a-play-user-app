import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:iconsax/iconsax.dart';
import '../model/referral_model.dart';

class PointTransactionItem extends StatelessWidget {
  final PointTransaction transaction;

  const PointTransactionItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingIcon(),
      title: Text(
        _getTransactionTitle(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${timeago.format(transaction.createdAt)} • ${transaction.description ?? ''}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        _formatPoints(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: transaction.points > 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData;
    Color backgroundColor;

    switch (transaction.transactionType) {
      case 'referral':
        iconData = Iconsax.user_add;
        backgroundColor = Colors.blue;
        break;
      case 'booking':
        iconData = Iconsax.calendar;
        backgroundColor = Colors.orange;
        break;
      case 'premium':
        iconData = Iconsax.crown_1;
        backgroundColor = Colors.purple;
        break;
      case 'daily_login':
        iconData = Iconsax.login;
        backgroundColor = Colors.teal;
        break;
      case 'rating':
        iconData = Iconsax.star;
        backgroundColor = Colors.amber;
        break;
      case 'redemption':
        iconData = Iconsax.shopping_bag;
        backgroundColor = Colors.red;
        break;
      default:
        iconData = Iconsax.chart;
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: backgroundColor,
        size: 24,
      ),
    );
  }

  String _getTransactionTitle() {
    switch (transaction.transactionType) {
      case 'referral':
        return 'Referral Bonus';
      case 'booking':
        return 'Booking Reward';
      case 'premium':
        return 'Premium Subscription';
      case 'daily_login':
        return 'Daily Login Bonus';
      case 'rating':
        return 'Rating Reward';
      case 'redemption':
        return 'Points Redemption';
      default:
        return 'Point Transaction';
    }
  }

  String _formatPoints() {
    if (transaction.points > 0) {
      return '+${transaction.points}';
    } else {
      return '${transaction.points}';
    }
  }
} 