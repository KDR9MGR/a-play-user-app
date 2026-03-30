# Supabase Schema Update Summary

**Date:** March 29, 2026
**Schema Changes:** March 21, 2026 migrations

## Overview

This document summarizes the recent Supabase schema changes and the corresponding updates made to the A-Play Flutter application to maintain compatibility.

---

## Schema Changes (March 21, 2026)

### 1. Restaurant Bookings - Payment Fields

**Migration File:** `supabase/migrations/20260321_restaurant_payment_fields.sql`

**New Columns Added to `restaurant_bookings` table:**

| Column | Type | Constraint | Description |
|--------|------|------------|-------------|
| `transaction_id` | TEXT | - | PayStack transaction ID |
| `payment_status` | TEXT | CHECK IN ('pending', 'paid', 'failed', 'refunded') | Payment status |
| `payment_method` | TEXT | - | Payment method used (paystack, apple_pay, etc.) |
| `payment_reference` | TEXT | UNIQUE | Unique payment reference for idempotency |
| `amount_paid` | DECIMAL(10,2) | CHECK >= 0 | Amount paid for the booking |
| `currency` | TEXT | DEFAULT 'GHS' | Currency code |

**Indexes Created:**
- `idx_restaurant_bookings_payment_ref` on `payment_reference`
- `idx_restaurant_bookings_transaction_id` on `transaction_id`
- `idx_restaurant_bookings_payment_status` on `payment_status`

**Purpose:**
Enable payment tracking for restaurant table reservations through PayStack integration.

---

### 2. Concierge Request Tracking

**Migration File:** `supabase/migrations/20260321_concierge_request_tracking.sql`

**New Table Created: `concierge_request_tracking`**

| Column | Type | Constraint | Description |
|--------|------|------------|-------------|
| `id` | UUID | PRIMARY KEY | Auto-generated UUID |
| `user_id` | UUID | FK to profiles(id) ON DELETE CASCADE | User reference |
| `month` | INTEGER | CHECK 1-12 | Month number |
| `year` | INTEGER | CHECK >= 2020 | Year |
| `request_count` | INTEGER | DEFAULT 0, CHECK >= 0 | Number of requests made |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Update timestamp |

**Unique Constraint:** `(user_id, month, year)`

**Indexes:**
- `idx_concierge_tracking_user_date` on `(user_id, year DESC, month DESC)`

**Additional Change:**
- Added `user_id` column to existing `concierge_requests` table

**Purpose:**
Track monthly concierge request counts to enforce tier-based limits:
- **Free tier:** No concierge access
- **Gold tier:** 3 requests/month
- **Platinum/Black tier:** Unlimited requests

**Row Level Security:**
- Users can view their own tracking records
- Service role can manage all tracking records

---

## Application Updates

### 1. Data Models

#### **RestaurantBooking Model** (`lib/features/restaurant/model/restaurant_booking_model.dart`)

**Added Fields:**
```dart
@JsonKey(name: 'transaction_id') String? transactionId,
@JsonKey(name: 'payment_status') @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
@JsonKey(name: 'payment_method') String? paymentMethod,
@JsonKey(name: 'payment_reference') String? paymentReference,
@JsonKey(name: 'amount_paid') double? amountPaid,
@Default('GHS') String? currency,
```

**Added Enum:**
```dart
enum PaymentStatus {
  @JsonValue('pending') pending,
  @JsonValue('paid') paid,
  @JsonValue('failed') failed,
  @JsonValue('refunded') refunded,
}
```

#### **ConciergeRequestTracking Model** (NEW)

**Location:** `lib/features/concierge/model/concierge_request_tracking_model.dart`

**Model Structure:**
```dart
class ConciergeRequestTracking {
  required String id,
  @JsonKey(name: 'user_id') required String userId,
  required int month, // 1-12
  required int year,  // >= 2020
  @JsonKey(name: 'request_count') @Default(0) int requestCount,
  @JsonKey(name: 'created_at') required DateTime createdAt,
  @JsonKey(name: 'updated_at') required DateTime updatedAt,
}
```

**Helper Methods:**
- `hasReachedLimit(String tier)` - Check if user reached monthly limit
- `getRemainingRequests(String tier)` - Get remaining requests
- `getLimitForTier(String tier)` - Get tier limit (static)

