-- =====================================================
-- 🚀 STAGING DATABASE SETUP GUIDE
-- =====================================================
**Created**: December 16, 2024
**Status**: Ready for Deployment
**Environment**: Staging

---

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ Supabase project created (staging environment)
- ✅ Supabase project URL and anon key
- ✅ Database password
- ✅ SQL editor access in Supabase Dashboard

---

## 🗂️ Migration Files Overview

You have **4 SQL migration files** to run in order:

| File | Purpose | Tables/Objects Created |
|------|---------|----------------------|
| `00_initial_schema.sql` | Create all database tables | 14 tables + indexes |
| `01_rls_policies.sql` | Row-level security policies | 30+ RLS policies |
| `02_functions_triggers.sql` | Database functions & triggers | 11 functions, 12 triggers |
| `03_seed_data.sql` | Sample test data | 50+ sample records |

---

## 🔧 Step-by-Step Setup

### Step 1: Access Supabase SQL Editor

1. Go to your Supabase project dashboard
2. Click **"SQL Editor"** in the left sidebar
3. Click **"New query"**

### Step 2: Run Migration Files (IN ORDER)

#### 2.1 Run Schema Migration

```sql
-- Copy and paste contents of supabase/migrations/00_initial_schema.sql
-- Then click "Run" or press Cmd/Ctrl + Enter
```

**Expected Output**:
```
✅ Initial schema created successfully!
📊 Tables created: 14
🔄 Next step: Run 01_rls_policies.sql
```

**Verify**: Check that 14 tables appear in the **"Table Editor"** sidebar

#### 2.2 Run RLS Policies

```sql
-- Copy and paste contents of supabase/migrations/01_rls_policies.sql
-- Then click "Run"
```

**Expected Output**:
```
✅ RLS policies created successfully!
🔒 All tables now have row-level security enabled
🔄 Next step: Run 02_functions_triggers.sql
```

**Verify**: Go to **Authentication** → **Policies** and check that policies exist for all tables

#### 2.3 Run Functions & Triggers

```sql
-- Copy and paste contents of supabase/migrations/02_functions_triggers.sql
-- Then click "Run"
```

**Expected Output**:
```
✅ Functions and triggers created successfully!
⚙️  Auto-update timestamps enabled
🎁 Points system configured
👥 Referral system ready
🔄 Next step: Run 03_seed_data.sql
```

**Verify**: Check **Database** → **Functions** to see all created functions

#### 2.4 Run Seed Data

```sql
-- Copy and paste contents of supabase/migrations/03_seed_data.sql
-- Then click "Run"
```

**Expected Output**:
```
✅ Seed data inserted successfully!
📊 4 subscription plans created
🎉 7 sample events added
🍸 3 clubs, 2 lounges, 2 pubs added
🎮 2 arcade centers added
🏖️  3 beaches added
🎭 2 live shows added
🍽️  3 restaurants added

🎯 Database setup complete!
📱 You can now test the user app
```

**Verify**: Use **Table Editor** to browse data in each table

---

## 🔐 Step 3: Configure Authentication

### 3.1 Enable Email Provider

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. Configure email templates (optional)

### 3.2 Enable OAuth (Optional)

1. Go to **Authentication** → **Providers**
2. Enable **Google** provider
3. Add OAuth credentials:
   - Client ID
   - Client Secret
   - Redirect URL: `https://<your-project-ref>.supabase.co/auth/v1/callback`

### 3.3 Configure Site URL

1. Go to **Authentication** → **URL Configuration**
2. Set **Site URL**: `your-app-url.com` (or `localhost:3000` for testing)
3. Set **Redirect URLs**: Add allowed redirect URLs

---

## 📊 Step 4: Verify Database Structure

### 4.1 Check Tables

Run this query to list all tables:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Expected 14 tables**:
- arcade_centers
- beaches
- bookings
- clubs
- events
- live_shows
- lounges
- point_redemptions
- profiles
- pubs
- referrals
- restaurants
- subscription_plans
- user_subscriptions

