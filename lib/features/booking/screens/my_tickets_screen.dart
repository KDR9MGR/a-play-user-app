
import 'package:a_play/config/feature_flags.dart';
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/data/models/unified_booking_model.dart';
import 'package:a_play/features/booking/screens/cancel_booking_screen.dart';
import 'package:a_play/features/booking/service/booking_service.dart';
import 'package:a_play/features/restaurant/model/restaurant_booking_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:a_play/core/constants/colors.dart';

final myBookingsProvider = FutureProvider<List<UnifiedBookingModel>>((ref) async {
  final unifiedBookingService = ref.watch(unifiedBookingServiceProvider);
  return unifiedBookingService.getMyBookings();
});

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // MVP: Show only Events tab (Restaurant bookings hidden)
    _tabController = TabController(
      length: FeatureFlags.enableRestaurants ? 2 : 1,
      vsync: this,
    );
    ref.read(myBookingsProvider.future);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myBookings = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 22),
            onPressed: () => ref.refresh(myBookingsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          indicatorWeight: 3,
          labelColor: AppColors.orange,
          unselectedLabelColor: Colors.grey,
          dividerColor: AppColors.cardDark,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.ticket, size: 18),
                  SizedBox(width: 8),
                  Text('Events'),
                ],
              ),
            ),
            // MVP: Restaurant bookings tab hidden - Coming in v2.1
            if (FeatureFlags.enableRestaurants)
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 18),
                    SizedBox(width: 8),
                    Text('Restaurants'),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Event Bookings
          myBookings.when(
            data: (bookings) {
              final eventBookings = bookings.where((b) => b.type == BookingType.event).toList();
              if (eventBookings.isEmpty) {
                return const Center(child: Text('No event bookings yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventBookings.length,
                itemBuilder: (context, index) => TicketCard(booking: eventBookings[index].eventBooking!),
              );
            },
            error: (error, stack) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),

          // MVP: Restaurant Bookings tab hidden - Coming in v2.1
          if (FeatureFlags.enableRestaurants)
            myBookings.when(
              data: (bookings) {
                final restaurantBookings = bookings.where((b) => b.type == BookingType.restaurant).toList();
                if (restaurantBookings.isEmpty) {
                  return const Center(child: Text('No restaurant bookings yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: restaurantBookings.length,
                  itemBuilder: (context, index) => RestaurantBookingCard(booking: restaurantBookings[index].restaurantBooking!),
                );
              },
              error: (error, stack) => Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final BookingModel booking;

  const TicketCard({super.key, required this.booking});

  void _showTicketDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TicketDetailsScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, MMM d').format(booking.bookingDate);
    final formattedTime = DateFormat('h:mm a').format(booking.bookingDate);
    final isActive = booking.status.toLowerCase() == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: booking.eventCoverImage != null
                      ? CachedNetworkImage(
                          imageUrl: booking.eventCoverImage!,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) => Container(
                            color: AppColors.orange.withOpacity(0.2),
                            child: const Icon(
                              Iconsax.gallery,
                              size: 30,
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.orange.withOpacity(0.2),
                          child: const Icon(
                            Iconsax.gallery,
                            size: 30,
                            color: AppColors.orange,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(booking.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.eventTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$formattedDate • $formattedTime',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (booking.zoneName != null)
                        Row(
                          children: [
                            Text(
                              booking.zoneName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.ticket,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.quantity} ticket${booking.quantity > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: QrImageView(
                      data: booking.id,
                      version: QrVersions.auto,
                      size: 70,
                      backgroundColor: AppColors.cardDark,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${booking.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (booking.amount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GH₵ ${booking.amount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return Colors.green[500]!;
      case 'used':
        return Colors.blue[500]!;
      case 'expired':
        return Colors.red[500]!;
      case 'cancelled':
        return Colors.grey[500]!;
      default:
        return Colors.grey[500]!;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'CONFIRMED';
      case 'active':
        return 'ACTIVE';
      case 'used':
        return 'USED';
      case 'expired':
        return 'EXPIRED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }
}

/// Ticket Details Screen with Cancel Button
class _TicketDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const _TicketDetailsScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    final eventDate = DateTime.parse(booking.eventEndDate);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
    final formattedTime = DateFormat('h:mm a').format(eventDate);
    final isActive = booking.status.toLowerCase() == 'confirmed' && eventDate.isAfter(DateTime.now());
    final canCancel = isActive && eventDate.difference(DateTime.now()).inHours > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ticket Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Card
            if (isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: booking.id,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan at venue for entry',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Event Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event Name
                  Text(
                    booking.eventTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details
                  _buildDetailRow(Iconsax.calendar, 'Date', formattedDate),
                  const SizedBox(height: 12),
                  _buildDetailRow(Iconsax.clock, 'Time', formattedTime),
                  const SizedBox(height: 12),
                  if (booking.zoneName != null)
                    _buildDetailRow(Iconsax.location, 'Zone', booking.zoneName!),
                  if (booking.zoneName != null) const SizedBox(height: 12),
                  _buildDetailRow(
                    Iconsax.ticket,
                    'Quantity',
                    '${booking.quantity} ticket${booking.quantity > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 12),
                  if (booking.amount != null)
                    _buildDetailRow(
                      Iconsax.money,
                      'Total Amount',
                      'GHS ${booking.amount!.toStringAsFixed(2)}',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Booking ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Booking ID',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    booking.id.substring(0, 8).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            if (canCancel) ...[
              const SizedBox(height: 24),

              // Cancel Booking Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CancelBookingScreen(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.close_circle, size: 20),
                  label: const Text('Cancel Booking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            if (!canCancel && booking.status == 'confirmed') ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade900.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade700),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade400, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Event has started. Cancellation is no longer available.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return Colors.green;
      case 'used':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'CONFIRMED';
      case 'active':
        return 'ACTIVE';
      case 'used':
        return 'USED';
      case 'expired':
        return 'EXPIRED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }
}

class RestaurantBookingCard extends ConsumerWidget {
  final RestaurantBooking booking;

  const RestaurantBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('EEE, MMM d').format(booking.bookingDate);
    final formattedTime = DateFormat('h:mm a').format(booking.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.restaurantName ?? 'Restaurant', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: $formattedDate'),
            Text('Time: $formattedTime'),
            Text('Party Size: ${booking.partySize}'),
            Text('Status: ${booking.status}'),
            if (booking.status == 'confirmed')
              ElevatedButton(
                onPressed: () async {
                  await ref.read(unifiedBookingServiceProvider).cancelRestaurantBooking(booking.id);
                  ref.refresh(myBookingsProvider);
                },
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
