# Guide: Hide Non-MVP Features

**Purpose:** Disable secondary features and show "Coming Soon" message
**Target Launch:** MVP with Auth, Events, Subscriptions, Chat/Feed only

---

## 🎯 Features to Hide

| Feature | Location | Action Required |
|---------|----------|----------------|
| Restaurant Bookings | Bottom Nav + Home | Replace with Coming Soon screen |
| Club Bookings | Home Cards | Hide card or show Coming Soon |
| Podcast/YouTube | Home/Explore | Hide section |
| Referral System | Profile | Hide referral UI |

**Keep Visible:**
- ✅ Concierge (Gold+ only - already has tier restrictions)
- ✅ Location Services (needed for events)
- ✅ Profile Management

---

## 📝 Implementation Steps

### Step 1: Update Bottom Navigation (High Priority)

**File:** `/lib/features/navbar.dart`

The bottom navigation currently has 5 tabs:
1. Home ✅ Keep
2. Explore ✅ Keep
3. Bookings ✅ Keep
4. Concierge ✅ Keep (Gold+ only)
5. Feed ✅ Keep

**No changes needed** - Bottom nav is MVP-ready!

---

### Step 2: Hide Restaurant Tab in Bookings

**File:** `/lib/features/booking/screens/my_tickets_screen.dart`

Current implementation has tabs for Events and Restaurants. We need to hide the Restaurant tab.

**Find this code** (around line 80-100):
```dart
TabBar(
  tabs: const [
    Tab(text: 'Events'),
    Tab(text: 'Restaurants'),
  ],
)
```

**Replace with:**
```dart
// MVP: Hide Restaurant bookings tab
TabBar(
  tabs: const [
    Tab(text: 'Events'),
    // Tab(text: 'Restaurants'), // Coming soon in v2
  ],
)

// Also update TabBarView to only show Events
TabBarView(
  children: [
    _buildEventBookings(),
    // _buildRestaurantBookings(), // Coming soon in v2
  ],
)
```

---

### Step 3: Hide Non-MVP Cards from Home Screen

**File:** `/lib/features/home/screens/home_screen.dart`

**Sections to Hide:**
1. Restaurant section
2. Club section
3. Podcast section

**Implementation:**

```dart
// Around the restaurant section
// BEFORE:
_buildRestaurantSection(),

// AFTER:
// _buildRestaurantSection(), // MVP: Coming soon in v2

// OR show Coming Soon banner:
GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ComingSoonScreen(
        featureName: 'Restaurant Bookings',
        description: 'Book tables and order delicious food from top restaurants in Ghana',
        icon: Icons.restaurant,
      ),
    ),
  ),
  child: _buildFeatureCard(
    title: 'Restaurants',
    subtitle: 'Coming Soon',
    icon: Icons.restaurant,
    gradient: LinearGradient(
      colors: [Colors.orange, Colors.deepOrange],
    ),
  ),
),
```

**Apply same pattern for:**
- Club bookings section
- Podcast/Entertainment section

---

### Step 4: Update Router (Prevent Direct Access)

**File:** `/lib/config/router.dart`

**Add route guards** for non-MVP features:

```dart
// Restaurant routes
GoRoute(
  path: '/restaurants',
  builder: (context, state) => ComingSoonScreen(
    featureName: 'Restaurant Bookings',
    description: 'Book tables and order food from top restaurants',
    icon: Icons.restaurant,
  ),
),

// Club routes
GoRoute(
  path: '/clubs',
  builder: (context, state) => ComingSoonScreen(
    featureName: 'Club Bookings',
    description: 'Reserve VIP tables at exclusive clubs',
    icon: Icons.nightlife,
  ),
),

// Podcast routes
GoRoute(
  path: '/podcasts',
  builder: (context, state) => ComingSoonScreen(
    featureName: 'Podcasts & Videos',
    description: 'Stream exclusive content and entertainment',
    icon: Icons.play_circle_filled,
  ),
),
```

---

### Step 5: Hide Referral UI from Profile

**File:** `/lib/features/profile/screens/profile_screen.dart` (or similar)

**Find referral section** and wrap with condition:

```dart
// BEFORE:
_buildReferralCard(),

// AFTER:
// MVP: Hide referral system
// _buildReferralCard(), // Coming soon in v2

// OR add Coming Soon banner:
const ComingSoonBanner(
  message: 'Refer & Earn - Coming Soon',
  compact: true,
),
```

---

### Step 6: Add Feature Flags (Optional but Recommended)

Create a feature flags file for easy toggling:

**Create:** `/lib/config/feature_flags.dart`