### 4.2 Check Subscription Plans

```sql
SELECT id, name, tier_level, price_monthly, price_yearly
FROM subscription_plans
ORDER BY tier_level;
```

**Expected 4 plans**:
| ID | Name | Tier Level | Monthly | Yearly |
|----|------|-----------|---------|--------|
| free-tier | Free | 1 | 0.00 | 0.00 |
| gold-tier | Gold | 2 | 120.00 | 1200.00 |
| platinum-tier | Platinum | 3 | 250.00 | 2500.00 |
| black-tier | Black | 4 | 500.00 | 5000.00 |

### 4.3 Check Events

```sql
SELECT title, start_date, price, is_featured
FROM events
WHERE is_active = true
ORDER BY start_date;
```

**Expected**: 7 sample events with dates starting from today

### 4.4 Check RLS Policies

```sql
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Expected**: 30+ policies across all tables

---

## 🔗 Step 5: Update App Configuration

### 5.1 Update .env File

Create/update `.env` file in your Flutter app:

```env
# Supabase Configuration (STAGING)
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# PayStack (Staging)
PAYSTACK_PUBLIC_KEY=pk_test_your_test_key

# App Environment
APP_ENV=staging
```

### 5.2 Get Supabase Credentials

1. Go to **Settings** → **API**
2. Copy **Project URL** → Use for `SUPABASE_URL`
3. Copy **anon/public key** → Use for `SUPABASE_ANON_KEY`

---

## 🧪 Step 6: Test the Setup

### 6.1 Test User Signup

1. Run your Flutter app
2. Create a new account (email + password)
3. Check database:

```sql
-- Should auto-create profile and free subscription
SELECT
  p.email,
  p.full_name,
  us.tier,
  us.referral_code,
  us.reward_points
FROM profiles p
JOIN user_subscriptions us ON us.user_id = p.id
WHERE p.email = 'your-test-email@example.com';
```

**Expected**:
- Profile created
- Free tier subscription created
- Unique referral code generated
- 0 reward points

### 6.2 Test Events Display

1. Open app home screen
2. Verify events appear in:
   - Featured carousel
   - Upcoming Events section (Today/Tomorrow/This Week filters)

### 6.3 Test Subscription Plans

1. Navigate to **Profile** → **Subscription**
2. Verify all 4 tiers display:
   - Free (current tier)
   - Gold
   - Platinum
   - Black
3. Check that prices show correctly

### 6.4 Test Booking Flow

1. Select an event
2. Book a ticket
3. Verify in database:

```sql
-- Check booking created and points awarded
SELECT
  b.id,
  b.status,
  b.payment_status,
  b.points_awarded,
  us.reward_points
FROM bookings b
JOIN user_subscriptions us ON us.user_id = b.user_id
WHERE b.user_id = 'your-user-id'
ORDER BY b.created_at DESC
LIMIT 1;
```

**Expected** (after payment confirmed):
- Booking status: 'confirmed'
- Payment status: 'paid'
- Points awarded: 10 (Free tier = 1x multiplier × 10 base points)
- Subscription reward_points increased by 10

---

## 🛠️ Common Issues & Solutions

### Issue 1: "Extension uuid-ossp does not exist"

**Solution**:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Issue 2: "Trigger function does not exist"

**Cause**: Ran files out of order

**Solution**: Run migrations in correct order (00 → 01 → 02 → 03)

### Issue 3: "RLS policy preventing access"

**Cause**: User not authenticated or policy too restrictive

**Solution**: Check if user is logged in via `auth.uid()`
```sql
-- Test if auth is working
SELECT auth.uid();  -- Should return user ID when logged in
```

### Issue 4: "No events showing in app"

**Possible causes**:
1. Events are in the past
2. Events are inactive
3. Date filter too strict

**Solution**: Check events data:
```sql
SELECT
  title,
  start_date,
  end_date,
  is_active,
  CASE
    WHEN end_date < NOW() THEN 'Past event'
    WHEN start_date > NOW() THEN 'Upcoming event'
    ELSE 'Ongoing event'
  END as status
