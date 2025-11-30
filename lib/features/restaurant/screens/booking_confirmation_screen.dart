import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/restaurant_booking_model.dart';
import '../model/restaurant_model.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final RestaurantBooking booking;
  final Restaurant restaurant;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Table Booked Successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Your table reservation has been confirmed',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Booking Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Booking Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildDetailRow(
                    'Booking ID',
                    booking.id.substring(0, 8).toUpperCase(),
                    Icons.confirmation_number,
                  ),
                  
                  _buildDetailRow(
                    'Restaurant',
                    restaurant.name,
                    Icons.store,
                  ),
                  
                  _buildDetailRow(
                    'Date',
                    DateFormat('EEEE, MMMM dd, yyyy').format(booking.bookingDate),
                    Icons.calendar_today,
                  ),
                  
                  _buildDetailRow(
                    'Time',
                    '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                    Icons.access_time,
                  ),
                  
                  _buildDetailRow(
                    'Table',
                    booking.table?.tableNumber ?? 'N/A',
                    Icons.table_restaurant,
                  ),
                  
                  _buildDetailRow(
                    'Party Size',
                    '${booking.partySize} ${booking.partySize == 1 ? 'person' : 'people'}',
                    Icons.people,
                  ),
                  
                  _buildDetailRow(
                    'Status',
                    booking.status.displayName,
                    Icons.info,
                    valueColor: _getStatusColor(booking.status),
                  ),
                  
                  if (booking.specialRequests != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Special Requests',
                      booking.specialRequests!,
                      Icons.note,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Important Notes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Please arrive on time to secure your table\n'
                    '• Contact the restaurant if you need to modify your booking\n'
                    '• Cancellations should be made at least 2 hours in advance\n'
                    '• Keep this confirmation for your records',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Restaurant Contact
            if (restaurant.phone != null || restaurant.email != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurant Contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (restaurant.phone != null)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.phone!,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    if (restaurant.email != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.email!,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to my bookings screen
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View My Bookings',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey[500],
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    return status.when(
      pending: () => Colors.orange,
      confirmed: () => Colors.green,
      cancelled: () => Colors.red,
      completed: () => Colors.blue,
    );
  }
}