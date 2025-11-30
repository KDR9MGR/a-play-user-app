import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/features/club_booking/service/club_booking_service.dart';
import 'package:a_play/features/club_booking/model/table_model.dart';
import 'package:a_play/features/club_booking/model/booking_model.dart';
import 'package:a_play/features/home/model/club_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Club details controller
class ClubDetailsController extends AsyncNotifier<Club?> {
  late final ClubBookingService _bookingService;

  @override
  Future<Club?> build() async {
    _bookingService = ClubBookingService();
    return null;
  }

  Future<void> loadClubDetails(String clubId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _bookingService.getClubById(clubId);
    });
  }
}

// Club tables controller
class ClubTablesController extends AsyncNotifier<List<TableModel>> {
  late final ClubBookingService _bookingService;

  @override
  Future<List<TableModel>> build() async {
    _bookingService = ClubBookingService();
    return [];
  }

  Future<void> loadClubTables(String clubId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _bookingService.getClubTables(clubId);
    });
  }

  void toggleTableSelection(String tableId) {
    state = AsyncValue.data(
      state.value!.map((table) {
        if (table.id == tableId) {
          return TableModel(
            id: table.id,
            clubId: table.clubId,
            name: table.name,
            capacity: table.capacity,
            isAvailable: table.isAvailable,
            pricePerHour: table.pricePerHour,
            location: table.location,
            isSelected: !table.isSelected,
          );
        }
        return table;
      }).toList(),
    );
  }
}

// Booking controller
class BookingController extends AsyncNotifier<BookingModel?> {
  late final ClubBookingService _bookingService;

  @override
  Future<BookingModel?> build() async {
    _bookingService = ClubBookingService();
    return null;
  }

  Future<void> createBooking({
    required String clubId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    state = const AsyncLoading();

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      state = await AsyncValue.guard(() async {
        // First check availability
        final isAvailable = await _bookingService.checkTableAvailability(
          tableId: tableId,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
        );

        if (!isAvailable) {
          throw Exception('Table is not available for the selected time');
        }

        // Create the booking
        return await _bookingService.createBooking(
          userId: userId,
          clubId: clubId,
          tableId: tableId,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
          totalPrice: totalPrice,
        );
      });
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
} 