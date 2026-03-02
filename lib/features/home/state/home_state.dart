import 'package:a_play/features/home/model/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_play/core/services/location_service.dart';

class HomeState {
  final List<EventModel> featuredEvents;
  final List<EventModel> upcomingEvents;
  final List<EventModel> nearbyEvents;
  final bool isLoading;
  final bool isLoadingLocation;
  final String? error;
  final int currentCarouselIndex;
  final int currentPage;
  final int itemsPerPage;
  final bool hasMoreItems;
  final double? latitude;
  final double? longitude;

  const HomeState({
    this.featuredEvents = const [],
    this.upcomingEvents = const [],
    this.nearbyEvents = const [],
    this.isLoading = false,
    this.isLoadingLocation = false,
    this.error,
    this.currentCarouselIndex = 0,
    this.currentPage = 0,
    this.itemsPerPage = 10,
    this.hasMoreItems = true,
    this.latitude,
    this.longitude,
  });

  HomeState copyWith({
    List<EventModel>? featuredEvents,
    List<EventModel>? upcomingEvents,
    List<EventModel>? nearbyEvents,
    bool? isLoading,
    bool? isLoadingLocation,
    String? error,
    int? currentCarouselIndex,
    int? currentPage,
    int? itemsPerPage,
    bool? hasMoreItems,
    double? latitude,
    double? longitude,
  }) {
    return HomeState(
      featuredEvents: featuredEvents ?? this.featuredEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      nearbyEvents: nearbyEvents ?? this.nearbyEvents,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      error: error ?? this.error,
      currentCarouselIndex: currentCarouselIndex ?? this.currentCarouselIndex,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class HomeStateNotifier extends StateNotifier<HomeState> {
  final LocationService _locationService;

  HomeStateNotifier(this._locationService) : super(const HomeState()) {
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final position = await _locationService.getCurrentLocation();
      state = state.copyWith(
        isLoading: false,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshLocation() async {
    await _initLocation();
  }
} 