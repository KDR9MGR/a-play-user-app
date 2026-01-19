# 🔄 User App Schema Update Plan - Alignment with Admin Panel

**Date**: December 16, 2024
**Status**: Action Required
**Priority**: HIGH

---

## 📊 Critical Schema Changes from Admin Panel

### **1. BREAKING CHANGE: `subscription_plans.id` Type Changed**

**Old Schema**:
```dart
// lib/features/subscription/model/subscription_model.dart
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,  // Was UUID string
    required String name,
    @JsonKey(name: 'price') required double price,  // Single price field
    // ...
  }) = _SubscriptionPlan;
}
```

**New Schema** (Admin Panel):
```typescript
interface SubscriptionPlan {
  id: string;  // TEXT (not UUID) - e.g., "abc123-def456"
  name: string;  // "Free", "Gold", "Platinum", "Black"
  price_monthly: number;  // NEW - Separate monthly pricing
  price_yearly: number;   // NEW - Separate annual pricing
  tier_level: number;     // NEW - 1, 2, 3, 4 for sorting
  features: PlanFeatures; // JSONB - Rich feature object
  benefits: string[];     // NEW - Array of benefit strings
  // Old 'price' field is DEPRECATED
}
```

**Impact**:
- ❗ Existing `price` field queries will fail
- ❗ Must update to use `price_monthly` and `price_yearly`
- ❗ `id` may not follow UUID format anymore

---

### **2. NEW: 4-Tier Subscription System**

**Old System**: 3 tiers (Bronze, Silver, Gold)
**New System**: 4 tiers (Free, Gold, Platinum, Black)

| Tier | Level | Monthly | Annual | Points Multiplier | Discount |
|------|-------|---------|--------|-------------------|----------|
| Free | 1 | GH₵0 | GH₵0 | 1x | 0% |
| Gold | 2 | GH₵120 | GH₵1,200 | 2x | 10% |
| Platinum | 3 | GH₵250 | GH₵2,500 | 3x | 15% |
| Black | 4 | GH₵500 | GH₵5,000 | 5x | 20% |