```dart
/// Feature flags for MVP launch
class FeatureFlags {
  // MVP Core Features
  static const bool enableAuth = true;
  static const bool enableEventBookings = true;
  static const bool enableSubscriptions = true;
  static const bool enableChat = true;
  static const bool enableFeed = true;

  // Non-MVP Features (disabled for launch)
  static const bool enableRestaurants = false;
  static const bool enableClubs = false;
  static const bool enableConcierge = true; // Keep for Gold+ users
  static const bool enablePodcasts = false;
  static const bool enableReferrals = false;

  // Experimental Features
  static const bool enableVideoContent = false;
  static const bool enableStories = false;
  static const bool enableVoiceMessages = false;

  /// Check if feature is enabled
  static bool isEnabled(String feature) {
    switch (feature) {
      case 'restaurants':
        return enableRestaurants;
      case 'clubs':
        return enableClubs;
      case 'concierge':
        return enableConcierge;
      case 'podcasts':
        return enablePodcasts;
      case 'referrals':
        return enableReferrals;
      default:
        return false;
    }
  }
}
```

**Usage in code:**

```dart
import 'package:a_play/config/feature_flags.dart';

// In home screen
if (FeatureFlags.enableRestaurants) {
  _buildRestaurantSection(),
} else {
  _buildComingSoonCard('Restaurants', Icons.restaurant),
}
```

---

## 🧪 Testing Checklist

After hiding non-MVP features:

- [ ] Home screen displays only MVP features
- [ ] Restaurant tab hidden in Bookings
- [ ] Clicking disabled features shows Coming Soon screen
- [ ] Direct URL navigation shows Coming Soon
- [ ] No broken navigation links
- [ ] Bottom nav still works correctly
- [ ] Concierge remains visible for Gold+ users
- [ ] App builds without errors
- [ ] No console warnings related to hidden features

---

## 📦 Files to Modify

### Must Modify:
1. `/lib/features/navbar.dart` - Bottom navigation
2. `/lib/features/booking/screens/my_tickets_screen.dart` - Hide restaurant tab
3. `/lib/features/home/screens/home_screen.dart` - Hide feature cards
4. `/lib/config/router.dart` - Add Coming Soon routes

### Should Modify:
5. `/lib/features/profile/screens/profile_screen.dart` - Hide referral UI
6. `/lib/features/explore/screens/explore_screen.dart` - Hide non-MVP categories

### Optional:
7. `/lib/config/feature_flags.dart` - Create feature flags (New file)

---

## 🎨 Coming Soon Widget Usage

**Already Created:** `/lib/core/widgets/coming_soon_widget.dart`

### Full Screen:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ComingSoonScreen(
      featureName: 'Restaurant Bookings',
      description: 'Book tables and order delicious food from top restaurants',
      icon: Icons.restaurant,
    ),
  ),
);
```

### Inline Banner:
```dart
const ComingSoonBanner(
  message: 'Coming Soon',
  compact: true,
)
```

### Custom Widget:
```dart
ComingSoonWidget(
  featureName: 'Premium Feature',
  description: 'This feature will be available soon!',
  icon: Icons.star,
  showBackButton: true,
)
```

---

## ⚠️ Important Notes

1. **Concierge Services:** DO NOT hide - it's a premium feature for Gold+ users
2. **Backend:** No need to modify backend/database - just hide UI
3. **Analytics:** Add tracking for Coming Soon screen views to gauge interest
4. **Gradual Rollout:** Use feature flags to enable features gradually post-launch
5. **User Feedback:** Consider adding "Request Feature" button in Coming Soon screen

---

## 🚀 Deployment Order

1. **Phase 1:** Hide UI (this guide)
2. **Phase 2:** Update routes
3. **Phase 3:** Test thoroughly
4. **Phase 4:** Deploy to staging
5. **Phase 5:** Final QA
6. **Phase 6:** Production release

---

## 📊 Expected Impact

**Before:**
- 9 major features visible
- Complex navigation
- Longer testing required

**After:**
- 4 core features (MVP)
- Simplified user experience
- Faster time to market
- Focused user testing
- Clearer value proposition

---

## 🔄 Re-enabling Features (Post-Launch)

When ready to launch hidden features:

1. Update `FeatureFlags` constants to `true`
2. Uncomment hidden UI code
3. Update routes
4. Test thoroughly
5. Deploy gradually (beta users first)
6. Monitor analytics and performance
7. Full rollout

---

**Estimated Implementation Time:** 2-4 hours
**Testing Time:** 2-3 hours
**Total:** 1 day max

**Next Steps:**
1. Review this guide
2. Make changes to files listed above
3. Run `flutter analyze`
4. Test on device
5. Create PR for review
6. Deploy to staging

---

**Questions?** Refer to [MVP_TASK_BOARD.md](./MVP_TASK_BOARD.md) for complete task list.
