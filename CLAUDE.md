# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Constraints

**IMPORTANT**: This project runs in a Windows environment with Flutter installed on Windows, but Claude Code operates from WSL (Windows Subsystem for Linux). This means:

- Claude Code can read/write files via mounted Windows drives (`/mnt/e/`)
- Claude Code **CANNOT** execute Flutter commands directly (flutter analyze, flutter run, etc.)
- User must run Flutter commands manually from Windows terminal

## Common Commands (Run these in Windows terminal)

### Development Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter clean` - Clean build artifacts
- `flutter analyze` - Run static analysis and check for linter errors
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Generate code for Freezed models and JSON serialization

### Testing Commands
- `flutter test` - Run all unit tests
- `flutter test test/specific_test.dart` - Run a specific test file
- `flutter integration_test` - Run integration tests
- `flutter test --coverage` - Run tests with coverage

### Build Commands
- `flutter build apk --release` - Build Android APK
- `flutter build appbundle --release` - Build Android App Bundle
- `flutter build ios --release` - Build iOS app
- `flutter build web --release` - Build web version

### Code Generation
- `flutter packages pub run build_runner build` - Generate Freezed and JSON serialization code
- `flutter packages pub run build_runner watch` - Watch for changes and auto-generate code
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Rebuild with conflict resolution

## Workflow Notes

1. **After making code changes**: Ask the user to run `flutter analyze` to check for errors
2. **After creating/modifying Freezed models**: Ask the user to run `flutter packages pub run build_runner build`
3. **Before committing**: Always remind the user to run `flutter analyze` as per CLAUDE.md instructions
4. **For testing**: Ask the user to run appropriate test commands

## Architecture Overview

This is a Flutter event booking application for Ghana built with **Clean Architecture** principles using **Riverpod** for state management and **Supabase** as the backend.

### Key Architectural Patterns

**State Management**: Recently migrated from BLoC to **Riverpod** (v2.4.9). All state management follows these patterns:
- `AsyncNotifier<T>` for complex state management
- `AsyncNotifierProvider` for exposing state
- `AsyncValue.when()` for handling loading/error/data states
- `ref.invalidate()` to refresh providers after mutations

**Feature Structure**: Each feature follows this consistent pattern (from .cursorrules):
```
lib/features/<feature_name>/
├── model/          # Freezed immutable data models
├── service/        # API interactions and business logic
├── controller/     # AsyncNotifier state management
├── provider/       # AsyncNotifierProvider definitions
├── view/           # UI screens (note: some legacy code uses 'screens/')
└── widgets/        # Reusable UI components
```

**Backend Integration**: Uses **Supabase** for:
- Authentication (email/password, Google OAuth)
- PostgreSQL database with Row Level Security
- Real-time subscriptions
- File storage
- Initialize with `Supabase.instance.client`

### Core Application Features

1. **Multi-Service Platform**
   - **Event Booking**: Discovery, booking, zone-based seating, QR tickets
   - **Club Reservations**: Table bookings and VIP experiences  
   - **Restaurant System**: Food ordering and table reservations
   - **Concierge Services**: Premium user services
   - **Entertainment Hub**: Podcast streaming with YouTube integration

2. **Authentication & Social Features**
   - Supabase Auth with stream-based state management
   - Route protection via RouterNotifier in `lib/config/router.dart`
   - User profiles with premium tier badges
   - Chat system and social feed
   - Referral system with rewards

3. **Payment & Subscription System**
   - PayStack integration for secure payments
   - Tier-based subscriptions (Bronze/Silver/Gold/Platinum)
   - Points and rewards system
   - Payment history tracking

4. **Navigation Architecture**
   - GoRouter 13.0.0 for declarative routing
   - Bottom navigation with 5 tabs: Home, Explore, Bookings, Concierge, Feed
   - Nested routes for complex flows
   - Authentication-based route protection

### Development Rules (from .cursorrules)

**Code Structure**:
- Use **Freezed** for all data models in `lib/features/<feature_name>/model/`
- Implement API interactions in `lib/features/<feature_name>/service/`
- Manage state using **AsyncNotifier** in `lib/features/<feature_name>/controller/`
- Expose providers via **AsyncNotifierProvider** in `lib/features/<feature_name>/provider/`
- Design UI in `lib/features/<feature_name>/view/` using `AsyncValue.when`
- Use `ref.invalidate()` to refresh providers after mutations
- Keep business logic out of UI components

**Supabase Integration Standards**:
- Initialize client with `Supabase.instance.client`
- Use try-catch blocks with meaningful error messages
- Return strongly typed models from API calls
- Avoid direct Supabase calls in UI or controller layers

**State Management Best Practices**:
- Extend `AsyncNotifier<T>` for state classes
- Implement `build()` method for initial data fetching
- Use separate methods for data mutations
- Set state using `AsyncData`, `AsyncLoading`, and `AsyncError`
- Avoid long-running operations in `build()` method

**UI Development Guidelines**:
- Use `ref.watch(provider)` for reactive state access in widgets
- Handle different states using `AsyncValue.when` method
- Keep widgets small and focused; extract reusable components
- Use shared widgets from `lib/core/widgets/` when applicable
- Note: Some legacy code may still use `screens/` instead of `view/` directory

## Key Technologies

- **Framework**: Flutter SDK >=3.1.3 <4.0.0 (from pubspec.yaml)
- **State Management**: Riverpod 2.4.9
- **Backend**: Supabase 2.0.0
- **Navigation**: GoRouter 13.0.0
- **Code Generation**: Freezed, JSON Serializable
- **Payment**: PayStack integration
- **Authentication**: Supabase Auth with Google OAuth
- **UI**: Custom dark theme with Google Fonts (Poppins)

## Environment Setup

Required environment variables (create `.env` file):
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PAYSTACK_PUBLIC_KEY=your_paystack_public_key
```

## Database Schema

Key Supabase tables:
- `profiles` - User profiles with premium status
- `events` - Event information with categories and locations
- `bookings` - Event bookings with zone-based seating
- `clubs` - Club/venue information for reservations
- `subscription_plans` - Available subscription tiers
- `user_subscriptions` - User subscription records
- `referrals` - Referral codes and tracking system
- `user_points` - Points and rewards system

## Important Notes

- Always run `flutter analyze` before committing changes
- Use `flutter packages pub run build_runner build` after creating/modifying Freezed models
- Follow the established feature-based folder structure
- Implement proper error handling in all service methods
- Use `ref.watch()` for reactive state access in UI
- Use `ref.read()` for one-time state access or calling methods
- Authentication state is globally managed - check `authStateProvider`
- The app uses a custom dark theme defined in `lib/core/theme/`

## Migration Context

This project recently migrated from BLoC to Riverpod. While some legacy BLoC dependencies remain in pubspec.yaml (`flutter_bloc: ^9.1.1`, `equatable: ^2.0.7`), all new code should use Riverpod patterns. The migration improved code simplicity, testability, and performance with fine-grained reactivity.

## Project Structure Notes

The codebase has some architectural inconsistencies due to the migration:
- Some features follow the new Riverpod structure: `lib/features/<feature>/model|service|controller|provider|view|widgets/`
- Legacy features may use different patterns like `presentation/` or `screens/` directories
- When working with existing features, maintain their current structure unless explicitly refactoring
- For new features, always follow the Riverpod architecture pattern defined above