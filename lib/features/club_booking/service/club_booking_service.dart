import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:a_play/features/club_booking/model/table_model.dart';
import 'package:a_play/features/club_booking/model/booking_model.dart';
import 'package:uuid/uuid.dart';

class ClubBookingService {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Get club details by ID
  Future<Club> getClubById(String clubId) async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .eq('id', clubId)
          .single();
          
      return Club.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch club: $e');
    }
  }
  
  // Get tables for a specific club
  Future<List<TableModel>> getClubTables(String clubId) async {
    try {
      final response = await _client
          .from('club_tables')
          .select()
          .eq('club_id', clubId)
          .order('name');
      
      return response.map<TableModel>((json) => 
        TableModel(
          id: json['id'],
          clubId: json['club_id'],
          name: json['name'],
          capacity: json['capacity'],
          isAvailable: json['is_available'],
          pricePerHour: json['price_per_hour'].toDouble(),
          location: json['location'],
          isSelected: false,
        )
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch tables: $e');
    }
  }
  
  // Create a new booking
  Future<BookingModel> createBooking({
    required String userId,
    required String clubId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    try {
      const uuid = Uuid();
      final bookingId = uuid.v4();
      
      final bookingData = {
        'id': bookingId,
        'user_id': userId,
        'club_id': clubId,
        'table_id': tableId,
        'booking_date': bookingDate.toIso8601String().split('T')[0],
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'total_price': totalPrice,
        'status': 'pending',
      };
      
      await _client
          .from('club_bookings')
          .insert(bookingData);
      
      return BookingModel(
        id: bookingId,
        userId: userId,
        clubId: clubId,
        tableId: tableId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        status: 'pending',
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
  
  // Check table availability for a specific date and time range
  Future<bool> checkTableAvailability({
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await _client
          .from('club_bookings')
          .select()
          .eq('table_id', tableId)
          .eq('booking_date', bookingDate.toIso8601String().split('T')[0])
          .or('end_time.gte.${startTime.toIso8601String()},start_time.lt.${endTime.toIso8601String()}')
          .not('status', 'eq', 'cancelled');
      
      return response.isEmpty;
    } catch (e) {
      throw Exception('Failed to check table availability: $e');
    }
  }
  
  // Get bookings for a user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('club_bookings')
          .select()
          .eq('user_id', userId)
          .order('booking_date', ascending: false);
      
      return response.map<BookingModel>((json) => 
        BookingModel(
          id: json['id'],
          userId: json['user_id'],
          clubId: json['club_id'],
          tableId: json['table_id'],
          bookingDate: DateTime.parse(json['booking_date']),
          startTime: DateTime.parse(json['start_time']),
          endTime: DateTime.parse(json['end_time']),
          totalPrice: json['total_price'].toDouble(),
          status: json['status'],
        )
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }
  
  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('club_bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
} 