---

### 2. Service Layer Updates

#### **RestaurantService** (`lib/features/restaurant/service/restaurant_service.dart`)

**New Methods:**

1. **`updateBookingPayment()`**
   - Updates payment information for a restaurant booking
   - Parameters: bookingId, transactionId, paymentStatus, paymentMethod, paymentReference, amountPaid, currency
   - Returns: Updated `RestaurantBooking`

2. **`getBookingByPaymentReference()`**
   - Retrieves booking by payment reference
   - Useful for payment callback verification
   - Returns: `RestaurantBooking?`

#### **ConciergeService** (`lib/features/concierge/services/concierge_service.dart`)

**Existing Implementation:**
The service already had tracking logic in place:
- `_trackMonthlyRequest()` - Creates/updates tracking records
- `_getMonthlyRequestCount()` - Gets current month's request count
- `canCreateRequest()` - Validates tier limits before creation

**New Methods Added:**

1. **`getMonthlyTracking(String userId)`**
   - Gets the tracking record for current month
   - Returns: `ConciergeRequestTracking?`

2. **`getTrackingHistory(String userId, {int? limit})`**
   - Gets historical tracking records
   - Returns: `List<ConciergeRequestTracking>`

---

## Tier-Based Concierge Limits

| Tier | Concierge Access | Monthly Limit | Notes |
|------|-----------------|---------------|-------|
| **Free** | ❌ No | 0 | Must upgrade to access |
| **Gold** | ✅ Yes (Business hours) | 3/month | Tracked via `concierge_request_tracking` |
| **Platinum** | ✅ Yes (24/7) | Unlimited | No tracking needed |
| **Black** | ✅ Yes (24/7) | Unlimited | No tracking needed |

---

## Code Generation

All Freezed models and JSON serialization code have been regenerated:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Results:**
- ✅ 334 outputs generated successfully
- ✅ No critical errors
- ⚠️ Some deprecation warnings (non-blocking)

---

## Testing Recommendations

### Restaurant Bookings

1. **Payment Flow:**
   - Create a table booking
   - Initiate PayStack payment
   - Verify `payment_status` updates correctly
   - Test payment reference uniqueness
   - Verify payment callbacks update booking status

2. **Edge Cases:**
   - Test failed payments
   - Test refund scenarios
   - Verify currency handling

### Concierge Requests

1. **Tier Limits:**
   - Test Gold tier: Verify 3-request limit enforcement
   - Test Platinum/Black: Verify unlimited access
   - Test Free tier: Verify access denial

2. **Tracking:**
   - Create requests and verify tracking updates
   - Test month/year rollover
   - Verify tracking history retrieval
   - Test concurrent request tracking

3. **Service Methods:**
   - Test `getMonthlyTracking()`
   - Test `getTrackingHistory()`
   - Verify RLS policies work correctly

---

## Database Migration Status

To apply these migrations to your Supabase project:

```bash
# From the project root
supabase db push
```

**Migrations Applied:**
- ✅ `20260321_restaurant_payment_fields.sql`
- ✅ `20260321_concierge_request_tracking.sql`

---

## Breaking Changes

### None

All changes are **backward compatible**:
- New fields in `restaurant_bookings` are **nullable** or have **defaults**
- New `concierge_request_tracking` table is optional (existing logic continues to work)
- Existing APIs remain unchanged

---

## Next Steps

1. **Testing:** Run thorough tests on payment flows and concierge limits
2. **UI Updates:** Update UI to display payment status and remaining concierge requests
3. **PayStack Integration:** Ensure payment callbacks properly update `payment_status`
4. **Monitoring:** Monitor `concierge_request_tracking` for accurate limit enforcement

---

## Related Files

### Models
- `lib/features/restaurant/model/restaurant_booking_model.dart`
- `lib/features/concierge/model/concierge_request_tracking_model.dart`

### Services
- `lib/features/restaurant/service/restaurant_service.dart`
- `lib/features/concierge/services/concierge_service.dart`

### Migrations
- `supabase/migrations/20260321_restaurant_payment_fields.sql`
- `supabase/migrations/20260321_concierge_request_tracking.sql`

---

**Updated by:** Claude Code
**Schema Analysis Date:** March 29, 2026
**Application Version:** 2.0.4+3
