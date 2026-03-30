# ⚡ Quick Start: Schema Migration Guide

## 🚀 Immediate Actions Required

### Step 1: Update Models (DO THIS FIRST)

```bash
# 1. Back up current models
cp lib/features/subscription/model/subscription_model.dart lib/features/subscription/model/subscription_model.dart.backup

# 2. Update the model files (see detailed changes below)

# 3. Run build_runner
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Critical Code Changes

#### ❗ CHANGE 1: Subscription Plan Pricing

**BEFORE** (Old - Will Break):
```dart
// ❌ OLD - Don't use
final price = plan.price;  // This field no longer exists!
```

**AFTER** (New - Use This):
```dart
// ✅ NEW - Use this
final monthlyPrice = plan.priceMonthly;
final annualPrice = plan.priceYearly;

// For display:
final price = billingCycle == 'monthly' ? plan.priceMonthly : plan.priceYearly;
```

#### ❗ CHANGE 2: Tier Names

**BEFORE** (Old):
```dart
// ❌ OLD tier names
"Bronze", "Silver", "Gold"
```

**AFTER** (New):
```dart
// ✅ NEW tier names
"Free", "Gold", "Platinum", "Black"
```

#### ❗ CHANGE 3: Features Access

**BEFORE** (Old):
```dart
// ❌ OLD - Simple fields
final discount = plan.discountPercentage;
```

**AFTER** (New):
```dart
// ✅ NEW - Nested in features object
final discount = plan.features.discountPercentage;
final pointsMultiplier = plan.features.pointsMultiplier;
final earlyAccess = plan.features.earlyBookingHours;
```

---

## 📦 New Model Structure

### Subscription Plan (Updated)

```dart
// lib/features/subscription/model/subscription_model.dart
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,

    // NEW: Separate monthly and yearly pricing
    @JsonKey(name: 'price_monthly') required double priceMonthly,
    @JsonKey(name: 'price_yearly') required double priceYearly,

    // NEW: Tier level (1-4)
    @JsonKey(name: 'tier_level') required int tierLevel,

    // NEW: Rich features object
    required PlanFeatures features,

    // NEW: Benefits array
    @Default([]) List<String> benefits,

    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}
```

### Plan Features (NEW)

```dart
@freezed
class PlanFeatures with _$PlanFeatures {
  const factory PlanFeatures({
    required String tier,
    required String color,
    @JsonKey(name: 'points_multiplier') @Default(1) int pointsMultiplier,
    @JsonKey(name: 'discount_percentage') @Default(0) int discountPercentage,
    @JsonKey(name: 'early_booking_hours') @Default(0) int earlyBookingHours,
    @JsonKey(name: 'concierge_access') @Default(false) bool conciergeAccess,
    @JsonKey(name: 'vip_entry') @Default(false) bool vipEntry,
    @JsonKey(name: 'vip_lounge_access') @Default(false) bool vipLoungeAccess,
    @JsonKey(name: 'points_per_booking') @Default(10) int pointsPerBooking,
    @JsonKey(name: 'points_per_review') @Default(5) int pointsPerReview,
    // ... more fields in full model
  }) = _PlanFeatures;

  factory PlanFeatures.fromJson(Map<String, dynamic> json) =>
      _$PlanFeaturesFromJson(json);
}
```

---

## 🎨 UI Quick Updates

### Display 4 Tiers with Colors

```dart
// Tier Colors
final tierColors = {
  'Free': Colors.grey,
  'Gold': Color(0xFFFFD700),
  'Platinum': Color(0xFFE5E4E2),
  'Black': Color(0xFF000000),
};

// Tier Icons
final tierIcons = {
  'Free': Icons.star_border,
  'Gold': Icons.star_half,
  'Platinum': Icons.star,
  'Black': Icons.workspace_premium,
};

// Usage
Container(
  color: tierColors[plan.name],
  child: Row(
    children: [
      Icon(tierIcons[plan.name]),
      Text(plan.name),
      Text('${plan.features.pointsMultiplier}x Points'),
    ],
  ),
)
```

### Monthly/Annual Toggle

```dart
String billingCycle = 'monthly';

// Toggle widget
ToggleButtons(
  isSelected: [
    billingCycle == 'monthly',
    billingCycle == 'annual',
  ],
  onPressed: (index) {
    setState(() {
      billingCycle = index == 0 ? 'monthly' : 'annual';
    });
  },
  children: [
    Text('Monthly'),
    Text('Annual (Save 17%)'),
  ],
);

