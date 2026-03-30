# 🔄 Supabase Sync Guide

**Date:** March 21, 2026
**Purpose:** Deploy all pending migrations and edge functions to Supabase production

---

## 📋 Pre-Deployment Checklist

Before syncing, ensure you have:

- [x] Supabase CLI installed (`npm install -g supabase`)
- [ ] Supabase project linked (`supabase link --project-ref YOUR_PROJECT_REF`)
- [ ] Resend API key for email service
- [ ] PayStack secret key (NOT public key)
- [ ] Terminal/command prompt access

---

## 🗄️ Step 1: Deploy Database Migrations

### Migrations to Deploy

Two new migration files created:

1. **`supabase/migrations/20260321_concierge_request_tracking.sql`**
   - Creates `concierge_request_tracking` table
   - Tracks monthly concierge requests per user
   - Enables Gold tier limit enforcement (3 requests/month)

2. **`supabase/migrations/20260321_restaurant_payment_fields.sql`**
   - Adds payment tracking columns to `restaurant_bookings` table
   - Includes: `transaction_id`, `payment_status`, `payment_reference`, `amount_paid`, `currency`
   - Creates performance indexes for payment queries

### Deployment Command

```bash
# Navigate to project directory
cd /Users/abdulrazak/Documents/a-play-user-app-main

# Deploy migrations
supabase db push
```

### Expected Output

```
✓ Applying migration 20260321_concierge_request_tracking.sql...
✓ Applying migration 20260321_restaurant_payment_fields.sql...
✓ All migrations applied successfully
```

### Verification

```sql
-- Verify concierge_request_tracking table exists
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'concierge_request_tracking';

-- Verify restaurant_bookings has payment columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'restaurant_bookings'
AND column_name IN ('transaction_id', 'payment_status', 'payment_reference', 'amount_paid', 'currency');

-- Verify indexes created
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename IN ('restaurant_bookings', 'concierge_request_tracking');
```

---

## ⚡ Step 2: Deploy Edge Functions

### Functions to Deploy

#### A. PayStack Webhook Handler

**File:** `supabase/functions/paystack-webhook/index.ts`

**Changes:**
- Consolidated webhook handling for all payment types
- Added routing based on `metadata.type`
- Idempotency protection via `payment_reference`
- Support for: subscriptions, event bookings, restaurant bookings, club bookings

**Deploy Command:**
```bash
supabase functions deploy paystack-webhook
```

**Expected Output:**
```
Deploying function paystack-webhook...
✓ Function deployed successfully
Function URL: https://YOUR_PROJECT_REF.supabase.co/functions/v1/paystack-webhook
```

#### B. Email Service

**File:** `supabase/functions/send-email/index.ts`

**Changes:**
- Added template loading from `templates/` directory
- Variable replacement function
- Support for 3 templates: event-booking, restaurant-booking, club-booking

**Deploy Command:**
```bash
supabase functions deploy send-email
```

**Expected Output:**
```
Deploying function send-email...
Bundling templates...
✓ Function deployed successfully
Function URL: https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-email
```

---

## 🔐 Step 3: Configure Environment Variables

### Required Secrets

Set these secrets for Edge Functions:

```bash
# Resend API key (for email service)
supabase secrets set RESEND_API_KEY=re_your_actual_api_key

# PayStack secret key (NOT public key)
supabase secrets set PAYSTACK_SECRET_KEY=sk_live_your_actual_secret_key
```

### Verify Secrets

```bash
supabase secrets list
```

**Expected Output:**
```
RESEND_API_KEY          re_***
PAYSTACK_SECRET_KEY     sk_***
SUPABASE_URL            https://***
SUPABASE_SERVICE_ROLE_KEY  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.***
```

---

## 🧪 Step 4: Test Deployment

### Test PayStack Webhook

1. **Update PayStack webhook URL** in PayStack dashboard:
   ```
   https://YOUR_PROJECT_REF.supabase.co/functions/v1/paystack-webhook
   ```

2. **Make test payment** using PayStack sandbox/live mode

3. **Check webhook logs:**
   ```bash
   supabase functions logs paystack-webhook --tail
   ```

4. **Expected log output:**
   ```
   PayStack webhook event: charge.success
   Processing payment: { reference: 'REST_abc123', type: 'restaurant_booking', amount: 60 }
   Restaurant booking created: { userId: 'xxx', restaurantId: 'yyy', tableId: 'zzz' }
   ```

### Test Email Service

**Manual test:**
```bash
curl -X POST \
  'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "test@example.com",
    "subject": "Test Email",
    "template": "event-booking",
    "data": {
      "userName": "John Doe",
      "eventName": "Test Event",
      "eventDate": "Mar 25, 2026",
      "eventTime": "7:00 PM",
      "venueName": "Test Venue",
      "venueAddress": "123 Test St",
      "zoneName": "VIP",
      "quantity": 2,
      "unitPrice": "100.00",
      "totalPrice": "200.00",
      "bookingReference": "TEST123",
      "qrCodeImage": "https://via.placeholder.com/200"
    }
  }'
```

**Check email logs:**
```bash
supabase functions logs send-email --tail
```

### Test Restaurant Booking Flow

1. **In Flutter app:** Navigate to restaurant booking
2. **Select:** Date, table, time, party size
3. **Proceed to payment:** Should see deposit amount calculated
4. **Complete PayStack payment**
5. **Verify:**
   - Webhook receives payment
   - Booking created in `restaurant_bookings` table
   - Email sent to user

**Database verification:**
```sql
SELECT
  id, user_id, restaurant_id, table_id,
  booking_date, party_size, status,
  payment_status, payment_reference, amount_paid
FROM restaurant_bookings
ORDER BY created_at DESC
LIMIT 5;
```

