
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/services/unified_booking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final unifiedBookingServiceProvider = Provider((ref) => UnifiedBookingService());

class BookingService {
  final _supabase = Supabase.instance.client;

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
}
