
import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/features/restaurant/model/restaurant_booking_model.dart';

enum BookingType { event, restaurant }

class UnifiedBookingModel {
  final BookingType type;
  final BookingModel? eventBooking;
  final RestaurantBooking? restaurantBooking;

  UnifiedBookingModel({
    required this.type,
    this.eventBooking,
    this.restaurantBooking,
  });
}
