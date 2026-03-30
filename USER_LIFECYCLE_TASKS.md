# A-Play User Lifecycle - Pending Tasks & Implementation Roadmap

> **Last Updated:** March 16, 2026
> **Purpose:** Comprehensive task list covering complete user journey from signup to all booking types

---

## 📋 Table of Contents

1. [User Registration & Onboarding](#1-user-registration--onboarding)
2. [Subscription System](#2-subscription-system)
3. [Event Booking Flow](#3-event-booking-flow)
4. [Restaurant Booking Flow](#4-restaurant-booking-flow)
5. [Club/Pub Booking Flow](#5-clubpub-booking-flow)
6. [Concierge Services](#6-concierge-services)
7. [Payment Infrastructure](#7-payment-infrastructure)
8. [Email System (Resend)](#8-email-system-resend)
9. [Testing & Quality Assurance](#9-testing--quality-assurance)

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Complete - Fully implemented and working |
| ⚠️ | Partial - Partially implemented, needs completion |
| ❌ | Missing - Not implemented yet |
| 🔴 | High Priority - Critical for user experience |
| 🟡 | Medium Priority - Important but not blocking |
| 🟢 | Low Priority - Nice to have enhancement |

---

## 1. User Registration & Onboarding

### Current Flow:
```
Open App → Sign Up/Sign In → Onboarding (5 screens) → Home Screen
```

### Tasks:

#### 1.1 Free Trial Presentation (3-Day Trial)
**Status:** ⚠️ Partial - Logic exists but not shown on signup
**Priority:** 🔴 High
**User Requirement:** Free users get 3 days trial access

**Current State:**
- ✅ Trial logic implemented in [lib/features/subscription/service/subscription_service.dart](lib/features/subscription/service/subscription_service.dart#L240-L289)
- ✅ Trial eligibility checking works
- ❌ Trial offer NOT shown after registration completion
- ❌ Trial offer only accessible via paywall screen

**Tasks:**
- [ ] Create `TrialOfferScreen` widget
  - Location: `lib/features/subscription/screens/trial_offer_screen.dart`
  - Design: Welcome message, trial benefits, "Start Free Trial" button
  - Show subscription tiers comparison

- [ ] Add route for trial offer
  - File: [lib/config/router.dart](lib/config/router.dart)
  - Route: `/trial-offer`
  - Should appear after onboarding completion

- [ ] Update onboarding completion handler
  - File: [lib/features/onboarding/controllers/onboarding_controller.dart](lib/features/onboarding/controllers/onboarding_controller.dart)
  - On completion: Check if trial eligible → Show trial offer → Home

- [ ] Add trial status tracking
  - Show days remaining in app header/profile
  - Alert user 24 hours before trial expires
  - Show upgrade prompt on trial expiration

**Files to Modify:**
- `lib/features/subscription/screens/trial_offer_screen.dart` (create)
- `lib/config/router.dart` (add route)
- `lib/features/onboarding/controllers/onboarding_controller.dart` (modify completion)
- `lib/features/navbar.dart` (add trial status indicator)

---

#### 1.2 Account Creation Improvements
**Status:** ✅ Complete
**Priority:** 🟢 Low

**Current State:**
- ✅ Email/password authentication working
- ✅ Google Sign-In integrated
- ✅ Apple Sign-In integrated
- ✅ Onboarding flow (profile photo, phone, DOB, city, interests)

**Optional Enhancements:**
- [ ] Add phone number verification (OTP)
- [ ] Add email verification enforcement
- [ ] Add profile completion progress indicator

---

## 2. Subscription System

### Current Flow (iOS):
```
User → Plans Screen → Select Plan → Apple IAP → Receipt Validation (Edge Function) → Subscription Active
```

### Current Flow (Android):
```
User → Plans Screen → Select Plan → PayStack Payment → Subscription Active
```

### Tasks:

#### 2.1 Remove Admin Panel Dependencies
**Status:** ✅ Complete - Already database-driven
**Priority:** 🟢 Low

**Current State:**
- ✅ No direct admin API calls found
- ✅ App reads from `subscription_plans` table
- ✅ Real-time sync via Supabase
- ✅ Admin panel manages plans separately

**Verification:**
- [x] Confirm no API endpoints to admin panel in codebase
- [x] Verify all subscription data from Supabase tables
- [x] Check real-time listeners for plan updates

**No Action Required** - System already fully decoupled.

---

#### 2.2 PayStack Server-Side Validation (Android Subscriptions)
**Status:** ⚠️ Partial - PayStack initialized via Edge Function but verification needs review
**Priority:** 🔴 High
**User Requirement:** Server validation for security

**Current State:**
- ✅ PayStack transaction initialization via Supabase Edge Function
  - [supabase/functions/paystack/index.ts](supabase/functions/paystack/index.ts)
  - Actions: `initialize`, `verify`
- ✅ Webhook handling: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
- ⚠️ Verification happens client-side after payment
- ⚠️ Subscription creation triggered by client

**Tasks:**
- [ ] Review PayStack Edge Function implementation
  - Ensure `verify` action validates with PayStack API
  - Confirm signature verification in webhook

- [ ] Move subscription creation to server-side
  - Current: Client calls `subscription_service.createSubscription()` after payment
  - Proposed: Webhook creates subscription automatically
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)

- [ ] Add subscription creation logic to webhook
  - Parse `metadata` from PayStack event
  - Extract `user_id`, `plan_id`, `billing_cycle`
  - Insert into `user_subscriptions` table
  - Record payment in `subscription_payments`
  - Trigger referral rewards if applicable

- [ ] Update client-side subscription service
  - File: [lib/features/subscription/service/subscription_service.dart](lib/features/subscription/service/subscription_service.dart)
  - Remove direct subscription creation
  - Poll for subscription status after payment
  - Or use Supabase real-time subscription to detect new subscription

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts` (add subscription creation)
- `lib/features/subscription/service/subscription_service.dart` (remove direct creation, add polling)

**Testing Requirements:**
- [ ] Test PayStack sandbox payment → webhook → subscription creation
- [ ] Verify referral rewards trigger correctly
- [ ] Test payment failure scenarios
- [ ] Verify duplicate prevention

---

#### 2.3 Apple IAP - Keep As-Is
**Status:** ✅ Complete
**Priority:** N/A

**Current State:**
- ✅ StoreKit integration complete
- ✅ Receipt validation via [supabase/functions/verify-apple-receipt/index.ts](supabase/functions/verify-apple-receipt/index.ts)
- ✅ Production + Sandbox environment handling
- ✅ Restore purchases working
- ✅ Auto-renewable subscriptions configured

**No Action Required** - System production-ready.

---

## 3. Event Booking Flow

### Current Flow:
```
Home → Browse Events → Event Details → Zone Selection → Checkout → PayStack Payment → Booking Confirmed → QR Ticket
```

### Tasks:

#### 3.1 Email Confirmation for Event Bookings
**Status:** ❌ Missing
**Priority:** 🔴 High
**User Requirement:** User receives ticket via email

**Current State:**
- ✅ Booking creation works: [lib/features/booking/service/booking_service.dart](lib/features/booking/service/booking_service.dart#L87-L125)
- ❌ No email sent after booking
- ✅ Resend Edge Function exists: [supabase/functions/send-email/index.ts](supabase/functions/send-email/index.ts)

**Tasks:**
- [ ] Create email template for event booking confirmation
  - Location: `supabase/functions/send-email/templates/event-booking.html`
  - Include: Event name, date, time, venue, zone, quantity, QR code, total price
  - Design: Professional HTML with A-Play branding

- [ ] Add email sending to booking service
  - File: [lib/features/booking/service/booking_service.dart](lib/features/booking/service/booking_service.dart#L87-L125)
  - After successful booking creation
  - Call `send-email` Edge Function
  - Pass booking details + user email

- [ ] Generate QR code on server-side for email
  - Option 1: Generate in Edge Function, embed as base64 image
  - Option 2: Generate QR code URL, embed link in email

- [ ] Add retry logic for failed email sends
  - Queue failed emails for retry
  - Log email failures to `email_logs` table (create if needed)

**Files to Modify:**
- `supabase/functions/send-email/templates/event-booking.html` (create)
- `lib/features/booking/service/booking_service.dart` (add email call)
- `supabase/functions/send-email/index.ts` (add template support)

**Data Required in Email:**
```dart
{
  "to": "user@email.com",
  "template": "event-booking",
  "data": {
    "userName": "John Doe",
    "eventName": "Concert at National Theatre",
    "eventDate": "March 20, 2026",
    "eventTime": "7:00 PM",
    "venue": "National Theatre of Ghana",
    "zone": "VIP Section",
    "quantity": 2,
    "totalPrice": "GH₵ 200.00",
    "qrCode": "base64_or_url",
    "bookingReference": "BK123456"
  }
}
```

---

#### 3.2 Move PayStack Payment to Edge Functions
**Status:** ⚠️ Partial - Already using Edge Functions
**Priority:** 🟡 Medium
**User Requirement:** Secure server-side payment handling

**Current State:**
- ✅ Event bookings use [lib/services/unified_payment_service.dart](lib/services/unified_payment_service.dart)
- ✅ Payment initialization via Edge Function `paystack`
- ✅ Returns authorization URL for WebView
- ⚠️ Verification happens client-side after payment

**Tasks:**
- [ ] Review current payment flow for events
  - Confirm `unified_payment_service` is used for event payments
  - Check metadata passed: `event_id`, `zone_id`, `user_id`, `quantity`

- [ ] Create webhook handler for event bookings
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
  - On `charge.success`, check metadata type
  - If `type: 'event_booking'`, create booking automatically
  - Call booking creation logic server-side

- [ ] Update booking service
  - File: [lib/features/booking/service/booking_service.dart](lib/features/booking/service/booking_service.dart)
  - After payment verification, poll for booking creation
  - Or listen to Supabase real-time for new booking

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts` (add event booking handler)
- `lib/features/booking/service/booking_service.dart` (update flow)

---

#### 3.3 QR Ticket Enhancements
**Status:** ⚠️ Partial - QR display works, validation unclear
**Priority:** 🟡 Medium

**Current State:**
- ✅ QR code displayed: [lib/features/booking/screens/my_tickets_screen.dart](lib/features/booking/screens/my_tickets_screen.dart)
- ✅ Uses `qr_flutter` package
- ⚠️ QR data structure not documented
- ❌ No validation endpoint found

**Tasks:**
- [ ] Define QR code data structure
  ```json
  {
    "booking_id": "uuid",
    "event_id": "uuid",
    "user_id": "uuid",
    "zone": "VIP",
    "quantity": 2,
    "timestamp": "2026-03-16T10:00:00Z",
    "signature": "hmac_sha256_signature"
  }
  ```

- [ ] Create QR validation Edge Function
  - Location: `supabase/functions/validate-ticket/index.ts`
  - Verify signature
  - Check booking exists and is valid
  - Mark as `attended` on scan
  - Prevent duplicate scans

- [ ] Add QR scanner for venue staff (optional)
  - Separate app or admin panel feature
  - Camera permission
  - Scan QR → Validate via Edge Function

**Files to Create:**
- `supabase/functions/validate-ticket/index.ts` (create)

---

## 4. Restaurant Booking Flow

### Current Flow:
```
Home → Browse Restaurants → Restaurant Details → Menu → Table Selection → Availability Check → Booking Created (Pending)
```

### Tasks:

#### 4.1 Complete Payment Integration
**Status:** ❌ Missing - Bookings created with status "pending", no payment
**Priority:** 🔴 High
**User Requirement:** All bookings use PayStack

**Current State:**
- ✅ Table booking creation: [lib/features/restaurant/service/restaurant_service.dart](lib/features/restaurant/service/restaurant_service.dart#L250-L307)
- ❌ Creates booking with `status: 'pending'`
- ❌ No payment integration
- ⚠️ Unclear if payment happens before or after restaurant confirmation

**Decision Needed:**
- **Option A:** Payment upfront → Booking confirmed → Restaurant notified
- **Option B:** Booking pending → Restaurant confirms → User pays → Booking confirmed

**Recommended: Option A (Payment Upfront)**

**Tasks:**
- [ ] Add payment step to restaurant booking flow
  - File: [lib/features/restaurant/service/restaurant_service.dart](lib/features/restaurant/service/restaurant_service.dart)
  - Before `createTableBooking()`, add payment initialization
  - Use `unified_payment_service.dart` for PayStack

- [ ] Define restaurant booking pricing
  - Add `booking_fee` or `deposit_amount` to restaurants table
  - Or calculate based on table price × duration

- [ ] Update `createTableBooking()` method
  - Add parameters: `transaction_id`, `payment_status`, `amount_paid`
  - Change initial status from `pending` to `confirmed` after payment

- [ ] Add webhook handler for restaurant bookings
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
  - On payment success, create booking server-side
  - Send confirmation email

**Files to Modify:**
- `lib/features/restaurant/service/restaurant_service.dart` (add payment)
- `lib/features/restaurant/screens/restaurant_booking_screen.dart` (add payment UI)
- `supabase/functions/paystack-webhook/index.ts` (add handler)

**Database Changes:**
- [ ] Add columns to `restaurant_bookings` table:
  ```sql
  ALTER TABLE restaurant_bookings
  ADD COLUMN transaction_id TEXT,
  ADD COLUMN payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  ADD COLUMN payment_method TEXT,
  ADD COLUMN payment_reference TEXT,
  ADD COLUMN amount_paid DECIMAL(10,2),
  ADD COLUMN currency TEXT DEFAULT 'GHS';
  ```

---

#### 4.2 Email Confirmation for Restaurant Bookings
**Status:** ❌ Missing
**Priority:** 🔴 High
**User Requirement:** User receives confirmation via email

**Current State:**
- ✅ Resend integration exists
- ❌ No email sent after restaurant booking

**Tasks:**
- [ ] Create email template for restaurant bookings
  - Location: `supabase/functions/send-email/templates/restaurant-booking.html`
  - Include: Restaurant name, date, time, table details, party size, total amount

- [ ] Add email sending to restaurant service
  - After successful booking + payment
  - Or in PayStack webhook for restaurant bookings

- [ ] Add booking confirmation details
  - Special requests reminder
  - Restaurant contact info
  - Cancellation policy

**Files to Create:**
- `supabase/functions/send-email/templates/restaurant-booking.html`

**Files to Modify:**
- `lib/features/restaurant/service/restaurant_service.dart` (add email call)
- OR `supabase/functions/paystack-webhook/index.ts` (send email from webhook)

---

#### 4.3 Table Selection Payment Flow
**Status:** ⚠️ Partial - Selection works, payment missing
**Priority:** 🔴 High

**Current State:**
- ✅ Table availability checking: [lib/features/restaurant/service/restaurant_service.dart](lib/features/restaurant/service/restaurant_service.dart#L202-L248)
- ✅ Capacity validation
- ✅ Time slot generation: Lines 380-433
- ❌ No payment UI after table selection

**Tasks:**
- [ ] Create payment screen for restaurant bookings
  - Location: `lib/features/restaurant/screens/restaurant_payment_screen.dart`
  - Show: Table details, time, price, total
  - PayStack payment button

- [ ] Add navigation from table selection to payment
  - After user selects table and time → Payment screen

- [ ] Show booking confirmation after payment
  - Success screen with booking details
  - Link to view in "My Bookings"

**Files to Create:**
- `lib/features/restaurant/screens/restaurant_payment_screen.dart`

**Files to Modify:**
- `lib/config/router.dart` (add route)
- `lib/features/restaurant/screens/table_selection_screen.dart` (add navigation)

---

## 5. Club/Pub Booking Flow

### Current Flow:
```
Home → Browse Clubs → Club Details → Table Selection → Time Selection → Payment → Booking Confirmed
```

### Tasks:

#### 5.1 Email Confirmation for Club Bookings
**Status:** ❌ Missing
**Priority:** 🔴 High
**User Requirement:** User receives confirmation via email

**Current State:**
- ✅ Club booking creation: [lib/features/club_booking/service/club_booking_service.dart](lib/features/club_booking/service/club_booking_service.dart#L52-L99)
- ✅ Payment integrated (transaction_id parameter)
- ❌ No email sent

**Tasks:**
- [ ] Create email template for club bookings
  - Location: `supabase/functions/send-email/templates/club-booking.html`
  - Include: Club name, date, time, table info, total price

- [ ] Add email sending to club booking service
  - File: [lib/features/club_booking/service/club_booking_service.dart](lib/features/club_booking/service/club_booking_service.dart)
  - After booking creation (line ~99)
  - Call `send-email` Edge Function

**Files to Create:**
- `supabase/functions/send-email/templates/club-booking.html`

**Files to Modify:**
- `lib/features/club_booking/service/club_booking_service.dart` (add email call)

---

#### 5.2 Ensure PayStack Server-Side Handling
**Status:** ⚠️ Partial - Payment happens, needs server-side validation
**Priority:** 🔴 High
**User Requirement:** Secure payments via Supabase Edge Functions

**Current State:**
- ✅ Club bookings accept `transaction_id`
- ⚠️ Booking created client-side after payment
- ⚠️ No server-side validation in webhook

**Tasks:**
- [ ] Review club payment flow
  - Check if using `unified_payment_service.dart`
  - Verify metadata includes: `club_id`, `table_id`, `user_id`, `date`, `time`

- [ ] Add webhook handler for club bookings
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
  - On `charge.success`, check for `type: 'club_booking'`
  - Create booking server-side
  - Send confirmation email

- [ ] Update club booking service
  - After payment verification, poll for booking
  - Or use real-time subscription

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts` (add club handler)
- `lib/features/club_booking/service/club_booking_service.dart` (update flow)

---

## 6. Concierge Services

### Current Flow:
```
Home → Concierge Tab → Browse Services → Request Service → Chat Room Created
```

### Tasks:

#### 6.1 Add Subscription Tier Enforcement
**Status:** ❌ Missing
**Priority:** 🔴 High
**User Requirement:** Concierge is subscription-only with tier-based limits

**Current State:**
- ✅ Concierge request creation: [lib/features/concierge/services/concierge_service.dart](lib/features/concierge/services/concierge_service.dart#L12-L46)
- ❌ No subscription validation
- ❌ No tier limit checking

**Subscription Tier Limits (from schema):**
- **Free:** No concierge access
- **Gold:** 3 requests/month
- **Platinum:** Unlimited
- **Black:** Unlimited + priority

**Tasks:**
- [ ] Add subscription check in `createRequest()`
  - File: [lib/features/concierge/services/concierge_service.dart](lib/features/concierge/services/concierge_service.dart#L12-L46)
  - Query user's active subscription
  - Verify tier has concierge access
  - Check monthly request count if tier has limits

- [ ] Create helper method `canCreateRequest()`
  ```dart
  Future<Map<String, dynamic>> canCreateRequest(String userId) async {
    // Get active subscription
    final subscription = await _getActiveSubscription(userId);

    if (subscription == null || subscription.tier == 'Free') {
      return {'allowed': false, 'reason': 'No active subscription'};
    }

    final tier = subscription.tier;
    final plan = await _getSubscriptionPlan(subscription.planId);
    final features = plan.features;

    if (features['concierge_access'] != true) {
      return {'allowed': false, 'reason': 'Tier does not include concierge'};
    }

    // Check limits for Gold tier
    if (tier == 'Gold') {
      final requestsThisMonth = await _getMonthlyRequestCount(userId);
      if (requestsThisMonth >= 3) {
        return {'allowed': false, 'reason': 'Monthly limit reached (3/3)'};
      }
    }

    return {'allowed': true};
  }
  ```

- [ ] Add UI validation before showing request dialog
  - File: Service detail page or request dialog
  - Show upgrade prompt if user not subscribed
  - Show limit warning if approaching limit

- [ ] Create request tracking table (if not exists)
  ```sql
  CREATE TABLE IF NOT EXISTS concierge_request_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    month INTEGER,
    year INTEGER,
    request_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, month, year)
  );
  ```

**Files to Modify:**
- `lib/features/concierge/services/concierge_service.dart` (add validation)
- `lib/features/concierge/widgets/service_request_dialog.dart` (add UI checks)
- `supabase/migrations/XX_concierge_limits.sql` (create tracking table)

---

#### 6.2 Request Limit Tracking
**Status:** ❌ Missing
**Priority:** 🟡 Medium

**Tasks:**
- [ ] Implement monthly counter
  - Increment on request creation
  - Reset on new month
  - Track in `concierge_request_tracking` table

- [ ] Add usage display in profile
  - Show: "2/3 requests used this month" (Gold tier)
  - Show: "Unlimited" (Platinum/Black)

- [ ] Add notification when limit reached
  - Alert user
  - Offer upgrade to Platinum

**Files to Create:**
- `lib/features/concierge/widgets/usage_indicator.dart`

---

## 7. Payment Infrastructure

### Tasks:

#### 7.1 Migrate All PayStack Operations to Supabase Edge Functions
**Status:** ⚠️ Partial - Initialization via Edge Function, some operations client-side
**Priority:** 🔴 High
**User Requirement:** Keep payments secure via Supabase Edge Functions

**Current State:**
- ✅ Payment initialization via Edge Function: `supabase/functions/paystack/`
- ✅ Webhook handling: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
- ⚠️ Some verification still client-side

**Tasks:**
- [ ] Audit all PayStack API calls
  - Search codebase for direct PayStack API usage
  - Ensure all go through Edge Functions

- [ ] Consolidate payment flows
  - Subscriptions (Android)
  - Event bookings
  - Restaurant bookings
  - Club bookings
  - All should use same Edge Function flow

- [ ] Create unified webhook handler
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
  - Route based on metadata.type:
    - `subscription` → Create subscription
    - `event_booking` → Create event booking
    - `restaurant_booking` → Create restaurant booking
    - `club_booking` → Create club booking

- [ ] Add idempotency protection
  - Prevent duplicate bookings on webhook retries
  - Use `payment_reference` as idempotency key
  - Check if record exists before creating

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts` (expand handlers)
- All booking services (update to poll after payment)

---

#### 7.2 Implement Server-Side Validation for All Transactions
**Status:** ⚠️ Partial - Apple IAP validated, PayStack needs review
**Priority:** 🔴 High

**Tasks:**
- [ ] Ensure PayStack webhook validates signatures
  - File: [supabase/functions/paystack-webhook/index.ts](supabase/functions/paystack-webhook/index.ts)
  - Verify HMAC signature on every webhook call
  - Reject invalid signatures

- [ ] Add transaction verification before booking creation
  - Query PayStack API to verify transaction is successful
  - Don't trust webhook alone

- [ ] Add fraud detection
  - Check for unusual patterns (multiple failed attempts, etc.)
  - Rate limiting on payment attempts

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts`

---

#### 7.3 Webhook Improvements
**Status:** ⚠️ Partial
**Priority:** 🟡 Medium

**Tasks:**
- [ ] Add comprehensive logging
  - Log all webhook events
  - Create `webhook_logs` table
  - Track: timestamp, event_type, reference, status, error_message

- [ ] Add error handling
  - Retry failed operations
  - Alert admins on critical failures

- [ ] Add webhook testing endpoint
  - Create test webhook for development
  - Simulate PayStack events

**Files to Create:**
- `supabase/migrations/XX_webhook_logs.sql`

**Files to Modify:**
- `supabase/functions/paystack-webhook/index.ts`

---

## 8. Email System (Resend)

### Current State:
- ✅ Resend integration: [supabase/functions/send-email/index.ts](supabase/functions/send-email/index.ts)
- ✅ Subscription emails working
- ❌ Booking confirmation emails missing

### Tasks:

#### 8.1 Complete Booking Confirmation Emails
**Status:** ❌ Missing
**Priority:** 🔴 High
**User Requirement:** All bookings send confirmation via email

**Tasks:**
- [ ] Create email templates (HTML)
  - `event-booking.html` - Event ticket with QR code
  - `restaurant-booking.html` - Restaurant reservation confirmation
  - `club-booking.html` - Club table booking confirmation
  - Location: `supabase/functions/send-email/templates/`

- [ ] Design templates with A-Play branding
  - Use Ghana color scheme (red, gold, green)
  - Professional layout
  - Mobile-responsive
  - Include logo and social links

- [ ] Add dynamic data rendering
  - Template variable replacement
  - Example: `{{userName}}`, `{{eventName}}`, `{{bookingDate}}`

- [ ] Test email delivery
  - Test all templates
  - Check spam score
  - Verify rendering on multiple email clients

**Template Variables:**

**Event Booking Email:**
```html
userName, eventName, eventDate, eventTime, venueName, venueAddress,
zoneName, quantity, unitPrice, totalPrice, bookingReference, qrCodeImage
```

**Restaurant Booking Email:**
```html
userName, restaurantName, bookingDate, bookingTime, tableName, partySize,
specialRequests, restaurantPhone, restaurantAddress, bookingReference
```

**Club Booking Email:**
```html
userName, clubName, bookingDate, startTime, endTime, tableName,
tableLocation, totalPrice, clubPhone, clubAddress, bookingReference
```

**Files to Create:**
- `supabase/functions/send-email/templates/event-booking.html`
- `supabase/functions/send-email/templates/restaurant-booking.html`
- `supabase/functions/send-email/templates/club-booking.html`

**Files to Modify:**
- `supabase/functions/send-email/index.ts` (add template loading and rendering)

---

#### 8.2 Email Template System
**Status:** ⚠️ Partial - Basic inline HTML, needs proper templating
**Priority:** 🟡 Medium

**Tasks:**
- [ ] Add template engine
  - Use Handlebars or similar
  - Support variable substitution
  - Support conditionals and loops

- [ ] Create base email layout
  - Header with logo
  - Footer with social links, contact info
  - Consistent styling

- [ ] Add email preview endpoint (dev only)
  - Test templates before sending
  - Preview with sample data

**Files to Modify:**
- `supabase/functions/send-email/index.ts` (add templating)

---

#### 8.3 Email Delivery Tracking
**Status:** ❌ Missing
**Priority:** 🟢 Low

**Tasks:**
- [ ] Create email logs table
  ```sql
  CREATE TABLE email_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    recipient_email TEXT,
    email_type TEXT, -- 'event_booking', 'subscription_confirmation', etc.
    subject TEXT,
    status TEXT CHECK (status IN ('sent', 'failed', 'bounced')),
    error_message TEXT,
    resend_id TEXT,
    sent_at TIMESTAMP DEFAULT NOW()
  );
  ```

- [ ] Log all email sends
  - Track delivery status
  - Record Resend message ID

- [ ] Add retry for failed emails
  - Queue system for retries
  - Max 3 retry attempts

**Files to Create:**
- `supabase/migrations/XX_email_logs.sql`

**Files to Modify:**
- `supabase/functions/send-email/index.ts` (add logging)

---

## 9. Testing & Quality Assurance

### Tasks:

#### 9.1 End-to-End User Flow Testing
**Status:** ❌ Not Started
**Priority:** 🔴 High

**Test Scenarios:**

**1. New User Registration → Trial → Event Booking**
- [ ] Sign up with email
- [ ] Complete onboarding
- [ ] See trial offer
- [ ] Start 3-day trial
- [ ] Browse events
- [ ] Select event and zone
- [ ] Complete PayStack payment
- [ ] Receive booking confirmation
- [ ] Check email for ticket
- [ ] View QR ticket in app

**2. Restaurant Booking Flow**
- [ ] Browse restaurants
- [ ] View menu
- [ ] Select table and time
- [ ] Complete payment
- [ ] Receive email confirmation
- [ ] View booking in "My Bookings"

**3. Subscription Purchase (iOS)**
- [ ] View subscription plans
- [ ] Select Platinum plan
- [ ] Complete Apple IAP payment
- [ ] Receipt validated
- [ ] Subscription active
- [ ] Access concierge features
- [ ] Receive email confirmation

**4. Subscription Purchase (Android)**
- [ ] View subscription plans
- [ ] Select Gold plan
- [ ] Complete PayStack payment
- [ ] Webhook creates subscription
- [ ] Subscription active
- [ ] Access tier benefits
- [ ] Receive email confirmation

**5. Concierge Request (Subscriber Only)**
- [ ] Verify active subscription
- [ ] Access concierge tab
- [ ] Create service request
- [ ] Chat room created
- [ ] Check monthly limit (Gold tier)

---

#### 9.2 Payment Flow Testing
**Status:** ❌ Not Started
**Priority:** 🔴 High

**Test Cases:**
- [ ] PayStack sandbox payment success
- [ ] PayStack sandbox payment failure
- [ ] PayStack webhook signature validation
- [ ] Duplicate payment prevention
- [ ] Apple IAP sandbox purchase
- [ ] Apple IAP production purchase
- [ ] Receipt validation (valid receipt)
- [ ] Receipt validation (invalid receipt)
- [ ] Restore purchases flow
- [ ] Refund handling

---

#### 9.3 Email Delivery Testing
**Status:** ❌ Not Started
**Priority:** 🟡 Medium

**Test Cases:**
- [ ] Event booking email sent
- [ ] Restaurant booking email sent
- [ ] Club booking email sent
- [ ] Subscription confirmation email sent
- [ ] Email template rendering (multiple clients)
- [ ] Email delivery to spam folder check
- [ ] Resend API error handling

---

## 10. Summary - Implementation Priority

### Phase 1: Critical (Complete First) 🔴

1. **Trial Offer After Registration**
   - Create trial offer screen
   - Show after onboarding completion
   - Estimated: 4-6 hours

2. **Event Booking Email Confirmations**
   - Create template
   - Integrate email sending
   - Estimated: 3-4 hours

3. **Restaurant Payment Integration**
   - Add PayStack payment flow
   - Update database schema
   - Estimated: 6-8 hours

4. **Restaurant Booking Email**
   - Create template
   - Send after booking creation
   - Estimated: 2-3 hours

5. **Club Booking Email**
   - Create template
   - Integrate sending
   - Estimated: 2-3 hours

6. **Concierge Tier Enforcement**
   - Add subscription validation
   - Implement request limits
   - Estimated: 4-5 hours

7. **PayStack Webhook Consolidation**
   - Expand webhook to handle all booking types
   - Add server-side booking creation
   - Estimated: 8-10 hours

**Total Phase 1: ~30-40 hours**

---

### Phase 2: Important (Next Priority) 🟡

1. **PayStack Server-Side Validation Review**
   - Audit current implementation
   - Ensure signature verification
   - Estimated: 3-4 hours

2. **QR Ticket Enhancement**
   - Define data structure
   - Create validation endpoint
   - Estimated: 4-5 hours

3. **Email Template System**
   - Professional HTML templates
   - Template engine integration
   - Estimated: 6-8 hours

4. **Webhook Logging**
   - Create logs table
   - Add comprehensive logging
   - Estimated: 2-3 hours

**Total Phase 2: ~15-20 hours**

---

### Phase 3: Enhancements (Nice to Have) 🟢

1. **Trial Status Indicator**
   - Days remaining display
   - Expiration alerts
   - Estimated: 2-3 hours

2. **Email Delivery Tracking**
   - Logs table
   - Retry mechanism
   - Estimated: 3-4 hours

3. **QR Code Scanner**
   - Scanner UI
   - Validation integration
   - Estimated: 4-6 hours

4. **Phone/Email Verification**
   - OTP verification
   - Email confirmation enforcement
   - Estimated: 4-5 hours

**Total Phase 3: ~13-18 hours**

---

## 11. Technical Debt & Code Cleanup

### Tasks:

- [ ] Remove unused BLoC dependencies from pubspec.yaml
  - `flutter_bloc: ^9.1.1` (no longer used)
  - `equatable: ^2.0.7` (BLoC dependency)

- [ ] Update CLAUDE.md documentation
  - Reflect completed Riverpod migration
  - Update payment flow architecture
  - Document email system

- [ ] Audit and remove admin panel API calls (if any found)
  - Already verified none exist

- [ ] Standardize folder structure
  - Some features use `screens/`, others use `view/`
  - Normalize to `view/` as per architecture

---

## 12. Environment & Configuration

### Tasks:

- [ ] Update PayStack public key
  - File: [lib/core/config/env.dart](lib/core/config/env.dart#L3)
  - Replace `pk_test_your_test_key` with actual production key

- [ ] Verify Supabase Edge Function environment variables
  - `RESEND_API_KEY` - Email service
  - `PAYSTACK_SECRET_KEY` - Webhook validation
  - `SUPABASE_SERVICE_ROLE_KEY` - Database operations

- [ ] Configure production vs staging environments
  - PayStack live vs test keys
  - Apple IAP production vs sandbox
  - Email sender address

---

## 13. Next Steps

1. **Review this document** with team/stakeholders
2. **Prioritize tasks** based on business needs
3. **Estimate timeline** for each phase
4. **Assign tasks** to developers
5. **Set up testing environment** (PayStack sandbox, Resend test account)
6. **Begin Phase 1 implementation**
7. **Test each feature** before moving to next
8. **Deploy to staging** after Phase 1 completion
9. **User acceptance testing**
10. **Production deployment**

---

## 14. Questions & Decisions Needed

- [ ] **Restaurant Booking Payment Flow:** Payment before or after restaurant confirmation?
  - **Recommended:** Payment upfront (Option A)
  - **User to confirm:** Final decision

- [ ] **QR Code Data Structure:** What information should be encoded?
  - **Recommended:** Booking ID + signature for security
  - **User to confirm:** Additional fields needed?

- [ ] **Email Sender Address:** What should be the "From" email?
  - Current: `onboarding@resend.dev` (default)
  - **Recommended:** `noreply@aplay.gh` or `bookings@aplay.gh`
  - **User to provide:** Domain for email sending

- [ ] **Concierge Limits:** Should limits be strict or soft?
  - **Strict:** Block at limit
  - **Soft:** Allow with premium prompt
  - **User to decide**

---

**Document Version:** 1.0
**Created:** March 16, 2026
**Author:** Claude Code Analysis Agent
**Status:** Ready for Review & Implementation
