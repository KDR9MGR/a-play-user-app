import 'package:flutter/material.dart';
import '../model/referral_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TimeLimitedOffersCard extends StatelessWidget {
  final List<TimeLimitedOffer> offers;

  const TimeLimitedOffersCard({
    super.key,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no active offers
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.flash_1, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Limited Time Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Earn bonus points for a limited time',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...offers.map((offer) => _buildOfferItem(context, offer)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferItem(BuildContext context, TimeLimitedOffer offer) {
    final now = DateTime.now();
    final remainingDays = offer.endDate.difference(now).inDays;
    final remainingHours = offer.endDate.difference(now).inHours % 24;
    
    // Different colors based on urgency
    Color offerColor;
    if (remainingDays < 1) {
      offerColor = Colors.red;
    } else if (remainingDays < 3) {
      offerColor = Colors.orange;
    } else {
      offerColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            offerColor.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: offerColor.withOpacity(0.5),
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
                  color: offerColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.discount_shape,
                  color: offerColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (offer.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          offer.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${offer.multiplier}x',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time remaining
          Row(
            children: [
              Icon(
                Iconsax.timer_1,
                color: offerColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _getRemainingTimeText(remainingDays, remainingHours),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: offerColor,
                ),
              ),
              const Spacer(),
              Text(
                'Valid until ${DateFormat('MMM d, yyyy').format(offer.endDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getRemainingTimeText(int days, int hours) {
    if (days > 0) {
      return '$days days, $hours hours left';
    } else if (hours > 0) {
      return '$hours hours left';
    } else {
      return 'Ending soon!';
    }
  }
} 