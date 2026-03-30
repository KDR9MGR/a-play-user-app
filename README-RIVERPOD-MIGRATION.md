# Migration from BLoC to Riverpod

This document outlines the steps taken to migrate the A Play application from BLoC to Riverpod for state management.

## Changes Made

1. **Dependencies**
   - Added `flutter_riverpod: ^2.6.1` to the project dependencies

2. **Provider Structure**
   - Created global providers in `main.dart` for repositories and use cases
   - Replaced `MultiRepositoryProvider` and `MultiBlocProvider` with `ProviderScope`

3. **State Management Files**
   - Replaced BLoC event/state classes with Riverpod StateNotifier classes
   - Added new provider files:
     - `lib/presentation/home/providers/featured_events_provider.dart`
     - `lib/presentation/booking/providers/booking_provider.dart`

4. **Screen Updates**
   - Updated all consumer screens to use Riverpod:
     - `HomeScreen`: Converted to `ConsumerStatefulWidget`
     - `EventDetailsScreen`: Converted to `ConsumerWidget`
     - `SeatSelectionScreen`: Converted to `ConsumerWidget`
     - `App`: Converted to `ConsumerStatefulWidget`

5. **State Access Changes**
   - Replaced `context.read<Bloc>().add(EventModel())` with `ref.read(provider.notifier).method()`
   - Replaced `BlocBuilder` with direct state access via `ref.watch(provider)`

## Architectural Benefits

1. **Simplicity**
   - Removed the need for event classes, simplifying the codebase
   - More direct access to state and state mutations

2. **Testability**
   - Providers are easily mockable for testing
   - Clear separation of concerns

3. **Performance**
   - Fine-grained reactivity through the provider system
   - More efficient rebuilds with Riverpod's smart dependency tracking

4. **Development Experience**
   - Reduced boilerplate code
   - Simpler debugging with Riverpod DevTools

## Future Improvements

1. Add family providers for parameterized data fetching
2. Implement caching strategies using Riverpod
3. Add error handling middleware
4. Consider using AsyncValue for better handling of loading/error states 