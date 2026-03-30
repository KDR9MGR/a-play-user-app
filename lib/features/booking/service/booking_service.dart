
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/services/unified_booking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final unifiedBookingServiceProvider = Provider((ref) => UnifiedBookingService());

class BookingService {
  final _supabase = Supabase.instance.client;

  Future<List<BookingModel>> getUserBookings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('bookings')
        .select('''
          id,
          user_id,
          event_id,
          zone_id,
          booking_date,
          quantity,
          status,
          created_at,
          amount,
          transaction_id,
          payment_status,
          events (
            title,
            end_date,
            cover_image
          ),
          zones (
            name
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .cast<Map<String, dynamic>>()
        .map((row) => BookingModel.fromJson(row))
        .toList();
  }

  Future<BookingModel> getBooking(String bookingId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('bookings')
        .select('''
          id,
          user_id,
          event_id,
          zone_id,
          booking_date,
          quantity,
          status,
          created_at,
          amount,
          transaction_id,
          payment_status,
          events (
            title,
            end_date,
            cover_image
          ),
          zones (
            name
          )
        ''')
        .eq('id', bookingId)
        .eq('user_id', user.id)
        .single();

    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  Future<String> createBooking({
    required String eventId,
    required String zoneId,
    required DateTime bookingDate,
    required int quantity,
    required String transactionId,
    required String paymentStatus,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Event: $eventId, Zone: $zoneId, Date: $bookingDate, Quantity: $quantity');

      // Insert the booking
      final response = await _supabase
          .from('bookings')
          .insert({
            'user_id': user.id,
            'event_id': eventId,
            'zone_id': zoneId,
            'booking_date': bookingDate.toIso8601String(),
            'quantity': quantity,
            'status': 'confirmed',
            'transaction_id': transactionId,
            'payment_status': paymentStatus,
          })
          .select('''
            id,
            quantity,
            amount,
            booking_date,
            events (
              title,
              start_date,
              location,
              venue_id
            ),
            zones (
              name,
              price
            )
          ''')
          .single();

      debugPrint('Booking created successfully: ${response['id']}');

      // Send confirmation email asynchronously (don't block booking creation)
      _sendBookingConfirmationEmail(
        bookingId: response['id'],
        userEmail: user.email!,
        bookingData: response,
      ).catchError((error) {
        debugPrint('Failed to send confirmation email: $error');
        // Don't throw - email failure shouldn't fail the booking
      });

      return response['id'];
    } catch (e) {
      debugPrint('Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<void> _sendBookingConfirmationEmail({
    required String bookingId,
    required String userEmail,
    required Map<String, dynamic> bookingData,
  }) async {
    try {
      // Get user profile for name
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final profile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();

      final event = bookingData['events'];
      final zone = bookingData['zones'];

      // Format date and time
      final eventDate = DateTime.parse(event['start_date'] as String);
      final formattedDate = '${_getMonthName(eventDate.month)} ${eventDate.day}, ${eventDate.year}';
      final formattedTime = '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';

      // Prepare email data
      final emailData = {
        'userName': profile['full_name'] ?? 'Valued Customer',
        'eventName': event['title'],
        'eventDate': formattedDate,
        'eventTime': formattedTime,
        'venueName': event['location'] ?? 'TBA',
        'venueAddress': event['venue_id'] ?? 'See event details',
        'zoneName': zone['name'],
        'quantity': bookingData['quantity'].toString(),
        'unitPrice': (zone['price'] as num).toStringAsFixed(2),
        'totalPrice': (bookingData['amount'] as num).toStringAsFixed(2),
        'bookingReference': bookingId.substring(0, 8).toUpperCase(),
        'qrCodeImage': 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$bookingId',
      };

      // Call Supabase Edge Function to send email
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': userEmail,
          'subject': 'Your Event Ticket - ${event['title']}',
          'template': 'event-booking',
          'data': emailData,
        },
      );

      debugPrint('Confirmation email sent to $userEmail');
    } catch (e) {
      debugPrint('Error sending confirmation email: $e');
      rethrow;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<List<Map<String, dynamic>>> createBookings({
    required String eventId,
    required DateTime eventDate,
    required String bookingDate, 
    required List<Map<String, dynamic>> tickets,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final bookings = tickets.map((ticket) => {
        'event_id': eventId,
        'user_id': user.id,
        'zone_id': ticket['zoneId'],
        'quantity': ticket['quantity'],
        'amount': ticket['amount'],
        'booking_date': bookingDate,
        'status': 'confirmed',
      }).toList();

      final response = await _supabase
          .from('bookings') 
          .insert(bookings)
          .select();

      return response;
    } catch (e) {
      debugPrint('Error creating bookings: $e');
      throw Exception('Failed to create bookings');
    }
  }
}
