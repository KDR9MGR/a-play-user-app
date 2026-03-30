/// Feature flags for MVP launch
/// Controls which features are visible to users
///
/// Usage:
/// ```dart
/// if (FeatureFlags.enableRestaurants) {
///   // Show restaurant features
/// }
/// ```
class FeatureFlags {
  // ==========================================
  // MVP CORE FEATURES (Always Enabled)
  // ==========================================

  /// Authentication (Email, Google, Apple Sign In)
  static const bool enableAuth = true;

  /// Event bookings with PayStack payment
  static const bool enableEventBookings = true;

  /// Subscription purchase (PayStack + Apple IAP)
  static const bool enableSubscriptions = true;

  /// Chat system (1-on-1 and group chat)
  static const bool enableChat = true;

  /// Social feed (posts, likes, comments)
  static const bool enableFeed = true;

  // ==========================================
  // NON-MVP FEATURES (Disabled for MVP Launch)
  // ==========================================

  /// Restaurant table bookings and food orders
  /// Coming Soon in v2.1
  static const bool enableRestaurants = false;

  /// Club/VIP table reservations
  /// Coming Soon in v2.1
  static const bool enableClubs = false;

  /// Podcast and YouTube content streaming
  /// Coming Soon in v2.2
  static const bool enablePodcasts = false;

  /// Referral system and rewards
  /// Coming Soon in v2.2
  static const bool enableReferrals = false;

  // ==========================================
  // PREMIUM FEATURES (Keep for paid tiers)
  // ==========================================

  /// Concierge services (Gold tier: 3/month, Platinum+: unlimited)
  /// Keep enabled - Premium feature for paying users
  static const bool enableConcierge = true;

  // ==========================================
  // SUPPORTING FEATURES (Always Enabled)
  // ==========================================

  /// Location services for events
  static const bool enableLocation = true;

  /// Profile management
  static const bool enableProfile = true;

  /// Search functionality
  static const bool enableSearch = true;

  // ==========================================
  // EXPERIMENTAL FEATURES (Future)
  // ==========================================

  /// Video posts in social feed
  static const bool enableVideoContent = false;

  /// Instagram-style stories
  static const bool enableStories = false;

  /// Voice messages in chat
  static const bool enableVoiceMessages = false;

  /// Live streaming events
  static const bool enableLiveStreaming = false;

  /// In-app wallet
  static const bool enableWallet = false;

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Check if a specific feature is enabled
  ///
  /// Usage:
  /// ```dart
  /// if (FeatureFlags.isEnabled('restaurants')) {
  ///   // Show feature
  /// }
  /// ```
  static bool isEnabled(String feature) {
    switch (feature.toLowerCase()) {
      // MVP Core
      case 'auth':
      case 'authentication':
        return enableAuth;
      case 'events':
      case 'event_bookings':
        return enableEventBookings;
      case 'subscriptions':
      case 'subscription_purchase':
        return enableSubscriptions;
      case 'chat':
      case 'messaging':
        return enableChat;
      case 'feed':
      case 'social_feed':
        return enableFeed;

      // Non-MVP
      case 'restaurants':
      case 'restaurant_bookings':
        return enableRestaurants;
      case 'clubs':
      case 'club_bookings':
        return enableClubs;
      case 'podcasts':
      case 'youtube':
      case 'entertainment':
        return enablePodcasts;
      case 'referrals':
      case 'refer_and_earn':
        return enableReferrals;

      // Premium
      case 'concierge':
      case 'concierge_services':
        return enableConcierge;

      // Experimental
      case 'video_content':
        return enableVideoContent;
      case 'stories':
        return enableStories;
      case 'voice_messages':
        return enableVoiceMessages;
      case 'live_streaming':
        return enableLiveStreaming;
      case 'wallet':
        return enableWallet;

      default:
        return false;
    }
  }

  /// Get a list of all enabled features
  static List<String> getEnabledFeatures() {
    final enabled = <String>[];

    if (enableAuth) enabled.add('Authentication');
    if (enableEventBookings) enabled.add('Event Bookings');
    if (enableSubscriptions) enabled.add('Subscriptions');
    if (enableChat) enabled.add('Chat');
    if (enableFeed) enabled.add('Social Feed');
    if (enableConcierge) enabled.add('Concierge Services');
    if (enableRestaurants) enabled.add('Restaurant Bookings');
    if (enableClubs) enabled.add('Club Bookings');
    if (enablePodcasts) enabled.add('Podcasts');
    if (enableReferrals) enabled.add('Referrals');

    return enabled;
  }

  /// Get a list of disabled features (coming soon)
  static List<String> getComingSoonFeatures() {
    final comingSoon = <String>[];

    if (!enableRestaurants) comingSoon.add('Restaurant Bookings');
    if (!enableClubs) comingSoon.add('Club Bookings');
    if (!enablePodcasts) comingSoon.add('Podcasts & Entertainment');
    if (!enableReferrals) comingSoon.add('Referral System');

    return comingSoon;
  }

  /// Check if app is in MVP mode (only core features enabled)
  static bool get isMVPMode {
    return enableAuth &&
        enableEventBookings &&
        enableSubscriptions &&
        enableChat &&
        enableFeed &&
        !enableRestaurants &&
        !enableClubs &&
        !enablePodcasts &&
        !enableReferrals;
  }

  /// Get MVP version string
  static String get mvpVersion => isMVPMode ? 'MVP 1.0' : 'Full Version';
}
