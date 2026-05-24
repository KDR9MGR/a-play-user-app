# Instructions to Clear All Users from Supabase

## ⚠️ WARNING
This will **DELETE ALL USERS** and **ALL USER DATA** from your database. This action is **IRREVERSIBLE**.

---

## Option 1: Using Supabase Dashboard (Recommended)

### Step 1: Go to Supabase Dashboard
1. Open your browser and go to: https://supabase.com/dashboard
2. Sign in to your account
3. Select your project: **gixstjuzbqcvdfcqeztk**

### Step 2: Run the SQL Script
1. In the left sidebar, click **SQL Editor**
2. Click **New Query**
3. Open the file: `supabase/migrations/CLEAR_ALL_USERS.sql`
4. Copy the entire content
5. Paste it into the SQL Editor
6. Click **RUN** (or press Cmd/Ctrl + Enter)

### Step 3: Verify Deletion
The script will automatically show you a summary:
```
============================================
DELETION COMPLETE
============================================
Auth Users: 0
Profiles: 0
Subscriptions: 0
Bookings: 0
============================================
✅ All users successfully deleted!
```

---

## Option 2: Delete Users Individually (Manual)

If you prefer to see users before deleting:

### Step 1: View All Users
1. Go to Supabase Dashboard
2. Click **Authentication** in the left sidebar
3. Click **Users**
4. You'll see a list of all registered users

### Step 2: Delete Users One by One
1. Click the **three dots (•••)** next to each user
2. Select **Delete user**
3. Confirm deletion
4. Repeat for all users

**Note:** This method deletes users from `auth.users`, but you'll still need to clean up their data in other tables.

---

## Option 3: Using Supabase CLI

### Prerequisites
- Supabase CLI installed ✅ (already installed on your system)
- Project linked to CLI

### Step 1: Link Your Project
```bash
cd /Users/abdulrazak/Documents/a-play-user-app-main

# Link to your project
supabase link --project-ref gixstjuzbqcvdfcqeztk
```

### Step 2: Run the Migration
```bash
# Apply the clear users migration
supabase db push --include-all
```

**OR** run directly via psql:
```bash
# Get your database URL from Supabase Dashboard > Settings > Database
# Then run:
psql "postgresql://postgres:[YOUR-PASSWORD]@db.gixstjuzbqcvdfcqeztk.supabase.co:5432/postgres" \
  -f supabase/migrations/CLEAR_ALL_USERS.sql
```

---

## What Gets Deleted

The script deletes data from these tables (in order):

### Chat & Social
- `chat_messages`
- `chat_participants`
- `chats`
- `friendships`
- `post_gifts`
- `post_likes`
- `post_comments`
- `posts`

### Bookings
- `booking_cancellations`
- `bookings`
- `restaurant_bookings`
- `club_bookings`
- `event_categories`
- `event_images`

### Subscriptions & Payments
- `user_subscriptions` ← **Your IAP subscriptions**
- `subscriptions`
- `subscription_plans`
- `user_points`
- `payment_history`

### Other
- `concierge_requests`
- `referrals`
- `podcast_episodes`
- `podcasts`
- `profiles`
- `auth.users` ← **All authentication data**

---

## After Deletion

### Test with Fresh Users
1. Open your app
2. Sign up with a new test account
3. Verify welcome email is sent
4. Test IAP subscription purchase
5. Verify subscription syncs correctly

### What Remains Intact
- Event data (events, venues, categories)
- Club and restaurant information
- Database schema and structure
- Edge Functions
- Storage buckets
- RLS policies

---

## Troubleshooting

### Error: "permission denied"
**Solution:** Make sure you're running the SQL from the Supabase Dashboard SQL Editor, which has admin privileges.

### Error: "violates foreign key constraint"
**Solution:** The script is designed to delete in the correct order. If you still get this error, the table might not be in the script. Add it before its dependent tables.

### Some users remain
**Solution:**
1. Go to Authentication > Users in Supabase Dashboard
2. Manually delete remaining users
3. Then run the script again to clean up orphaned data

---

## Quick Commands

### Check User Count
```sql
SELECT COUNT(*) FROM auth.users;
SELECT COUNT(*) FROM profiles;
```

### Check Subscription Count
```sql
SELECT COUNT(*) FROM user_subscriptions;
```

### View All Tables
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

---

## Need Help?

If you encounter issues:
1. Check Supabase logs: Dashboard > Logs
2. Verify you have admin/service_role permissions
3. Try deleting users manually from Authentication > Users first
4. Then run the cleanup script for remaining data

---

**Created:** 2026-04-24
**Project:** A-Play User App
**Supabase Project ID:** gixstjuzbqcvdfcqeztk
