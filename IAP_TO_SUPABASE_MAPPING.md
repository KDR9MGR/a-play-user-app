# IAP to Supabase Subscription Plan Mapping

**Purpose:** Map Apple IAP products to Supabase subscription plans
**Date:** June 6, 2026

---

## Complete Mapping Table

| IAP Product ID | IAP Name | IAP Price (USD) | Supabase Plan ID | Supabase Tier | Duration | Points Earned |
|----------------|----------|-----------------|------------------|---------------|----------|---------------|
| **7day** | 7 Day Fun | $3.99 | weekly_plan | Gold | 7 days | 50 |
| **1month** | A Month Fun | $12.99 | monthly_plan | Platinum | 30 days | 200 |
| **3SUB** | 3 Month's Premium | $36.99 | quarterly_plan | Platinum | 90 days | 650 |
| **365day** | Fun for a year | $146.99 | annual_plan | Black | 365 days | 3000 |

---

## Code Implementation

### In Flutter App (iap_verification_service.dart)

```dart
String _mapProductToPlanId(String productId) {
  switch (productId) {
    case '7day':
      return 'weekly_plan';
    case '1month':
      return 'monthly_plan';
    case '3SUB':
      return 'quarterly_plan';
    case '365day':
      return 'annual_plan';
    default:
      return 'unknown';
  }
}

String _mapProductToPlanType(String productId) {
  switch (productId) {
    case '7day':
      return 'weekly';
    case '1month':
      return 'monthly';
    case '3SUB':
      return 'quarterly';
    case '365day':
      return 'annual';
    default:
      return 'unknown';
  }
}

String _getTier(String productId) {
  switch (productId) {
    case '7day':
      return 'Gold';
    case '1month':
      return 'Platinum';
    case '3SUB':
      return 'Platinum';
    case '365day':
      return 'Black';
    default:
      return 'Gold';
  }
}

int _getTierPoints(String productId) {
  switch (productId) {
    case '7day':
      return 50;
    case '1month':
      return 200;
    case '3SUB':
      return 650;
    case '365day':
      return 3000;
    default:
      return 0;
  }
}

Duration _getDuration(String productId) {
  switch (productId) {
    case '7day':
      return const Duration(days: 7);
    case '1month':
      return const Duration(days: 30);
    case '3SUB':
      return const Duration(days: 90);
    case '365day':
      return const Duration(days: 365);
    default:
      return const Duration(days: 30);
  }
}

double _getAmount(String productId) {
  switch (productId) {
    case '7day':
      return 3.99;
    case '1month':
      return 12.99;
    case '3SUB':
      return 36.99;
    case '365day':
      return 146.99;
    default:
      return 0.0;
  }
}
```

---

## Database Schema

### Supabase `subscription_plans` Table

**Purpose:** For PayStack (Ghana GHS pricing) and reference

```sql
SELECT id, name, price, currency, duration_days
FROM subscription_plans
ORDER BY duration_days;
```

**Result:**
| id | name | price | currency | duration_days |
|----|------|-------|----------|---------------|
| weekly_plan | 1 Week Premium | 50.00 | GHS | 7 |
| monthly_plan | 1 Month Premium | 190.00 | GHS | 30 |
| quarterly_plan | 3 Months Premium | 550.00 | GHS | 90 |
| annual_plan | 1 Year Premium | 2200.00 | GHS | 365 |

**Note:** These GHS prices are for PayStack/Android only, NOT for iOS IAP!

---

### Supabase `user_subscriptions` Table

**Purpose:** Track active subscriptions

```sql
CREATE TABLE user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  plan_id TEXT NOT NULL, -- 'weekly_plan', 'monthly_plan', etc.
  plan_type TEXT NOT NULL, -- 'weekly', 'monthly', 'quarterly', 'annual'
  tier TEXT NOT NULL, -- 'Gold', 'Platinum', 'Black'
  status TEXT NOT NULL DEFAULT 'active',
  subscription_type TEXT NOT NULL DEFAULT 'premium',
  billing_cycle TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL, -- From Apple: 3.99, 12.99, 36.99, 146.99
  currency TEXT NOT NULL DEFAULT 'USD', -- 'USD' for IAP, 'GHS' for PayStack
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  payment_method TEXT, -- 'apple_iap' or 'paystack'
  tier_points_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Subscription Creation Flow

### iOS IAP Purchase Flow:

**Step 1:** User taps "Subscribe Now" on 1month plan
```dart
// App Store Connect returns:
ProductDetails {
  id: '1month',
  title: 'A Month Fun',
  price: '$12.99',
  rawPrice: 12.99,
  currency: 'USD'
}
```

**Step 2:** User confirms purchase with Face ID

**Step 3:** Purchase successful, app verifies:
```dart
await _verificationService.verifyAndActivateSubscription(
  productId: '1month',
  amount: 12.99, // From Apple StoreKit
);
```

**Step 4:** Backend creates subscription:
```sql
INSERT INTO user_subscriptions (
  user_id,
  plan_id,        -- 'monthly_plan' (mapped from '1month')
  plan_type,      -- 'monthly'
  tier,           -- 'Platinum'
  status,         -- 'active'
  subscription_type, -- 'premium'
  billing_cycle,  -- 'monthly'
  amount,         -- 12.99 (from Apple)
  currency,       -- 'USD' (IAP)
  start_date,     -- NOW()
  end_date,       -- NOW() + 30 days
  payment_method, -- 'apple_iap'
  tier_points_earned -- 200
) VALUES (...);
```

**Step 5:** Database trigger updates profile:
```sql
UPDATE profiles
SET
  is_subscribed = true,
  subscription_tier = 'Platinum',
  current_tier = 'Platinum',
  subscription_expires_at = NOW() + INTERVAL '30 days'
