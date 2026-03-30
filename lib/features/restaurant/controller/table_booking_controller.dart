import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/restaurant_table_model.dart';
import '../model/restaurant_booking_model.dart';
import '../service/restaurant_service.dart';

// Service Provider
final restaurantServiceProvider = Provider<RestaurantService>((ref) => RestaurantService());

// Restaurant Tables Controller
class RestaurantTablesNotifier extends AsyncNotifier<List<RestaurantTable>> {
  late RestaurantService _service;
  String? _currentRestaurantId;

  @override
  Future<List<RestaurantTable>> build() async {
    _service = ref.read(restaurantServiceProvider);
    return [];
  }

  Future<void> loadTables(String restaurantId) async {
    if (_currentRestaurantId != restaurantId) {
      _currentRestaurantId = restaurantId;
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _service.getRestaurantTables(restaurantId));
    }
  }

  Future<List<RestaurantTable>> getAvailableTables({
    required String restaurantId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    int? minCapacity,
  }) async {
    try {
      return await _service.getAvailableTables(
        restaurantId: restaurantId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        minCapacity: minCapacity,
      );
    } catch (e) {
      throw Exception('Failed to get available tables: $e');
    }
  }
}

// Table Booking Controller
class TableBookingNotifier extends AsyncNotifier<RestaurantBooking?> {
  late RestaurantService _service;

  @override
  Future<RestaurantBooking?> build() async {
    _service = ref.read(restaurantServiceProvider);
    return null;
  }

  Future<RestaurantBooking> createBooking({
    required String restaurantId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required int partySize,
    String? specialRequests,
    String? contactPhone,
  }) async {
    try {
      state = const AsyncLoading();
      
      final booking = await _service.createTableBooking(
        restaurantId: restaurantId,
        tableId: tableId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        partySize: partySize,
        specialRequests: specialRequests,
        contactPhone: contactPhone,
      );

      state = AsyncData(booking);
      
      // Refresh user bookings
      ref.invalidate(userBookingsProvider);
      
      return booking;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _service.cancelBooking(bookingId);
      
      // Refresh user bookings
      ref.invalidate(userBookingsProvider);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}

// User Bookings Controller
class UserBookingsNotifier extends AsyncNotifier<List<RestaurantBooking>> {
  late RestaurantService _service;

  @override
  Future<List<RestaurantBooking>> build() async {
    _service = ref.read(restaurantServiceProvider);
    return _fetchBookings();
  }

  Future<List<RestaurantBooking>> _fetchBookings() async {
    try {
      return await _service.getUserBookings();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<void> refreshBookings() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchBookings());
  }
}

// Time Slots Controller
class TimeSlotNotifier extends AsyncNotifier<List<BookingTimeSlot>> {
  late RestaurantService _service;

  @override
  Future<List<BookingTimeSlot>> build() async {
    _service = ref.read(restaurantServiceProvider);
    return [];
  }

  Future<void> loadTimeSlots({
    required String restaurantId,
    required String tableId,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      _service.getAvailableTimeSlots(
        restaurantId: restaurantId,
        tableId: tableId,
        date: date,
      )
    );
  }
}

// Available Tables Controller  
class AvailableTablesNotifier extends AsyncNotifier<List<RestaurantTable>> {
  late RestaurantService _service;

  @override
  Future<List<RestaurantTable>> build() async {
    _service = ref.read(restaurantServiceProvider);
    return [];
  }

  Future<void> loadAvailableTables({
    required String restaurantId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    int? minCapacity,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      _service.getAvailableTables(
        restaurantId: restaurantId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        minCapacity: minCapacity,
      )
    );
  }
}

// Provider definitions
final restaurantTablesProvider = AsyncNotifierProvider<RestaurantTablesNotifier, List<RestaurantTable>>(() {
  return RestaurantTablesNotifier();
});

final tableBookingProvider = AsyncNotifierProvider<TableBookingNotifier, RestaurantBooking?>(() {
  return TableBookingNotifier();
});

final userBookingsProvider = AsyncNotifierProvider<UserBookingsNotifier, List<RestaurantBooking>>(() {
  return UserBookingsNotifier();
});

final timeSlotsProvider = AsyncNotifierProvider<TimeSlotNotifier, List<BookingTimeSlot>>(() {
  return TimeSlotNotifier();
});

final availableTablesProvider = AsyncNotifierProvider<AvailableTablesNotifier, List<RestaurantTable>>(() {
  return AvailableTablesNotifier();
});

// State providers for UI
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeSlotProvider = StateProvider<BookingTimeSlot?>((ref) => null);
final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);
final partySizeProvider = StateProvider<int>((ref) => 2);

// Family providers for specific data
final restaurantTablesFamily = FutureProvider.family<List<RestaurantTable>, String>((ref, restaurantId) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getRestaurantTables(restaurantId);
});

final availableTablesFamily = FutureProvider.family<List<RestaurantTable>, AvailableTablesParams>((ref, params) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getAvailableTables(
    restaurantId: params.restaurantId,
    date: params.date,
    startTime: params.startTime,
    endTime: params.endTime,
    minCapacity: params.minCapacity,
  );
});

final timeSlotsFamily = FutureProvider.family<List<BookingTimeSlot>, TimeSlotsParams>((ref, params) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getAvailableTimeSlots(
    restaurantId: params.restaurantId,
    tableId: params.tableId,
    date: params.date,
  );
});

// Parameter classes for family providers
class AvailableTablesParams {
  final String restaurantId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int? minCapacity;

  AvailableTablesParams({
    required this.restaurantId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.minCapacity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableTablesParams &&
          runtimeType == other.runtimeType &&
          restaurantId == other.restaurantId &&
          date == other.date &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          minCapacity == other.minCapacity;

  @override
  int get hashCode =>
      restaurantId.hashCode ^
      date.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      minCapacity.hashCode;
}

class TimeSlotsParams {
  final String restaurantId;
  final String tableId;
  final DateTime date;

  TimeSlotsParams({
    required this.restaurantId,
    required this.tableId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotsParams &&
          runtimeType == other.runtimeType &&
          restaurantId == other.restaurantId &&
          tableId == other.tableId &&
          date == other.date;

  @override
  int get hashCode =>
      restaurantId.hashCode ^ tableId.hashCode ^ date.hashCode;
}