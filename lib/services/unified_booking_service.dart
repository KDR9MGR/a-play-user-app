
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/data/models/unified_booking_model.dart';
import 'package:a_play/features/restaurant/model/restaurant_booking_model.dart';
import 'package:a_play/features/club_booking/model/club_booking_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnifiedBookingService {
  final _supabase = Supabase.instance.client;

  Future<List<UnifiedBookingModel>> getMyBookings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final eventBookingsResponse = await _supabase
        .from('bookings')
        .select('*, events(*), zones(*)')
        .eq('user_id', userId);

    final restaurantBookingsResponse = await _supabase
        .from('restaurant_bookings')
        .select('*, restaurants(*), restaurant_tables(*)')
        .eq('user_id', userId);

    // MVP: club table bookings previously had a creation flow but nothing
    // ever surfaced them back to the user afterwards - no history, no
    // cancellation. Joins clubs/club_tables for display names, same shape
    // as the restaurant fetch above.
    final clubBookingsResponse = await _supabase
        .from('club_bookings')
        .select('*, clubs(*), club_tables(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final eventBookings = (eventBookingsResponse as List)
        .map((e) => UnifiedBookingModel(
              type: BookingType.event,
              eventBooking: BookingModel.fromJson(e),
            ))
        .toList();

    final restaurantBookings = (restaurantBookingsResponse as List)
        .map((e) => UnifiedBookingModel(
              type: BookingType.restaurant,
              restaurantBooking: RestaurantBooking.fromJson(e),
            ))
        .toList();

    final clubBookings = (clubBookingsResponse as List)
        .map((e) => UnifiedBookingModel(
              type: BookingType.club,
              clubBooking: ClubBookingHistory.fromJson(e),
            ))
        .toList();

    return [...eventBookings, ...restaurantBookings, ...clubBookings];
  }

  Future<void> cancelRestaurantBooking(String bookingId) async {
    await _supabase
        .from('restaurant_bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  Future<void> cancelClubBooking(String bookingId) async {
    await _supabase
        .from('club_bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }
}