### Test Concierge Limits

**For Gold tier user:**

```sql
-- Check user's tier
SELECT tier, status FROM user_subscriptions WHERE user_id = 'YOUR_USER_ID';

-- Make 3 concierge requests through the app

-- Verify tracking
SELECT user_id, month, year, request_count
FROM concierge_request_tracking
WHERE user_id = 'YOUR_USER_ID';

-- Try 4th request - should be blocked with upgrade message
```

---

## 🔍 Step 5: Monitor Production

### View Live Logs

**PayStack webhook:**
```bash
supabase functions logs paystack-webhook --tail
```

**Email service:**
```bash
supabase functions logs send-email --tail
```

**View errors only:**
```bash
supabase functions logs paystack-webhook --level error
```

### Database Monitoring Queries

**Recent restaurant bookings:**
```sql
SELECT
  rb.id,
  rb.booking_date,
  rb.status,
  rb.payment_status,
  r.name as restaurant_name,
  p.full_name as user_name,
  rb.created_at
FROM restaurant_bookings rb
JOIN restaurants r ON r.id = rb.restaurant_id
JOIN profiles p ON p.id = rb.user_id
WHERE rb.created_at > NOW() - INTERVAL '24 hours'
ORDER BY rb.created_at DESC;
```

**Payment failures:**
```sql
SELECT
  id, payment_reference, payment_status, created_at
FROM restaurant_bookings
WHERE payment_status = 'failed'
ORDER BY created_at DESC
LIMIT 10;
```

**Concierge usage by tier:**
```sql
SELECT
  us.tier,
  COUNT(crt.id) as total_requests,
  AVG(crt.request_count) as avg_requests_per_user
FROM concierge_request_tracking crt
JOIN user_subscriptions us ON us.user_id = crt.user_id
WHERE crt.year = 2026 AND crt.month = 3
GROUP BY us.tier
ORDER BY total_requests DESC;
```

---

## ⚠️ Troubleshooting

### Issue: Migration fails with "relation already exists"

**Solution:** Check if tables were manually created
```sql
-- Check existing tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- If table exists but migration hasn't run, mark migration as applied:
-- (Contact Supabase support or manually handle)
```

### Issue: Webhook not receiving events

**Checklist:**
- [ ] Webhook URL configured in PayStack dashboard
- [ ] PayStack secret key is correct (starts with `sk_`)
- [ ] Function deployed successfully
- [ ] Check function logs for errors

**Debug:**
```bash
# View recent webhook attempts
supabase functions logs paystack-webhook --level all

# Test webhook signature manually
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/paystack-webhook' \
  -H 'x-paystack-signature: test' \
  -d '{"event":"charge.success","data":{}}'
```

### Issue: Emails not sending

**Checklist:**
- [ ] Resend API key is valid (starts with `re_`)
- [ ] Sender domain verified in Resend dashboard
- [ ] Template files deployed with function
- [ ] Check email logs for errors

**Debug:**
```bash
# View email function logs
supabase functions logs send-email --level error

# Check if templates were deployed
# (Templates should be in supabase/functions/send-email/templates/)
```

### Issue: Concierge limit not enforced

**Checklist:**
- [ ] Migration applied successfully
- [ ] User has active Gold subscription
- [ ] `canCreateRequest()` method called before creating request

**Debug:**
```sql
-- Verify subscription features
SELECT
  sp.tier,
  sp.features
FROM subscription_plans sp
WHERE sp.tier = 'Gold';

-- Should show: {"concierge_access": true, ...}

-- Check tracking table exists
SELECT * FROM concierge_request_tracking LIMIT 1;
```

---

## 📊 Success Metrics

After successful deployment, you should see:

✅ **Database:**
- 2 new tables created (`concierge_request_tracking`)
- `restaurant_bookings` has 6 new columns
- 4 new indexes created

✅ **Edge Functions:**
- PayStack webhook handling all booking types
- Email service sending confirmations
- Function logs showing successful processing

✅ **User Experience:**
- Restaurant bookings require payment
- Email confirmations received
- Concierge limits enforced for Gold tier
- Trial offer shown after signup

✅ **Monitoring:**
- Real-time logs accessible
- Database queries returning expected data
- No errors in function logs

---

## 🎯 Post-Deployment Tasks

1. **Test complete user flows:**
   - New user signup → trial offer → event booking
   - Restaurant booking with payment
   - Concierge request with tier checking

2. **Monitor for 24 hours:**
   - Check webhook logs hourly
   - Verify email delivery rates
   - Watch for any payment failures

3. **Update PayStack settings:**
   - Switch from test keys to live keys when ready
   - Update webhook URL if needed

4. **Document any issues:**
   - Note any errors in production
   - Create tickets for bugs
   - Update troubleshooting guide

---

## 📞 Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **Supabase Support:** https://supabase.com/dashboard/support
- **PayStack Docs:** https://paystack.com/docs
- **Resend Docs:** https://resend.com/docs

---

## ✅ Deployment Checklist

Before going live:

- [ ] Link Supabase project (`supabase link`)
- [ ] Deploy database migrations (`supabase db push`)
- [ ] Deploy PayStack webhook function
- [ ] Deploy send-email function
- [ ] Set Resend API key
- [ ] Set PayStack secret key
- [ ] Update PayStack webhook URL
- [ ] Test restaurant booking flow
- [ ] Test email delivery
- [ ] Test concierge limits
- [ ] Monitor logs for 24 hours
- [ ] Update production keys when ready

---

**Status:** Ready for deployment 🚀

**Next Steps:** Run commands in sequence, test each component, monitor production