**Changes Required**:
- Update UI to show 4 tiers instead of 3
- Add tier level badges
- Update tier colors (Free: Gray, Gold: #FFD700, Platinum: Silver, Black: #000)
- Remove Bronze/Silver references

---

### **3. NEW: Rich Features JSONB Object**

**Old**: Simple feature flags
**New**: Comprehensive features object

```typescript
features: {
  tier: "Gold",
  color: "#FFD700",
  points_multiplier: 2,
  discount_percentage: 10,
  early_booking_hours: 48,
  concierge_access: true,
  concierge_hours: "business_hours",
  vip_entry: false,
  priority_support: true,
  free_reservations_per_month: 3,
  vip_lounge_access: true,
  event_upgrades_per_month: 1,
  points_per_booking: 20,
  points_per_review: 10,
  referral_limit: 10,
  support_response_hours: 12,
  badge_type: "gold",
  // ... 20+ more fields
}
```

**Impact**:
- Must update Dart model to handle complex features object
- UI must display new feature categories
- Need to parse and display benefits array

---

### **4. NEW: `user_subscriptions.plan_id` Type Changed**

**Old**: `UUID` (references subscription_plans.id)
**New**: `TEXT` (matches new subscription_plans.id type)

**Migration Required**:
```sql
-- Old
plan_id UUID REFERENCES subscription_plans(id)

-- New
plan_id TEXT REFERENCES subscription_plans(id)
```

---

### **5. NEW: Points & Rewards System**

**New Table**: `point_redemptions`

```dart
class PointRedemption {
  final String id;
  final String userId;
  final int pointsSpent;
  final String rewardType;  // "discount", "free_event", "upgrade"
  final double rewardValue;
  final String description;
  final String status;  // "pending", "redeemed", "expired"
  final DateTime createdAt;
  final DateTime expiresAt;
}
```

**Integration Needed**:
- Display user's current points balance
- Show points history
- Implement redemption UI
- Award points after bookings/reviews
- Points multiplier based on tier (1x, 2x, 3x, 5x)

---

### **6. NEW: Referral System**

**New Table**: `referrals`

```dart
class Referral {
  final String id;
  final String referrerUserId;
  final String referredUserId;
  final String referralCode;
  final String subscriptionPlanId;
  final String tier;
  final String status;  // "pending", "completed", "expired"
  final int pointsAwarded;
  final bool bonusApplied;
  final DateTime createdAt;
  final DateTime? completedAt;
}
```

**Integration Needed**:
- Generate unique referral code for each user
- Display user's referral code
- Track referral signups
- Award bonus points when referral subscribes
- Show referral dashboard

---

## 🛠️ Required Updates

### **Priority 1: Critical Model Updates**

#### 1.1 Update Subscription Plan Model

**File**: `lib/features/subscription/model/subscription_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,  // TEXT (not UUID)
    required String name,  // "Free", "Gold", "Platinum", "Black"
    required String description,

    // NEW: Separate pricing
    @JsonKey(name: 'price_monthly') required double priceMonthly,
    @JsonKey(name: 'price_yearly') required double priceYearly,

    // NEW: Tier level for sorting
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

@freezed
class PlanFeatures with _$PlanFeatures {
  const factory PlanFeatures({
    required String tier,
    required String color,
    @JsonKey(name: 'points_multiplier') @Default(1) int pointsMultiplier,
    @JsonKey(name: 'discount_percentage') @Default(0) int discountPercentage,
    @JsonKey(name: 'early_booking_hours') @Default(0) int earlyBookingHours,
    @JsonKey(name: 'concierge_access') @Default(false) bool conciergeAccess,
    @JsonKey(name: 'concierge_hours') @Default('none') String conciergeHours,
    @JsonKey(name: 'vip_entry') @Default(false) bool vipEntry,
    @JsonKey(name: 'priority_support') @Default(false) bool prioritySupport,
    @JsonKey(name: 'free_reservations_per_month') @Default(0) int freeReservationsPerMonth,
    @JsonKey(name: 'vip_lounge_access') @Default(false) bool vipLoungeAccess,
    @JsonKey(name: 'points_per_booking') @Default(10) int pointsPerBooking,
    @JsonKey(name: 'points_per_review') @Default(5) int pointsPerReview,
    @JsonKey(name: 'referral_limit') @Default(5) int referralLimit,
    @JsonKey(name: 'support_response_hours') @Default(48) int supportResponseHours,
    @JsonKey(name: 'badge_type') @Default('basic') String badgeType,

    // Optional premium features
    @JsonKey(name: 'event_upgrades_per_month') int? eventUpgradesPerMonth,
    @JsonKey(name: 'concierge_requests_per_month') int? conciergeRequestsPerMonth,
    @JsonKey(name: 'all_access_vip_lounge') bool? allAccessVipLounge,
    @JsonKey(name: 'meet_greet_per_year') int? meetGreetPerYear,
    @JsonKey(name: 'backstage_access_per_year') int? backstageAccessPerYear,
    @JsonKey(name: 'free_parking') bool? freeParking,
    @JsonKey(name: 'personal_coordinator') bool? personalCoordinator,
    @JsonKey(name: 'quarterly_gifts') bool? quarterlyGifts,
    @JsonKey(name: 'animated_badge') bool? animatedBadge,

    // Black tier exclusive
    @JsonKey(name: 'invite_only') bool? inviteOnly,
    @JsonKey(name: 'exclusive_first_access') bool? exclusiveFirstAccess,
    @JsonKey(name: 'dedicated_concierge') bool? dedicatedConcierge,
    @JsonKey(name: 'private_lounge_access') bool? privateLoungeAccess,
    @JsonKey(name: 'valet_service') bool? valetService,
    @JsonKey(name: 'dedicated_account_manager') bool? dedicatedAccountManager,
    @JsonKey(name: 'luxury_gifts') bool? luxuryGifts,
    @JsonKey(name: 'private_events') bool? privateEvents,
    @JsonKey(name: 'celebrity_access') bool? celebrityAccess,
    @JsonKey(name: 'luxury_transport') bool? luxuryTransport,
    @JsonKey(name: 'international_perks') bool? internationalPerks,
  }) = _PlanFeatures;

  factory PlanFeatures.fromJson(Map<String, dynamic> json) =>
      _$PlanFeaturesFromJson(json);
}
```

#### 1.2 Update User Subscription Model

**File**: `lib/features/subscription/model/user_subscription_model.dart`

```dart
@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required String id,
    @JsonKey(name: 'user_id') required String userId,

    // CHANGED: plan_id is now TEXT, not UUID
    @JsonKey(name: 'plan_id') required String planId,

    required String tier,  // "Free", "Gold", "Platinum", "Black"

    // NEW: Billing cycle
    @JsonKey(name: 'billing_cycle') required String billingCycle,  // "monthly", "annual", "lifetime"

    required String status,  // "active", "cancelled", "expired"
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,

    // NEW: Payment details
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_reference') String? paymentReference,

    // NEW: Rewards
    @JsonKey(name: 'reward_points') @Default(0) int rewardPoints,

    // NEW: Referral code
    @JsonKey(name: 'referral_code') String? referralCode,

    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,

    // Nested subscription plan details
    @JsonKey(name: 'subscription_plans') SubscriptionPlan? subscriptionPlans,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionFromJson(json);
}
```

#### 1.3 Create Point Redemption Model

**File**: `lib/features/subscription/model/point_redemption_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_redemption_model.freezed.dart';
part 'point_redemption_model.g.dart';

@freezed
class PointRedemption with _$PointRedemption {
  const factory PointRedemption({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'points_spent') required int pointsSpent,
    @JsonKey(name: 'reward_type') required String rewardType,
    @JsonKey(name: 'reward_value') required double rewardValue,
    required String description,
    required String status,  // "pending", "redeemed", "expired", "cancelled"
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
  }) = _PointRedemption;

  factory PointRedemption.fromJson(Map<String, dynamic> json) =>
      _$PointRedemptionFromJson(json);
}
```

#### 1.4 Create Referral Model

**File**: `lib/features/subscription/model/referral_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral_model.freezed.dart';
part 'referral_model.g.dart';

@freezed
class Referral with _$Referral {
  const factory Referral({
    required String id,
    @JsonKey(name: 'referrer_user_id') required String referrerUserId,
    @JsonKey(name: 'referred_user_id') required String referredUserId,
    @JsonKey(name: 'referral_code') required String referralCode,
    @JsonKey(name: 'subscription_plan_id') String? subscriptionPlanId,
    String? tier,
    required String status,  // "pending", "completed", "expired"
    @JsonKey(name: 'points_awarded') @Default(0) int pointsAwarded,
    @JsonKey(name: 'bonus_applied') @Default(false) bool bonusApplied,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'completed_at') String? completedAt,
  }) = _Referral;

  factory Referral.fromJson(Map<String, dynamic> json) =>
      _$ReferralFromJson(json);
}
```

---

### **Priority 2: Service Layer Updates**

#### 2.1 Update Subscription Service

**File**: `lib/features/subscription/service/subscription_service.dart`

Add new methods:

```dart
class SubscriptionService {
  final supabase = Supabase.instance.client;

  // Fetch plans (updated for new schema)
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await supabase
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('tier_level', ascending: true);  // NEW: Sort by tier_level

      return response.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching subscription plans: $e');
      rethrow;
    }
  }

  // Get user subscription with plan details
  Future<UserSubscription?> getUserSubscription(String userId) async {
    try {
      final response = await supabase
          .from('user_subscriptions')
          .select('''
            *,
            subscription_plans (*)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;
      return UserSubscription.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user subscription: $e');
      return null;
    }
  }

  // NEW: Award points to user
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String action,
  }) async {
    try {
      await supabase.rpc('increment_reward_points', params: {
        'user_id_param': userId,
        'points_to_add': points,
      });
      debugPrint('Awarded $points points to user $userId for $action');
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }

  // NEW: Redeem points
  Future<PointRedemption> redeemPoints({
    required String userId,
    required int pointsToSpend,
    required String rewardType,
    required double rewardValue,
    required String description,
  }) async {
    try {
      // Check if user has enough points
      final subscription = await getUserSubscription(userId);
      if (subscription == null || subscription.rewardPoints < pointsToSpend) {
        throw Exception('Insufficient points');
      }

      // Create redemption record
      final redemptionResponse = await supabase
          .from('point_redemptions')
          .insert({
            'user_id': userId,
            'points_spent': pointsToSpend,
            'reward_type': rewardType,
            'reward_value': rewardValue,
            'description': description,
            'status': 'redeemed',
          })
          .select()
          .single();

      // Deduct points
      await supabase
          .from('user_subscriptions')
          .update({
            'reward_points': subscription.rewardPoints - pointsToSpend,
          })
          .eq('user_id', userId);

      return PointRedemption.fromJson(redemptionResponse);
    } catch (e) {
      debugPrint('Error redeeming points: $e');
      rethrow;
    }
  }

  // NEW: Get referral code for user
  Future<String?> getReferralCode(String userId) async {
    try {
      final response = await supabase
          .from('user_subscriptions')
          .select('referral_code')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['referral_code'];
    } catch (e) {
      debugPrint('Error fetching referral code: $e');
      return null;
    }
  }

  // NEW: Track referral
  Future<void> trackReferral({
    required String referralCode,
    required String newUserId,
  }) async {
    try {
      // Find referrer
      final referrerResponse = await supabase
          .from('user_subscriptions')
          .select('user_id, plan_id, tier')
          .eq('referral_code', referralCode)
          .maybeSingle();

      if (referrerResponse == null) {
        throw Exception('Invalid referral code');
      }

      // Create referral record
      await supabase.from('referrals').insert({
        'referrer_user_id': referrerResponse['user_id'],
        'referred_user_id': newUserId,
        'referral_code': referralCode,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Error tracking referral: $e');
      rethrow;
    }
  }

  // NEW: Calculate price with tier discount
  double calculateDiscountedPrice(double basePrice, PlanFeatures features) {
    final discountPercentage = features.discountPercentage;
    final discount = (basePrice * discountPercentage) / 100;
    return basePrice - discount;
  }
}
```

---

### **Priority 3: UI Updates**

#### 3.1 Update Subscription Plans Screen

**File**: `lib/features/subscription/screens/subscription_plans_screen.dart`

Key changes:
1. Display 4 tiers (Free, Gold, Platinum, Black)
2. Show monthly/annual toggle
3. Display `price_monthly` and `price_yearly`
4. Show `benefits` array as bullet points
5. Add tier badges with colors
6. Highlight current user tier

Example structure:
```dart
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final billingCycle = useState('monthly');  // or 'annual'

    return plansAsync.when(
      data: (plans) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final price = billingCycle.value == 'monthly'
                ? plan.priceMonthly
                : plan.priceYearly;

            return PlanCard(
              plan: plan,
              price: price,
              billingCycle: billingCycle.value,
              tierColor: Color(int.parse(plan.features.color.replaceFirst('#', '0xFF'))),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### 3.2 Create Points Dashboard Widget

**New File**: `lib/features/subscription/widgets/points_dashboard.dart`

```dart
class PointsDashboard extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(userSubscriptionProvider(userId));

    return subscription.when(
      data: (sub) {
        return Card(
          child: Column(
            children: [
              Text('${sub?.rewardPoints ?? 0} Points',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('${sub?.tier ?? "Free"} Member'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/points/redeem'),
                child: Text('Redeem Points'),
              ),
            ],
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### 3.3 Create Referral Dashboard

**New File**: `lib/features/subscription/screens/referral_dashboard_screen.dart`

```dart
class ReferralDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.id ?? '';
    final referralCode = ref.watch(referralCodeProvider(userId));
    final referrals = ref.watch(userReferralsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text('Referrals')),
      body: Column(
        children: [
          // Referral Code Card
          Card(
            child: Column(
              children: [
                Text('Your Referral Code'),
                Text(referralCode.value ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referralCode.value ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Referral Stats
          Row(
            children: [
              StatCard(
                label: 'Total Referrals',
                value: '${referrals.value?.length ?? 0}',
              ),
              StatCard(
                label: 'Successful',
                value: '${referrals.value?.where((r) => r.status == "completed").length ?? 0}',
              ),
              StatCard(
                label: 'Points Earned',
                value: '${referrals.value?.fold(0, (sum, r) => sum + r.pointsAwarded) ?? 0}',
              ),
            ],
          ),

          // Referral List
          Expanded(
            child: referrals.when(
              data: (refs) => ListView.builder(
                itemCount: refs.length,
                itemBuilder: (context, index) {
                  final ref = refs[index];
                  return ReferralListItem(referral: ref);
                },
              ),
              loading: () => CircularProgressIndicator(),
              error: (error, stack) => ErrorWidget(error),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Implementation Checklist

### Phase 1: Data Models (Week 1)
- [ ] Update `SubscriptionPlan` model with new fields
- [ ] Create `PlanFeatures` model
- [ ] Update `UserSubscription` model
- [ ] Create `PointRedemption` model
- [ ] Create `Referral` model
- [ ] Run `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Phase 2: Service Layer (Week 1-2)
- [ ] Update `SubscriptionService` with new methods
- [ ] Add points awarding logic
- [ ] Add points redemption logic
- [ ] Add referral tracking
- [ ] Create `PointsService`
- [ ] Create `ReferralService`

### Phase 3: Providers (Week 2)
- [ ] Update `subscriptionPlansProvider`
- [ ] Update `userSubscriptionProvider`
- [ ] Create `pointRedemptionsProvider`
- [ ] Create `userReferralsProvider`
- [ ] Create `referralCodeProvider`

### Phase 4: UI Updates (Week 2-3)
- [ ] Update subscription plans screen (4 tiers)
- [ ] Add billing cycle toggle (monthly/annual)
- [ ] Create points dashboard widget
- [ ] Create referral dashboard screen
- [ ] Update profile screen with tier badge
- [ ] Add points balance to app bar
- [ ] Create points redemption screen
- [ ] Update theme with tier colors

### Phase 5: Integration (Week 3-4)
- [ ] Award points after event bookings
- [ ] Award points after reviews
- [ ] Apply tier discounts to prices
- [ ] Implement early access for premium tiers
- [ ] Track referral signups
- [ ] Complete referrals on subscription
- [ ] Test Paystack integration

### Phase 6: Testing (Week 4)
- [ ] Test all 4 tier displays
- [ ] Test points awarding
- [ ] Test points redemption
- [ ] Test referral flow
- [ ] Test tier benefits (discounts, early access)
- [ ] Test subscription upgrade/downgrade
- [ ] Test payment flow

---

## 📋 SQL Migrations Needed

### Create increment_reward_points function
```sql
CREATE OR REPLACE FUNCTION increment_reward_points(
  user_id_param UUID,
  points_to_add INTEGER
)
RETURNS void AS $$
BEGIN
  UPDATE user_subscriptions
  SET reward_points = reward_points + points_to_add
  WHERE user_id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 🚨 Breaking Changes Summary

1. **`subscription_plans.id`**: Changed from UUID to TEXT
2. **`subscription_plans.price`**: Deprecated, use `price_monthly` and `price_yearly`
3. **Tier names**: Bronze/Silver replaced with Free/Gold
4. **New required fields**: `tier_level`, `features`, `benefits`
5. **`user_subscriptions.plan_id`**: Changed from UUID to TEXT

---

**Next Steps**:
1. Review this plan
2. Start with Phase 1 (Data Models)
3. Run build_runner after model updates
4. Proceed sequentially through phases

**Estimated Timeline**: 4 weeks for full implementation