// Display price
Text(
  'GH₵${billingCycle == "monthly" ? plan.priceMonthly : plan.priceYearly}'
);
```

### Benefits List

```dart
// Display benefits array
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: plan.benefits.map((benefit) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 16),
        SizedBox(width: 8),
        Expanded(child: Text(benefit)),
      ],
    );
  }).toList(),
)
```

---

## 🎁 Points System Integration

### Display Points Balance

```dart
// In app bar or profile
class PointsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(userSubscriptionProvider);

    return subscription.when(
      data: (sub) => Row(
        children: [
          Icon(Icons.stars, color: Colors.amber),
          SizedBox(width: 4),
          Text('${sub?.rewardPoints ?? 0} pts'),
        ],
      ),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => SizedBox(),
    );
  }
}
```

### Award Points After Booking

```dart
// After successful event booking
Future<void> onEventBooked(String userId, String eventId) async {
  final subscription = await subscriptionService.getUserSubscription(userId);
  final pointsToAward = subscription?.subscriptionPlans?.features.pointsPerBooking ?? 10;

  await subscriptionService.awardPoints(
    userId: userId,
    points: pointsToAward,
    action: 'event_booking',
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('You earned $pointsToAward points!')),
  );
}
```

---

## 👥 Referral System Integration

### Display Referral Code

```dart
class ReferralCodeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.id ?? '';
    final codeAsync = ref.watch(referralCodeProvider(userId));

    return codeAsync.when(
      data: (code) => Card(
        child: Column(
          children: [
            Text('Your Referral Code'),
            Text(code ?? 'N/A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.share('Use my code: $code to join A-Play!'),
            ),
          ],
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Error loading code'),
    );
  }
}
```

---

## 🔧 Service Updates

### Fetch Plans (Updated)

```dart
// lib/features/subscription/service/subscription_service.dart
Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
  final response = await supabase
      .from('subscription_plans')
      .select()
      .eq('is_active', true)
      .order('tier_level', ascending: true);  // NEW: Order by tier_level

  return response.map((json) => SubscriptionPlan.fromJson(json)).toList();
}
```

### Get User Subscription with Features

```dart
Future<UserSubscription?> getUserSubscription(String userId) async {
  final response = await supabase
      .from('user_subscriptions')
      .select('''
        *,
        subscription_plans (
          *
        )
      ''')
      .eq('user_id', userId)
      .eq('status', 'active')
      .maybeSingle();

  if (response == null) return null;
  return UserSubscription.fromJson(response);
}
```

---

## 🎯 Apply Tier Benefits

### Calculate Discounted Price

```dart
double getDiscountedPrice(double basePrice, PlanFeatures features) {
  final discountPercent = features.discountPercentage;
  final discount = (basePrice * discountPercent) / 100;
  return basePrice - discount;
}

// Usage
final basePrice = 100.0;  // Event price
final userTierFeatures = subscription.subscriptionPlans?.features;
final finalPrice = getDiscountedPrice(basePrice, userTierFeatures);

// Display
Text('Original: GH₵$basePrice');
if (userTierFeatures.discountPercentage > 0) {
  Text('Your Price: GH₵$finalPrice (${userTierFeatures.discountPercentage}% off)');
}
```

### Check Early Access

```dart
bool hasEarlyAccess(DateTime eventDate, PlanFeatures features) {
  final now = DateTime.now();
  final earlyAccessHours = features.earlyBookingHours;
  final earlyAccessDate = eventDate.subtract(Duration(hours: earlyAccessHours));

  return now.isAfter(earlyAccessDate);
}

// Usage in UI
if (hasEarlyAccess(event.startDate, userFeatures)) {
  ElevatedButton(
    onPressed: () => bookEvent(),
    child: Text('Book Now'),
  );
} else {
  Text('Available in ${calculateHoursUntil(event.startDate, userFeatures)} hours');
}
```

---

## 📱 Updated Providers

```dart
// lib/features/subscription/provider/subscription_provider.dart

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionPlans();
});

final userSubscriptionProvider = FutureProvider.family<UserSubscription?, String>((ref, userId) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getUserSubscription(userId);
});

final referralCodeProvider = FutureProvider.family<String?, String>((ref, userId) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getReferralCode(userId);
});

final userReferralsProvider = FutureProvider.family<List<Referral>, String>((ref, userId) async {
  final response = await Supabase.instance.client
      .from('referrals')
      .select()
      .eq('referrer_user_id', userId)
      .order('created_at', ascending: false);

  return response.map((json) => Referral.fromJson(json)).toList();
});
```

---

## ⚡ Migration Commands

```bash
# 1. Update models
# (Copy updated model code from USER_APP_SCHEMA_UPDATE_PLAN.md)

# 2. Generate Freezed code
flutter packages pub run build_runner build --delete-conflicting-outputs

# 3. Run flutter analyze
flutter analyze

# 4. Test the app
flutter run
```

---

## 🐛 Common Issues & Fixes

### Issue 1: "price field not found"
```dart
// ❌ Wrong
Text('GH₵${plan.price}')

// ✅ Correct
Text('GH₵${plan.priceMonthly}')
```

### Issue 2: "features.discountPercentage not accessible"
```dart
// ❌ Wrong
final discount = plan.discountPercentage;

// ✅ Correct
final discount = plan.features.discountPercentage;
```

### Issue 3: "Bronze tier not found"
```dart
// ❌ Wrong - Old tier names
if (tierName == 'Bronze') { ... }

// ✅ Correct - New tier names
if (tierName == 'Free') { ... }
```

---

## 📚 Full Documentation References

- **Detailed Plan**: See `USER_APP_SCHEMA_UPDATE_PLAN.md`
- **Admin Panel Guide**: See `COMPLETE_INTEGRATION_GUIDE.md`
- **Subscription Plans**: See `SUBSCRIPTION_PLANS.md`
- **Upcoming Events Fix**: See `UPCOMING_EVENTS_AND_CLUB_FEATURES_ANALYSIS.md`

---

**Status**: Ready for Implementation
**Priority**: HIGH
**Estimated Time**: 4 weeks
**Start Date**: Immediately after approval
