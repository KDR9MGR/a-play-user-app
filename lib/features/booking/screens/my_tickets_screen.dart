import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/features/booking/providers/bookin_history_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:a_play/core/constants/colors.dart';

//ConsumerStatefulWidget
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
    _tabController = TabController(length: 2, vsync: this);
    ref.read(bookingHistoryProvider.future);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterTickets(List<BookingModel> tickets, bool isActive) {
    final now = DateTime.now();
    return tickets.where((ticket) {
      final isExpired = DateTime.parse(ticket.eventEndDate).isBefore(now);
      return isActive ? !isExpired : isExpired;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = ref.watch(bookingHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 22),
            onPressed: () => ref.refresh(bookingHistoryProvider),
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
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.ticket, size: 18),
                  SizedBox(width: 8),
                  Text('Active'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.ticket_expired, size: 18),
                  SizedBox(width: 8),
                  Text('Expired'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tickets Tab
          bookingProvider.when(
            data: (bookings) {
              final activeTickets = _filterTickets(bookings, true);
              if (activeTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.ticket_expired5,
                    size: 70,
                    color: Color(0xFF303030),
                  ),
                  const SizedBox(height: 24),
                  Text(
                        'No Active Tickets',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                          'You don\'t have any active tickets at the moment',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade400,
                            height: 1.4,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explore Events',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeTickets.length,
                itemBuilder: (context, index) => TicketCard(booking: activeTickets[index]),
              );
            },
        error: (error, stack) {
          // Check if error is authentication-related
          final isAuthError = error.toString().contains('AUTH_REQUIRED');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAuthError ? Iconsax.lock_1 : Iconsax.warning_2,
                  size: 70,
                  color: isAuthError ? AppColors.orange : const Color(0xFFFF3B30),
                ),
                const SizedBox(height: 24),
                Text(
                  isAuthError ? 'Sign in Required' : 'Failed to Load Tickets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    isAuthError
                      ? 'Please sign in to view your tickets and booking history'
                      : 'Unable to load your tickets. Please try again.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isAuthError
                    ? () => Navigator.pushNamed(context, '/sign-in')
                    : () => ref.refresh(bookingHistoryProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(isAuthError ? Iconsax.login : Iconsax.refresh),
                  label: Text(isAuthError ? 'Sign In' : 'Retry'),
                ),
              ],
            ),
          );
        },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            ),
          ),

          // Expired Tickets Tab
          bookingProvider.when(
            data: (bookings) {
              final expiredTickets = _filterTickets(bookings, false);
              if (expiredTickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.ticket_expired5,
                        size: 70,
                        color: Color(0xFF303030),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Expired Tickets',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 12),
              Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                          'You don\'t have any expired tickets',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade400,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: expiredTickets.length,
                itemBuilder: (context, index) => TicketCard(booking: expiredTickets[index]),
              );
            },
            error: (error, stack) {
              // Check if error is authentication-related
              final isAuthError = error.toString().contains('AUTH_REQUIRED');

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAuthError ? Iconsax.lock_1 : Iconsax.warning_2,
                      size: 70,
                      color: isAuthError ? AppColors.orange : const Color(0xFFFF3B30),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isAuthError ? 'Sign in Required' : 'Failed to Load Tickets',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        isAuthError
                          ? 'Please sign in to view your tickets and booking history'
                          : 'Unable to load your tickets. Please try again.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade400,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: isAuthError
                        ? () => Navigator.pushNamed(context, '/sign-in')
                        : () => ref.refresh(bookingHistoryProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(isAuthError ? Iconsax.login : Iconsax.refresh),
                      label: Text(isAuthError ? 'Sign In' : 'Retry'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final BookingModel booking;

  const TicketCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, MMM d').format(booking.bookingDate);
    final formattedTime = DateFormat('h:mm a').format(booking.bookingDate);
    final isActive = booking.status.toLowerCase() == 'confirmed';
    
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
      clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Top section with image and details
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event poster
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
                          color: AppColors.orange.withValues(alpha: 0.2),
                          child: const Icon(
                            Iconsax.gallery,
                            size: 30,
                            color: AppColors.orange,
                          ),
                        ),
                      )
                    : Image.network(
                        booking.eventCoverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.orange.withValues(alpha: 0.2),
                          child: const Icon(
                            Iconsax.gallery,
                            size: 30,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                ),
              ),
              
              // Event details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status chip
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
                      
                      // Event ID (replace with title when available)
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
                        
                        // Date and time
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
                        
                      // Zone
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
                        
                      // Quantity
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
              
              // Right side with QR code (if active)
              if (isActive)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: QrImageView(
                      data: booking.id,
                      version: QrVersions.auto,
                      size: 70,
                      backgroundColor:  AppColors.cardDark,
                      foregroundColor: AppColors.white,
                    ),
                              ),
                            ),
                          ],
                        ),
                        
          // Bottom section with amount and ID
                                Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),  
              border: Border(
               
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
                            ),
                            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                // Booking ID
                Text(
                  'ID: ${booking.id.substring(0, 8).toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Amount
                if (booking.amount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.2),
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

