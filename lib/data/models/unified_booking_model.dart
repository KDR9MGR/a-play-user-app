
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/features/restaurant/model/restaurant_booking_model.dart';
import 'package:a_play/features/club_booking/model/club_booking_history_model.dart';

enum BookingType { event, restaurant, club }

class UnifiedBookingModel {
  final BookingType type;
  final BookingModel? eventBooking;
  final RestaurantBooking? restaurantBooking;
  final ClubBookingHistory? clubBooking;

  UnifiedBookingModel({
    required this.type,
    this.eventBooking,
    this.restaurantBooking,
    this.clubBooking,
  });
}