WHERE id = user_id;
```

---

## Tier Benefits

### Gold Tier (Weekly - $3.99)
- 10% discount on all bookings
- 24-hour early booking
- 1 free table reservation
- 50 tier points

### Platinum Tier (Monthly/Quarterly - $12.99/$36.99)
- 10-15% discount on all bookings
- 48-72 hour early booking
- 3+ free table reservations
- Priority support
- 200-650 tier points

### Black Tier (Annual - $146.99)
- 20% discount on all bookings
- 1-week early booking access
- VIP lounge access nationwide
- Personal event planner
- Exclusive backstage passes
- 3000 tier points

---

## Testing with Different Plans

### Test Weekly (7day - $3.99):
```sql
INSERT INTO user_subscriptions (
  user_id, plan_id, plan_type, tier, status, subscription_type,
  billing_cycle, amount, currency, start_date, end_date,
  payment_method, tier_points_earned
)
SELECT
  id, 'weekly_plan', 'weekly', 'Gold', 'active', 'premium',
  'weekly', 3.99, 'USD', NOW(), NOW() + INTERVAL '7 days',
  'apple_iap', 50
FROM profiles
WHERE email = 'test@example.com';
```

### Test Monthly (1month - $12.99):
```sql
INSERT INTO user_subscriptions (...)
SELECT
  id, 'monthly_plan', 'monthly', 'Platinum', 'active', 'premium',
  'monthly', 12.99, 'USD', NOW(), NOW() + INTERVAL '30 days',
  'apple_iap', 200
FROM profiles WHERE email = 'test@example.com';
```

### Test Quarterly (3SUB - $36.99):
```sql
INSERT INTO user_subscriptions (...)
SELECT
  id, 'quarterly_plan', 'quarterly', 'Platinum', 'active', 'premium',
  'quarterly', 36.99, 'USD', NOW(), NOW() + INTERVAL '90 days',
  'apple_iap', 650
FROM profiles WHERE email = 'test@example.com';
```

### Test Annual (365day - $146.99):
```sql
INSERT INTO user_subscriptions (...)
SELECT
  id, 'annual_plan', 'annual', 'Black', 'active', 'premium',
  'annual', 146.99, 'USD', NOW(), NOW() + INTERVAL '365 days',
  'apple_iap', 3000
FROM profiles WHERE email = 'test@example.com';
```

---

## Verification Queries

### Check User's Current Subscription:
```sql
SELECT
  us.plan_id,
  us.tier,
  us.amount,
  us.currency,
  us.start_date,
  us.end_date,
  us.status,
  p.is_subscribed,
  p.subscription_tier,
  p.current_tier
FROM user_subscriptions us
JOIN profiles p ON us.user_id = p.id
WHERE p.email = 'user@example.com'
  AND us.status = 'active'
ORDER BY us.created_at DESC
LIMIT 1;
```

### Expected Results:
- `plan_id` should match mapping (weekly_plan, monthly_plan, etc.)
- `tier` should match tier mapping (Gold, Platinum, Black)
- `amount` should be IAP price (3.99, 12.99, 36.99, 146.99)
- `currency` should be 'USD' for IAP
- `is_subscribed` should be true
- `subscription_tier` should match tier

---

## Price Comparison

### iOS IAP vs PayStack:

| Plan | IAP Price (USD) | PayStack Price (GHS) | Conversion* |
|------|-----------------|----------------------|-------------|
| Weekly | $3.99 | GHS 50.00 | ~GHS 12.53 |
| Monthly | $12.99 | GHS 190.00 | ~GHS 14.62 |
| Quarterly | $36.99 | GHS 550.00 | ~GHS 14.87 |
| Annual | $146.99 | GHS 2,200.00 | ~GHS 14.96 |

*Conversion rate varies, approximately 1 USD = 12.5-15 GHS

**Why Different?**
- IAP uses USD (Apple requirement)
- PayStack uses GHS (Ghana local currency)
- Different payment processor fees
- Different value propositions for platforms

---

## Summary

### Platform-Specific Pricing:

**iOS:**
- Uses Apple IAP product IDs (7day, 1month, 3SUB, 365day)
- Prices from App Store Connect ($3.99, $12.99, $36.99, $146.99)
- Currency: USD
- Payment: Apple In-App Purchase

**Android/PayStack:**
- Uses Supabase plan IDs (weekly_plan, monthly_plan, etc.)
- Prices from database (GHS 50, 190, 550, 2200)
- Currency: GHS
- Payment: PayStack

**Database:**
- Stores everything in `user_subscriptions`
- Maps IAP products to plan IDs
- Tracks tier, amount, currency, payment method
- Triggers update profile on creation/update

---

**Status:** ✅ Complete IAP to Supabase mapping documented
