# 🚀 A-Play Deployment Guide

**Quick Reference for Production Deployment**

> 📖 **Quick Start:** See [QUICK_DEPLOY.md](QUICK_DEPLOY.md) for copy-paste deployment commands
> 📚 **Detailed Guide:** See [SUPABASE_SYNC_GUIDE.md](SUPABASE_SYNC_GUIDE.md) for comprehensive sync instructions

---

## ✅ Pre-Deployment Checklist

### 1. Update Production Keys

#### PayStack Public Key
**File:** [lib/core/config/env.dart](lib/core/config/env.dart#L3)
```dart
static const String _hardcodedPaystackKey = 'pk_live_YOUR_PRODUCTION_KEY';
```
Replace `pk_test_your_test_key` with your **PayStack Live Key**

#### Email Sender Domain
**File:** [supabase/functions/send-email/index.ts](supabase/functions/send-email/index.ts#L47)
```typescript
from: 'A-Play <bookings@aplay.gh>',  // Your domain
```
Replace `bookings@resend.dev` with your actual domain

---

## 📦 Deployment Steps

### Step 1: Database Migrations

```bash
# Navigate to project root
cd /Users/abdulrazak/Documents/a-play-user-app-main

# Push migrations to Supabase
supabase db push
```

**Expected Output:**
```
✓ Applying migration 20260321_concierge_request_tracking.sql...
✓ Applying migration 20260321_restaurant_payment_fields.sql...
✓ All migrations applied successfully
```

**Migrations Applied:**
- `concierge_request_tracking` table created
- `restaurant_bookings` payment columns added
- Indexes created for performance
- RLS policies configured

---

### Step 2: Deploy Edge Functions

```bash
# Deploy send-email function
supabase functions deploy send-email

# Deploy paystack-webhook function
supabase functions deploy paystack-webhook
```

**Verify Deployment:**
```bash
supabase functions list
```

---

### Step 3: Verify Environment Variables

```bash
# Check Supabase secrets
supabase secrets list
```

**Required Secrets:**
- ✅ `RESEND_API_KEY` - Your Resend API key
- ✅ `PAYSTACK_SECRET_KEY` - PayStack secret (NOT public key)
- ✅ `SUPABASE_URL` - Auto-configured
- ✅ `SUPABASE_SERVICE_ROLE_KEY` - Auto-configured

**Set Missing Secrets:**
```bash
supabase secrets set RESEND_API_KEY=re_your_api_key
supabase secrets set PAYSTACK_SECRET_KEY=sk_live_your_secret_key
```

---

### Step 4: Flutter App

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run code generation (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## 🧪 Testing in Production

### Test Trial Flow
1. Create new account (use real email)
2. Complete onboarding
3. Verify trial offer screen appears
4. Start 3-day trial
5. Check database: `user_subscriptions` should have trial record

```sql
SELECT * FROM user_subscriptions WHERE user_id = 'your_user_id';
```

### Test Event Booking Email
1. Book an event ticket
2. Complete PayStack payment (use PayStack live mode)
3. Check email inbox for confirmation
4. Verify QR code displays
5. Check database: `bookings` table has record

```sql
SELECT * FROM bookings WHERE user_id = 'your_user_id' ORDER BY created_at DESC LIMIT 1;
```

### Test Restaurant Booking
1. Browse restaurants
2. Select table and time
3. Navigate to payment screen
4. Complete PayStack payment
5. Verify email received
6. Check database: `restaurant_bookings` table

```sql
SELECT * FROM restaurant_bookings WHERE user_id = 'your_user_id' ORDER BY created_at DESC LIMIT 1;
```

### Test Concierge Limits
1. Create Gold subscription account
2. Make 3 concierge requests
3. Attempt 4th request → Should block with message
4. Check tracking table

```sql
SELECT * FROM concierge_request_tracking WHERE user_id = 'your_user_id';
```

### Test Webhook
1. Make test payment via PayStack live mode
2. Check Supabase logs:
```bash
supabase functions logs paystack-webhook --tail
```
3. Verify booking created in database
4. Confirm email sent

---

## 🔍 Monitoring & Logging

### View Edge Function Logs

```bash
# Real-time webhook logs
supabase functions logs paystack-webhook --tail

# Real-time email logs
supabase functions logs send-email --tail

# View specific function errors
supabase functions logs paystack-webhook --level error
```

### Database Queries for Monitoring

**Recent Bookings:**
```sql
SELECT
  id, user_id, status, payment_status, created_at
FROM bookings
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

**Failed Payments:**
```sql
SELECT
  id, payment_reference, payment_status, created_at
FROM restaurant_bookings
WHERE payment_status = 'failed'
ORDER BY created_at DESC;
```

**Concierge Usage:**
```sql
SELECT
  user_id, month, year, request_count
FROM concierge_request_tracking
WHERE year = 2026 AND month = 3
ORDER BY request_count DESC;
```

---

## ⚠️ Common Issues & Fixes

### Issue 1: Webhook Not Receiving Events
**Symptom:** Bookings not created after payment

**Fix:**
1. Verify webhook URL in PayStack dashboard
2. Check webhook signature secret matches
3. View logs: `supabase functions logs paystack-webhook`

**PayStack Webhook URL:**
```
https://your-project-ref.supabase.co/functions/v1/paystack-webhook
```

### Issue 2: Emails Not Sending
**Symptom:** Bookings created but no emails

**Check:**
1. Resend API key is correct
2. Sender domain is verified in Resend
3. View logs: `supabase functions logs send-email`

**Debug:**
```sql
-- Check if email service is being called
SELECT
  id, user_id, created_at
FROM bookings
WHERE created_at > NOW() - INTERVAL '1 hour';
```

### Issue 3: Template Not Found
**Symptom:** Email error "Template not found"

**Fix:**
1. Ensure template files are in correct directory:
```bash
ls supabase/functions/send-email/templates/
# Should show:
# event-booking.html
# restaurant-booking.html
# club-booking.html
```

2. Redeploy function:
```bash
supabase functions deploy send-email
```

### Issue 4: Concierge Always Blocked
**Symptom:** Even subscribed users can't access concierge

**Check:**
```sql
-- Verify active subscription
SELECT
  us.user_id, us.tier, us.status, sp.features
FROM user_subscriptions us
JOIN subscription_plans sp ON sp.id = us.plan_id
WHERE us.user_id = 'your_user_id' AND us.status = 'active';

-- Check features include concierge_access: true
```

**Fix:** Update subscription plan features:
```sql
UPDATE subscription_plans
SET features = jsonb_set(features, '{concierge_access}', 'true'::jsonb)
WHERE tier_level >= 2;  -- Gold, Platinum, Black
```

---

## 📊 Performance Optimization

### Database Indexes (Already Created)
```sql
-- Verify indexes exist
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('restaurant_bookings', 'concierge_request_tracking');
```

### Expected Indexes:
- `idx_restaurant_bookings_payment_ref`
- `idx_restaurant_bookings_transaction_id`
- `idx_restaurant_bookings_payment_status`
- `idx_concierge_tracking_user_date`

---

## 🔐 Security Checklist

- [x] PayStack webhook signature verification enabled
- [x] Supabase Row Level Security (RLS) enabled on all tables
- [x] Service role key never exposed to client
- [x] Email templates sanitize user input
- [x] Idempotency protection on payments
- [x] HTTPS enforced on all endpoints

---

## 📱 App Store Submission Notes

### iOS (Apple IAP)
**Already Implemented:**
- ✅ StoreKit integration
- ✅ Receipt validation via Edge Function
- ✅ Sandbox and production support
- ✅ Restore purchases

**Before Submission:**
- Set up App Store Connect subscription products
- Match product IDs in code with App Store
- Test with TestFlight

### Android (PayStack)
**Already Implemented:**
- ✅ PayStack web payment
- ✅ Server-side verification
- ✅ Webhook handling

**Before Submission:**
- Update to PayStack live keys
- Test on physical Android device
- Ensure payment flow works on low-end devices

---

## 🎯 Success Metrics to Monitor

### Week 1 After Launch:
- [ ] Trial conversion rate > 30%
- [ ] Email delivery success > 95%
- [ ] Payment success rate > 90%
- [ ] Zero duplicate bookings (idempotency working)
- [ ] Concierge limits enforced correctly

### Queries for Metrics:

**Trial Conversion:**
```sql
SELECT
  COUNT(CASE WHEN subscription_type = '3-Day Free Trial' THEN 1 END) as trials,
  COUNT(CASE WHEN tier IN ('Gold', 'Platinum', 'Black') THEN 1 END) as paid,
  ROUND(100.0 * COUNT(CASE WHEN tier IN ('Gold', 'Platinum', 'Black') THEN 1 END) /
        NULLIF(COUNT(CASE WHEN subscription_type = '3-Day Free Trial' THEN 1 END), 0), 2) as conversion_rate
FROM user_subscriptions;
```

**Payment Success Rate:**
```sql
SELECT
  payment_status,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM restaurant_bookings
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY payment_status;
```

---

## 🚨 Rollback Plan

If issues occur after deployment:

### Rollback Database Migrations
```bash
# Revert to previous migration
supabase db reset
```

### Rollback Edge Functions
```bash
# Deploy previous version
git checkout previous_commit
supabase functions deploy send-email
supabase functions deploy paystack-webhook
```

### Emergency: Disable Feature
```sql
-- Temporarily disable concierge for all tiers
UPDATE subscription_plans
SET features = jsonb_set(features, '{concierge_access}', 'false'::jsonb);

-- Re-enable later
UPDATE subscription_plans
SET features = jsonb_set(features, '{concierge_access}', 'true'::jsonb)
WHERE tier_level >= 2;
```

---

## 📞 Support Contacts

**Supabase Support:** https://supabase.com/dashboard/support
**PayStack Support:** support@paystack.com
**Resend Support:** https://resend.com/support

---

## ✅ Final Pre-Launch Checklist

- [ ] PayStack live keys updated
- [ ] Email sender domain configured
- [ ] Database migrations applied
- [ ] Edge functions deployed
- [ ] Environment variables verified
- [ ] Test payment completed successfully
- [ ] Test email received
- [ ] Concierge limits working
- [ ] Trial offer appears after signup
- [ ] `flutter analyze` passes with no errors
- [ ] App Store / Play Store metadata updated
- [ ] Privacy policy and terms updated
- [ ] Backup plan in place
- [ ] Monitoring dashboard configured

---

## 🎉 You're Ready to Launch!

Once all checklist items are complete:

1. Deploy Flutter app to stores
2. Monitor logs for first 24 hours
3. Check email delivery rates
4. Verify payment webhook is working
5. Track trial conversion metrics

**Good luck with your launch! 🚀**

---

*Last Updated: March 21, 2026*
*Version: 1.0 - Production Ready*