FROM events
ORDER BY start_date;
```

### Issue 5: "Cannot insert into subscription_plans"

**Cause**: RLS prevents non-admin inserts

**Solution**: Run seed data as service_role or via SQL Editor (which bypasses RLS)

---

## 📈 Monitoring & Maintenance

### Check Database Size

```sql
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Monitor Active Subscriptions

```sql
SELECT
  tier,
  COUNT(*) as user_count,
  SUM(reward_points) as total_points
FROM user_subscriptions
WHERE status = 'active'
GROUP BY tier
ORDER BY tier_level;
```

### Check Upcoming Events

```sql
SELECT
  COUNT(*) FILTER (WHERE start_date::date = CURRENT_DATE) as today,
  COUNT(*) FILTER (WHERE start_date::date = CURRENT_DATE + 1) as tomorrow,
  COUNT(*) FILTER (WHERE start_date::date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7) as this_week,
  COUNT(*) as total_upcoming
FROM events
WHERE is_active = true AND end_date > NOW();
```

### Monitor Booking Revenue

```sql
SELECT
  DATE_TRUNC('day', created_at) as date,
  COUNT(*) as booking_count,
  SUM(total_price) as revenue,
  AVG(total_price) as avg_booking_value
FROM bookings
WHERE payment_status = 'paid'
  AND created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date DESC;
```

---

## 🔄 Cron Jobs Setup (Optional)

### Auto-expire Subscriptions

Set up a cron job to run daily:

1. Go to **Database** → **Cron Jobs** (if available)
2. Create new job:

```sql
SELECT expire_old_subscriptions();
```

**Schedule**: `0 2 * * *` (2 AM daily)

---

## 📚 Database Schema Reference

### Key Tables

#### profiles
- User account information
- Links to auth.users
- Tracks current_tier (denormalized)

#### subscription_plans
- 4-tier system (Free, Gold, Platinum, Black)
- Rich features as JSONB
- Monthly and annual pricing

#### user_subscriptions
- User's active subscription
- Reward points balance
- Referral code
- Auto-renewable

#### events
- All events and shows
- Capacity tracking
- Featured flag
- Venue linking

#### bookings
- Event ticket purchases
- Payment tracking
- QR codes
- Points awarded

### Key Functions

| Function | Purpose |
|----------|---------|
| `handle_new_user()` | Auto-create profile + free subscription |
| `increment_reward_points()` | Add points to user |
| `award_booking_points()` | Auto-award points on booking |
| `complete_referral()` | Process referral rewards |
| `calculate_discounted_price()` | Apply tier discount |
| `has_early_access()` | Check booking eligibility |

---

## ✅ Success Checklist

Before going live, verify:

- [ ] All 4 migration files ran successfully
- [ ] 14 tables exist with data
- [ ] 4 subscription plans created
- [ ] Sample events visible
- [ ] User signup creates profile + free subscription
- [ ] RLS policies working (users can only see their own data)
- [ ] Booking awards points correctly
- [ ] Events filter by date correctly
- [ ] All triggers firing (updated_at, points, capacity)
- [ ] App successfully connects to database
- [ ] Authentication working (signup, login, logout)
- [ ] No console errors in app

---

## 🆘 Support & Resources

### Supabase Documentation
- [Supabase Docs](https://supabase.com/docs)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Functions](https://supabase.com/docs/guides/database/functions)

### App Documentation
- `SUBSCRIPTION_PLANS.md` - Full subscription details
- `USER_APP_SCHEMA_UPDATE_PLAN.md` - App update guide
- `QUICK_START_SCHEMA_MIGRATION.md` - Quick reference

### Need Help?
- Check Supabase logs in Dashboard → Database → Logs
- Review `pg_policies` table for RLS issues
- Test queries in SQL Editor with `EXPLAIN ANALYZE`

---

**Database Version**: 1.0.0
**Last Updated**: December 16, 2024
**Status**: ✅ Ready for Testing
