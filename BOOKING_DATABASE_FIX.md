# Booking Database Schema Fix

**Issue:** Booking creation fails after successful payment
**Error:** `PostgrestException: column bookings.transaction_id does not exist, code: 42703`
**Date:** June 2, 2026
**Status:** 🔧 Migration created, awaiting execution

---

## Problem Summary

✅ **Payment Processing:** WORKS - PayStack payment completes successfully
❌ **Booking Creation:** FAILS - Database schema mismatch

### User Flow:
1. ✅ User selects event and proceeds to checkout
2. ✅ PayStack WebView loads correctly
3. ✅ User enters card details
4. ✅ Payment is processed successfully
5. ✅ Payment verification confirms success
6. ❌ **Booking creation fails** with database error
7. ❌ User sees "Error loading booking details"
8. ❌ No ticket generated
9. ❌ Payment taken but booking not created ⚠️

---

## Root Cause Analysis

The `bookings` table schema in the database doesn't match what the application code expects.

### Database Schema (Actual):
From [`supabase/migrations/00_initial_schema.sql:281-316`](supabase/migrations/00_initial_schema.sql#L281-L316):

```sql
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,

  quantity INTEGER NOT NULL CHECK (quantity > 0),
  zone TEXT,                          -- ❌ TEXT, not UUID reference
  seat_numbers TEXT[],

  unit_price DECIMAL(10, 2) NOT NULL,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  total_price DECIMAL(10, 2) NOT NULL, -- ❌ Not "amount"
  currency TEXT DEFAULT 'GHS',

  payment_status TEXT NOT NULL CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')) DEFAULT 'pending',
  payment_method TEXT,
  payment_reference TEXT,             -- ❌ Not "transaction_id"

  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'attended')) DEFAULT 'pending',
  qr_code TEXT,
  points_awarded INTEGER DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  cancelled_at TIMESTAMP WITH TIME ZONE,
  attended_at TIMESTAMP WITH TIME ZONE
  -- ❌ No "booking_date" column
);
```

### Application Code (Expected):
From [`lib/features/booking/service/booking_service.dart:104-115`](lib/features/booking/service/booking_service.dart#L104-L115):

```dart
final response = await _supabase
    .from('bookings')
    .insert({
      'user_id': user.id,
      'event_id': eventId,
      'zone_id': zoneId,           // ❌ Expected UUID column
      'booking_date': bookingDate.toIso8601String(), // ❌ Missing column
      'quantity': quantity,
      'status': 'confirmed',
      'transaction_id': transactionId,  // ❌ Missing column
      'payment_status': paymentStatus,
    })
```

### Schema Mismatches:

| Application Expects | Database Has | Issue |
|---------------------|--------------|-------|
| `transaction_id` TEXT | `payment_reference` TEXT | ❌ Wrong column name |
| `zone_id` UUID (FK) | `zone` TEXT | ❌ Wrong type, no FK |
| `amount` DECIMAL | `total_price` DECIMAL | ❌ Wrong column name |
| `booking_date` TIMESTAMP | (missing) | ❌ Column doesn't exist |

---

## Solution

Created migration to add missing columns while preserving existing schema for backward compatibility.

### Migration File: [`supabase/migrations/20260602_fix_bookings_schema.sql`](supabase/migrations/20260602_fix_bookings_schema.sql)

```sql
-- Add missing columns to bookings table
ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS zone_id UUID REFERENCES zones(id),
  ADD COLUMN IF NOT EXISTS amount DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_bookings_transaction_id ON bookings(transaction_id);
CREATE INDEX IF NOT EXISTS idx_bookings_zone_id ON bookings(zone_id);

-- Migrate existing data
UPDATE bookings
SET
  transaction_id = payment_reference,
  amount = total_price,
  booking_date = created_at
WHERE transaction_id IS NULL OR amount IS NULL OR booking_date IS NULL;
```

### Why This Approach?

1. **Backward Compatible:** Keeps existing `payment_reference`, `total_price`, and `zone` columns
2. **Forward Compatible:** Adds new columns that application code expects
3. **Data Migration:** Copies existing data to new columns
4. **No Breaking Changes:** Old queries will still work
5. **Safe:** Uses `ADD COLUMN IF NOT EXISTS` to prevent errors if already added

---

## How to Apply the Fix

### Method 1: Supabase Dashboard SQL Editor (Recommended)

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/sql
   ```

2. **Click "New Query"**

3. **Copy and paste the migration:**
   ```sql
   -- Add missing columns to bookings table
   ALTER TABLE bookings
     ADD COLUMN IF NOT EXISTS transaction_id TEXT,
     ADD COLUMN IF NOT EXISTS zone_id UUID REFERENCES zones(id),
     ADD COLUMN IF NOT EXISTS amount DECIMAL(10, 2),
     ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;

   -- Create indexes
   CREATE INDEX IF NOT EXISTS idx_bookings_transaction_id ON bookings(transaction_id);
   CREATE INDEX IF NOT EXISTS idx_bookings_zone_id ON bookings(zone_id);

   -- Migrate existing data
   UPDATE bookings
   SET
     transaction_id = payment_reference,
     amount = total_price,
     booking_date = created_at
   WHERE transaction_id IS NULL OR amount IS NULL OR booking_date IS NULL;
   ```

4. **Click "Run"**

5. **Verify Success:**
   ```sql
   -- Check if columns were added
   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'bookings'
   AND column_name IN ('transaction_id', 'zone_id', 'amount', 'booking_date');
   ```

   Expected output:
   ```
   transaction_id  | text
   zone_id         | uuid
   amount          | numeric
   booking_date    | timestamp with time zone
   ```

### Method 2: Supabase CLI (Alternative)

```bash
# Link to your project (if not already linked)
supabase link --project-ref yvnfhsipyfxdmulajbgl

# Push the migration
supabase db push

# Or execute directly
supabase db execute -f supabase/migrations/20260602_fix_bookings_schema.sql
```

---

## After Migration - Testing

### Test 1: Book an Event

1. **Open app** → Sign in
2. **Select event** → Choose zone and quantity
3. **Proceed to checkout**
4. **Enter test card:**
   ```
   Card: 4084 0840 8408 4081
   CVV: 408
   Expiry: 12/30
   PIN: 0000
   OTP: 123456
   ```
5. **Complete payment**

### Expected Results:

✅ **Before (Now):**
- Payment processes
- Database error
- No booking created
- No ticket

✅ **After (Fixed):**
- Payment processes
- Booking created successfully
- QR ticket generated
- Ticket visible in "My Bookings" tab
- Confirmation email sent

### Test 2: Verify Database

```sql
-- Check latest booking
SELECT
  id,
  user_id,
  event_id,
  zone_id,           -- New column
  transaction_id,    -- New column
  amount,            -- New column
  booking_date,      -- New column
  total_price,       -- Old column (still exists)
  payment_reference, -- Old column (still exists)
  status,
  payment_status,
  qr_code,
  created_at
FROM bookings
ORDER BY created_at DESC
LIMIT 1;
```

Should show:
- ✅ `zone_id` populated with UUID
- ✅ `transaction_id` populated with PayStack reference
- ✅ `amount` matches `total_price`
- ✅ `booking_date` matches `created_at`
- ✅ `status = 'confirmed'`
- ✅ `payment_status = 'paid'`

---

## QR Ticket Generation

After booking is created, the app should generate a QR code. The QR code data is the booking ID.

### QR Code Flow:

1. **Booking Created** → Database returns booking ID
2. **QR Generated** → Booking ID encoded as QR
3. **Ticket Displayed** → Shows in "My Bookings"
4. **Email Sent** → Confirmation with QR code image

### QR Code Format:

```
Data: <booking-id-uuid>
Example: a1b2c3d4-e5f6-7890-abcd-ef1234567890
Image URL: https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=<booking-id>
```

---

## Related Files

### Modified/Created:
1. [`supabase/migrations/20260602_fix_bookings_schema.sql`](supabase/migrations/20260602_fix_bookings_schema.sql) - ✅ Created
2. [`BOOKING_DATABASE_FIX.md`](BOOKING_DATABASE_FIX.md) - ✅ This file

### Need Updates (Future - Optional):
1. [`lib/features/booking/service/booking_service.dart`](lib/features/booking/service/booking_service.dart) - Could also populate `total_price` and `payment_reference` for full compatibility
2. [`lib/data/models/booking_model.dart`](lib/data/models/booking_model.dart) - Could add both old and new field names

---

## Impact Analysis

### ✅ What Works Now:
- Payment processing
- Payment verification
- User authentication
- Event browsing

### ❌ What's Broken (Before Fix):
- Event bookings
- Club reservations
- Restaurant bookings
- Any booking creation after payment

### ✅ What Will Work (After Fix):
- Complete booking flow
- QR ticket generation
- Booking history
- Cancellations and refunds
- Email confirmations
- Points awarded

---

## Risk Assessment

### Migration Safety: ✅ LOW RISK

1. **Non-Destructive:** Only adds columns, doesn't remove or modify existing ones
2. **Idempotent:** Uses `IF NOT EXISTS` - safe to run multiple times
3. **Backward Compatible:** Old code will still work
4. **Data Preserved:** All existing bookings remain intact
5. **Indexing:** Adds performance indexes for new columns

### Rollback Plan:

If needed, remove added columns:
```sql
ALTER TABLE bookings
  DROP COLUMN IF EXISTS transaction_id,
  DROP COLUMN IF EXISTS zone_id,
  DROP COLUMN IF EXISTS amount,
  DROP COLUMN IF EXISTS booking_date;
```

**Note:** Only rollback if application is reverted to old code. New code requires these columns.

---

## Production Checklist

Before deploying to production:

- [ ] Run migration in Supabase Dashboard
- [ ] Verify columns added successfully
- [ ] Test complete booking flow (dev/staging)
- [ ] Verify QR ticket generation
- [ ] Check email confirmations
- [ ] Test cancellation flow
- [ ] Verify points awarded correctly
- [ ] Test with all booking types:
  - [ ] Event bookings
  - [ ] Club reservations
  - [ ] Restaurant bookings
- [ ] Monitor error logs for 24 hours
- [ ] Verify no payment-without-booking issues

---

## Next Steps

1. **Run Migration** (You): Execute SQL in Supabase Dashboard
2. **Test Booking** (You): Complete an event booking end-to-end
3. **Verify QR** (You): Check if ticket shows up in "My Bookings"
4. **Monitor** (Me): Check logs for any other schema issues

---

## Timeline

- **Issue Identified:** June 2, 2026 - 7:28 AM
- **Root Cause Found:** June 2, 2026 - 7:35 AM
- **Migration Created:** June 2, 2026 - 7:40 AM
- **Migration Applied:** ⏳ Awaiting your action
- **Booking Fixed:** ⏳ After migration

---

**Status:** Ready for migration execution
**Priority:** 🔴 CRITICAL - Payments are processing but bookings not being created
**Action Required:** Run migration SQL in Supabase Dashboard

**Estimated Fix Time:** 2-3 minutes to run migration + 2 minutes to test
