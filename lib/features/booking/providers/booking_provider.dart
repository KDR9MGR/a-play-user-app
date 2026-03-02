import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingState {
  final Set<String> selectedSeats;
  final List<String> bookedSeats;
  final bool isLoading;
  final String? errorMessage;

  const BookingState({
    this.selectedSeats = const {},
    this.bookedSeats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BookingState copyWith({
    Set<String>? selectedSeats,
    List<String>? bookedSeats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingState(
      selectedSeats: selectedSeats ?? this.selectedSeats,
      bookedSeats: bookedSeats ?? this.bookedSeats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void selectSeat(String seatId) {
    if (!state.bookedSeats.contains(seatId)) {
      state = state.copyWith(
        selectedSeats: {...state.selectedSeats, seatId},
        errorMessage: null,
      );
    }
  }

  void unselectSeat(String seatId) {
    state = state.copyWith(
      selectedSeats: state.selectedSeats.where((id) => id != seatId).toSet(),
      errorMessage: null,
    );
  }

  Future<void> loadBookedSeats(String eventId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      // TODO: Implement API call to get booked seats
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      state = state.copyWith(
        bookedSeats: [], // This will come from the API
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load booked seats',
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(
      selectedSeats: {},
      errorMessage: null,
    );
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
}); 