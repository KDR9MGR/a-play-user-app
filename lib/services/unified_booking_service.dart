
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/data/models/unified_booking_model.dart';
import 'package:a_play/features/restaurant/model/restaurant_booking_model.dart';
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

    return [...eventBookings, ...restaurantBookings];
  }

  Future<void> cancelRestaurantBooking(String bookingId) async {
    await _supabase
        .from('restaurant_bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }
}
