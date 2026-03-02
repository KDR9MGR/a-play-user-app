# 🚀 Database Setup - Next Steps

**Status**: SQL syntax errors fixed ✅
**Date**: December 23, 2024
**Ready to proceed**: YES

---

## ✅ What's Been Fixed

Both SQL syntax errors in `00_initial_schema.sql` have been resolved:

1. **UNIQUE constraint error** (Line 129):
   - ❌ Old: `UNIQUE(user_id, status) WHERE status = 'active'` (inline constraint - not supported)
   - ✅ Fixed: Converted to partial unique index after table creation
   ```sql
   CREATE UNIQUE INDEX idx_user_subscriptions_user_active
     ON user_subscriptions(user_id)
     WHERE status = 'active';
   ```

2. **Immutable function error** (events table):
   - ❌ Old: `WHERE is_active = true AND end_date > NOW()` (NOW() is not immutable)
   - ✅ Fixed: Simplified to remove NOW() predicate
   ```sql
   CREATE INDEX idx_events_active_start_date ON events(is_active, start_date)
     WHERE is_active = true;
   ```

---

## 📋 What You Need to Do Now

### Step 1: Run the Fixed Schema Migration

1. Open your Supabase project dashboard
2. Go to **SQL Editor** (left sidebar)
3. Click **New query**
4. Copy and paste the **entire contents** of:
   ```
   supabase/migrations/00_initial_schema.sql
   ```
5. Click **Run** (or press Cmd/Ctrl + Enter)

### Expected Success Output:
```
✅ Initial schema created successfully!
📊 Tables created: 14
🗂️ Indexes created: 20+
🔄 Next step: Run 01_rls_policies.sql
```

### If You Get Errors:
- Copy the exact error message
- Note which line number it occurred at
- I'll help you fix it immediately

---

### Step 2: Verify Tables Were Created

After running the schema migration, verify in Supabase Dashboard:

1. Go to **Table Editor** (left sidebar)
2. You should see **14 tables**:
   - ✅ profiles
   - ✅ subscription_plans
   - ✅ user_subscriptions
   - ✅ point_redemptions
   - ✅ referrals
   - ✅ events
   - ✅ bookings
   - ✅ clubs
   - ✅ lounges
   - ✅ pubs
   - ✅ arcade_centers
   - ✅ beaches
   - ✅ live_shows
   - ✅ restaurants

---

### Step 3: Run RLS Policies (Second Migration)

Once Step 1 succeeds:

1. Create another **New query** in SQL Editor
2. Copy and paste contents of:
   ```
   supabase/migrations/01_rls_policies.sql
   ```
3. Click **Run**

### Expected Output:
```
✅ RLS policies created successfully!
🔒 All tables now have row-level security enabled
🔄 Next step: Run 02_functions_triggers.sql
```

---

### Step 4: Run Functions & Triggers (Third Migration)

1. Create another **New query** in SQL Editor
2. Copy and paste contents of:
   ```
   supabase/migrations/02_functions_triggers.sql
   ```
3. Click **Run**

### Expected Output:
```
✅ Functions and triggers created successfully!
⚙️  Auto-update timestamps enabled
🎁 Points system configured
👥 Referral system ready
🔄 Next step: Run 03_seed_data.sql
```

---

### Step 5: Run Seed Data (Fourth Migration)

1. Create another **New query** in SQL Editor
2. Copy and paste contents of:
   ```
   supabase/migrations/03_seed_data.sql
   ```
3. Click **Run**

### Expected Output:
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

---

## 🧪 Step 6: Verify Everything Works

Run these queries in SQL Editor to verify:

### Check All Tables Exist:
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```
**Expected**: 14 tables listed

### Check Subscription Plans:
```sql
SELECT id, name, tier_level, price_monthly, price_yearly
FROM subscription_plans
ORDER BY tier_level;
```
**Expected**: 4 plans (Free, Gold, Platinum, Black)

### Check Sample Events:
```sql
SELECT title, start_date, price, is_featured
FROM events
WHERE is_active = true
ORDER BY start_date;
```
**Expected**: 7 events with dates starting today

### Check RLS Policies:
```sql
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```
**Expected**: 30+ policies

---

## 🔗 Step 7: Update Flutter App Configuration

After database setup is complete, update your Flutter app:

### Create/Update `.env` file:
```env
# Supabase Configuration (STAGING)
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# PayStack (Staging)
PAYSTACK_PUBLIC_KEY=pk_test_your_test_key

# App Environment
APP_ENV=staging
```

### Get Supabase Credentials:
1. Go to **Settings** → **API** in Supabase Dashboard
2. Copy **Project URL** → Use for `SUPABASE_URL`
3. Copy **anon/public key** → Use for `SUPABASE_ANON_KEY`

---

## 📱 Step 8: Test the App

1. Run the Flutter app: `flutter run`
2. Create a test account (email + password)
3. Verify that:
   - ✅ Profile is created automatically
   - ✅ Free subscription is assigned
   - ✅ Unique referral code is generated
   - ✅ Events show up on home screen
   - ✅ You can view subscription plans

---

## 🆘 If You Encounter Issues

### Common Issues:

**Issue**: "Extension uuid-ossp does not exist"
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

**Issue**: "Trigger function does not exist"
- **Cause**: Ran files out of order
- **Solution**: Run migrations in correct order (00 → 01 → 02 → 03)

**Issue**: "RLS policy preventing access"
- **Cause**: User not authenticated
- **Solution**: Make sure you're logged in via the app

**Issue**: "No events showing in app"
- Check events are not in the past
- Check events are active (`is_active = true`)
- Run this query:
```sql
SELECT title, start_date, end_date, is_active
FROM events
ORDER BY start_date;
```

---

## 📚 Reference Documentation

For detailed information, see:
- **STAGING_DATABASE_SETUP_GUIDE.md** - Complete setup guide
- **SUBSCRIPTION_PLANS.md** - Subscription system details
- **USER_APP_SCHEMA_UPDATE_PLAN.md** - App schema alignment guide

---

## ✅ Success Checklist

Before marking database setup as complete:

- [ ] `00_initial_schema.sql` ran successfully
- [ ] 14 tables exist in Table Editor
- [ ] `01_rls_policies.sql` ran successfully
- [ ] 30+ policies visible in pg_policies
- [ ] `02_functions_triggers.sql` ran successfully
- [ ] 11 functions created
- [ ] `03_seed_data.sql` ran successfully
- [ ] 4 subscription plans exist
- [ ] 7 sample events exist
- [ ] App `.env` file updated with Supabase credentials
- [ ] Test user signup creates profile + free subscription
- [ ] Events show on app home screen

---

**Ready to proceed!** Start with Step 1 above and let me know if you hit any errors.
