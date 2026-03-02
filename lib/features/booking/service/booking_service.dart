import 'package:a_play/data/models/booking_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final _supabase = Supabase.instance.client;

  Future<String> createBooking({
    required String eventId,
    required String zoneId,
    required DateTime bookingDate,
    required int quantity,
    String? transactionId, // Optional for backward compatibility
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
          })
          .select()
          .single();

      debugPrint('Booking created successfully: ${response['id']}');
      return response['id'];
    } catch (e) {
      debugPrint('Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
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

  Future<Map<String, dynamic>> getBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            event:events(*),
            zone:zones(*)
          ''')
          .eq('id', bookingId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      throw Exception('Failed to fetch booking: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('AUTH_REQUIRED');
      }

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            events (
              cover_image,
              title,
              end_date
             ),
            zones (
              name
            )
          ''')
          .eq('user_id', user.id);

      debugPrint('Bookings with event & zone info: $response');
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      // Preserve auth error message
      if (e.toString().contains('AUTH_REQUIRED')) {
        rethrow;
      }
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}


