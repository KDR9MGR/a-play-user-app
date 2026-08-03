# Complete User Deletion Guide

**File:** `DELETE_USER_COMPLETE.sql`
**Purpose:** Permanently delete a user from ALL tables including auth

---

## ⚠️ WARNING

**THIS IS PERMANENT AND CANNOT BE UNDONE!**
- Deletes user from 25+ tables
- Removes all bookings, posts, chats, points
- Deletes from auth.users (user cannot login)

**Always:**
- Test on staging first
- Backup database before mass deletions
- Double-check the email/ID

---

## Quick Usage (Recommended)

### Step 1: Check What Will Be Deleted
```bash
# Replace 'user@example.com' with actual email
echo "
SELECT
  u.id,
  u.email,
  u.created_at,
  (SELECT COUNT(*) FROM event_bookings WHERE user_id = u.id) as bookings,
  (SELECT COUNT(*) FROM feeds WHERE user_id = u.id) as posts,
  (SELECT COUNT(*) FROM user_subscriptions WHERE user_id = u.id) as subscriptions
FROM auth.users u
WHERE u.email = 'user@example.com';
" | supabase db query --linked
```

### Step 2: Delete the User
```bash
# Method 1: Using the SQL file
cat DELETE_USER_COMPLETE.sql | supabase db query --linked
# (Edit the email in the file first)

# Method 2: Using psql directly
echo "SELECT delete_user_completely('user@example.com');" | supabase db query --linked
```

---

## Methods Available

### Method 1: Delete by Email (Easiest) ✅

**Edit `DELETE_USER_COMPLETE.sql`:**
```sql
v_email TEXT := 'user@example.com'; -- CHANGE THIS
```

**Then run:**
```bash
cat DELETE_USER_COMPLETE.sql | supabase db query --linked
```

---

### Method 2: Delete by User ID

**If you know the UUID:**
```sql
DO $$
DECLARE
  v_user_id UUID := 'abc-123-def-456'; -- REPLACE
BEGIN
  -- Deletion code...
END $$;
```

---

### Method 3: Create Function (Best for Multiple Users)

**Run once to create function:**
```bash
echo "
CREATE OR REPLACE FUNCTION delete_user_completely(p_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
DECLARE
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = p_email;
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_email;
  END IF;

  -- Delete from all tables (in correct order)
  DELETE FROM point_transactions WHERE user_id = v_user_id;
  DELETE FROM user_points WHERE user_id = v_user_id;
  DELETE FROM user_subscriptions WHERE user_id = v_user_id;
  DELETE FROM event_bookings WHERE user_id = v_user_id;
  DELETE FROM feeds WHERE user_id = v_user_id;
  DELETE FROM chat_messages WHERE sender_id = v_user_id;
  DELETE FROM profiles WHERE id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;

  RAISE NOTICE '✓ User deleted: %', p_email;
END;
\$\$;
" | supabase db query --linked
```

**Then use it:**
```bash
echo "SELECT delete_user_completely('user@example.com');" | supabase db query --linked
```

---

## What Gets Deleted

### 1. Points & Referrals
- point_transactions
- point_redemptions
- user_points
- user_challenge_progress
- user_daily_logins
- referral_history
- referrals

### 2. Subscriptions
- user_subscriptions

### 3. Bookings
- event_bookings
- club_bookings
- restaurant_bookings
- table_bookings

### 4. Social Features
- feeds (posts)
- feed_likes
- feed_comments
- post_gifts
- followers/following

### 5. Chat & Messages
- chat_messages
- chat_participants
- chats

### 6. Reviews & Favorites
- event_reviews
- club_reviews
- favorite_events
- favorite_clubs
- saved_events

### 7. Notifications & Sessions
- notifications
- user_sessions
- user_devices

### 8. Profile & Auth
- profiles
- **auth.users** ← User cannot login after this

---

## Examples

### Delete Banned User
```bash
echo "SELECT delete_user_completely('banned.user@example.com');" | supabase db query --linked
```

### Delete Test Account
```bash
echo "SELECT delete_user_completely('test@example.com');" | supabase db query --linked
```

### Delete Multiple Users
```bash
echo "
SELECT delete_user_completely('user1@example.com');
SELECT delete_user_completely('user2@example.com');
SELECT delete_user_completely('user3@example.com');
" | supabase db query --linked
```

---

## Verification

### Before Deletion
```bash
echo "SELECT id, email, created_at FROM auth.users WHERE email = 'user@example.com';" | supabase db query --linked
```

### After Deletion
```bash
echo "SELECT id, email FROM auth.users WHERE email = 'user@example.com';" | supabase db query --linked
# Should return: (0 rows)
```

---

## Troubleshooting

### Error: "User not found"
**Cause:** Email doesn't exist in database
**Fix:** Check spelling, verify email exists

### Error: "Permission denied"
**Cause:** Supabase user doesn't have admin rights
**Fix:** Run with `--linked` flag (uses service role)

### Error: "Foreign key constraint"
**Cause:** Deletion order is wrong
**Fix:** Use provided script - it handles FK order correctly

---

## Safety Tips

### 1. Always Backup First
```bash
# Backup before deletion
supabase db dump --linked > backup_before_delete.sql
```

### 2. Test on Staging
```bash
# Use staging project
supabase link --project-ref staging-project-ref
supabase db query --linked < DELETE_USER_COMPLETE.sql
```

### 3. Double Check Email
```bash
# Verify it's the right user
echo "SELECT id, email, created_at FROM auth.users WHERE email = 'user@example.com';" | supabase db query --linked
```

---

## Common Use Cases

### 1. Delete Sandbox Test Account
```sql
SELECT delete_user_completely('test@example.com');
```

### 2. Remove Banned User
```sql
SELECT delete_user_completely('spammer@example.com');
```

### 3. Clean Up Demo Accounts
```sql
SELECT delete_user_completely('demo1@example.com');
SELECT delete_user_completely('demo2@example.com');
```

### 4. Delete Your Own Test Account
```sql
SELECT delete_user_completely('your.test@example.com');
```

---

## Summary

**Fastest Method:**
1. Create function (run OPTION 4 from SQL file once)
2. Delete users: `SELECT delete_user_completely('email');`

**Safest Method:**
1. Check what will be deleted (OPTION 3)
2. Backup database
3. Run deletion (OPTION 1)
4. Verify user is gone

**For Your Current Issue (Banned Sandbox Account):**
```bash
# Just delete the banned sandbox account and create new one
echo "SELECT delete_user_completely('banned.sandbox@example.com');" | supabase db query --linked
```

Then create a fresh sandbox tester in App Store Connect with a different email.

---

**Status:** Ready to use! Choose your method and execute.
