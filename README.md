# 🎉 A-Play - Your Ultimate Event Booking Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.2.0-blue.svg)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.4.0-orange.svg)](https://riverpod.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-2.0.0-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A modern, feature-rich event booking and entertainment platform built with Flutter and Supabase. Discover, book, and enjoy amazing events, clubs, restaurants, and entertainment experiences.

## ✨ Features

### 🎫 Event Management
- **Smart Event Discovery** - Browse events by category, location, and date
- **Real-time Booking** - Instant booking with secure payment processing
- **Event Calendar** - Interactive calendar with event scheduling
- **Personalized Recommendations** - AI-powered event suggestions

### 🏪 Club & Restaurant Booking
- **Club Reservations** - Book tables and VIP experiences
- **Restaurant Orders** - Food delivery and dine-in reservations
- **Table Management** - Real-time table availability
- **Special Offers** - Exclusive deals and promotions

### 🎧 Entertainment Hub
- **Podcast Streaming** - Curated audio content
- **Video Content** - Entertainment videos and shows
- **Progress Tracking** - Resume where you left off
- **Favorites System** - Save your favorite content

### 👥 Social Features
- **User Profiles** - Personalized user experience
- **Referral System** - Earn rewards by inviting friends
- **Chat System** - Connect with other users
- **Reviews & Ratings** - Share your experiences

### 💳 Payment & Rewards
- **Secure Payments** - Multiple payment methods
- **Reward Points** - Earn points for bookings
- **Tier System** - Bronze, Silver, Gold, Platinum memberships
- **Point Redemption** - Use points for discounts

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.16.0
- **State Management**: Riverpod 2.4.0
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Payments**: Paystack Integration

### Project Structure
```
lib/
├── core/                    # Core utilities and configurations
│   ├── config/             # App configuration
│   ├── constants/          # App constants
│   ├── providers/          # Global providers
│   ├── services/           # Core services
│   ├── theme/              # App theming
│   └── widgets/            # Shared widgets
├── features/               # Feature modules
│   ├── authentication/     # Auth feature
│   ├── booking/           # Event booking
│   ├── club_booking/      # Club reservations
│   ├── concierge/         # Concierge services
│   ├── explore/           # Event discovery
│   ├── feed/              # Social feed
│   ├── home/              # Home screen
│   ├── location/          # Location services
│   ├── podcast/           # Entertainment content
│   ├── profile/           # User profiles
│   ├── referral/          # Referral system
│   ├── restaurant/        # Restaurant features
│   └── subscription/      # Subscription management
└── data/                  # Data models and repositories
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/a-play-user.git
   cd a-play-user
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project
   - Update `lib/core/config/supabase_config.dart` with your credentials
   - Run database migrations

4. **Configure Firebase (optional)**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

<div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen">
  <img src="screenshots/event_booking.png" width="200" alt="Event Booking">
  <img src="screenshots/club_booking.png" width="200" alt="Club Booking">
  <img src="screenshots/podcast_screen.png" width="200" alt="Podcast Screen">
</div>

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PAYSTACK_PUBLIC_KEY=your_paystack_key
```

### Supabase Setup
1. Create tables for events, bookings, users, etc.
2. Set up Row Level Security (RLS) policies
3. Configure authentication providers
4. Set up storage buckets for images

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Build & Deploy

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

### Web
```bash
# Build for web
flutter build web --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The amazing UI framework
- [Riverpod](https://riverpod.dev/) - State management solution
- [Supabase](https://supabase.com/) - Backend as a service
- [Paystack](https://paystack.com/) - Payment processing

## 📞 Support

- **Email**: support@a-play.com
- **Discord**: [Join our community](https://discord.gg/a-play)
- **Documentation**: [Read our docs](https://docs.a-play.com)

## 🔄 Changelog

### [1.0.0] - 2024-01-15
- Initial release
- Event booking system
- Club and restaurant features
- Podcast and entertainment content
- User authentication and profiles
- Payment integration
- Reward system

---

<div align="center">
  <p>Made with ❤️ by the A-Play Team</p>
  <p>⭐ Star this repository if you found it helpful!</p>
</div>
