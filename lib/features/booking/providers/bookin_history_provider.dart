
//Booking History Provider

import 'package:a_play/data/models/booking_model.dart';
import 'package:a_play/features/booking/service/booking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
    return BookingService();
});

final bookingHistoryProvider = FutureProvider<List<BookingModel>>((ref) async {
    final bookingService = ref.read(bookingServiceProvider);
    try {
        return await bookingService.getUserBookings();
    } catch (e) {
        debugPrint("Error fetching booking history: $e");
        throw Exception(e);
    }
});
