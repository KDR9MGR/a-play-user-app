import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/club_booking/model/table_model.dart';
import 'package:a_play/features/club_booking/model/booking_model.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:a_play/features/club_booking/service/club_booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Club details provider
final clubDetailsControllerProvider = AsyncNotifierProvider<ClubDetailsController, Club?>(
  () => ClubDetailsController(),
);

// Club tables provider
final clubTablesControllerProvider = AsyncNotifierProvider<ClubTablesController, List<TableModel>>(
  () => ClubTablesController(),
);

// Booking provider
final bookingControllerProvider = AsyncNotifierProvider<BookingController, BookingModel?>(
  () => BookingController(),
);

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Time range provider
final timeRangeProvider = StateProvider<(DateTime, DateTime)>((ref) {
  final now = DateTime.now();
  final startTime = DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
  final endTime = DateTime(now.year, now.month, now.day, 21, 0);   // 9:00 PM
  return (startTime, endTime);
});

// Controller for club details
class ClubDetailsController extends AsyncNotifier<Club?> {
  final _bookingService = ClubBookingService();
  
  Future<void> loadClubDetails(String clubId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _bookingService.getClubById(clubId));
  }
  
  @override
  Future<Club?> build() async {
    return null;
  }
}

// Controller for club tables
class ClubTablesController extends AsyncNotifier<List<TableModel>> {
  final _bookingService = ClubBookingService();
  
  Future<void> loadClubTables(String clubId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _bookingService.getClubTables(clubId));
  }
  
  @override
  Future<List<TableModel>> build() async {
    return [];
  }
}

// Controller for booking
class BookingController extends AsyncNotifier<BookingModel?> {
  final _bookingService = ClubBookingService();
  
  Future<void> createBooking({
    required String clubId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    state = const AsyncLoading();
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = AsyncError('User not authenticated', StackTrace.current);
      return;
    }
    
    state = await AsyncValue.guard(() => _bookingService.createBooking(
      userId: userId,
      clubId: clubId,
      tableId: tableId,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
    ));
  }
  
  @override
  Future<BookingModel?> build() async {
    return null;
  }
} 