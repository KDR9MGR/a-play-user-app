# User Deletion Guide

**Date:** May 30, 2026
**Purpose:** Complete hard deletion of users from A-Play database

---

## ⚠️ CRITICAL WARNINGS

1. **IRREVERSIBLE**: User deletion is permanent and cannot be undone
2. **NO SOFT DELETE**: These queries perform hard deletes, not soft deletes
3. **BACKUP FIRST**: Always backup production database before bulk deletions
4. **TEST IN STAGING**: Test deletion queries in staging environment first
5. **TWO-STEP PROCESS**: Database deletion + Auth deletion (both required)

---

## Database Schema Overview

### Tables with User Data (16 tables):

| Table | Records | Foreign Key | Cascade |
|-------|---------|-------------|---------|
| `booking_cancellations` | Cancellations | user_id → auth.users | YES |
| `bookings` | Event bookings | user_id → profiles | YES |
| `post_gifts` | Social gifts | gifter_user_id, receiver_user_id → profiles | YES |
| `chat_messages` | Messages | sender_id → profiles | NO |
| `chat_participants` | Chat membership | user_id → profiles | NO |
| `friendships` | Friend connections | user_id, friend_id → profiles | YES |
| `referrals` | Referral tracking | referrer_user_id, referred_user_id → profiles | YES |
| `point_redemptions` | Points spent | user_id → profiles | YES |
| `concierge_request_tracking` | Monthly limits | user_id → profiles | YES |
| `subscription_events` | Sub audit log | user_id → auth.users | YES |
| `subscriptions` | IAP subs | user_id → auth.users | YES |
| `user_subscriptions` | Active subs | user_id → profiles | YES |
| `profiles` | User profiles | id → auth.users | YES |
| `auth.users` | Auth accounts | - | - |

**Total User-Related Tables:** 14 (+ auth.users + chat_rooms)

---

## Method 1: Delete ALL Users (Nuclear Option)

### When to Use:
- Resetting staging/dev environment
- Testing fresh database state
- Development cleanup

### File: `DELETE_ALL_USERS.sql`

### How to Run:

#### Option A: Supabase Dashboard
1. Go to https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/sql
2. Paste contents of `DELETE_ALL_USERS.sql`
3. Click "Run"
4. Verify output shows 0 records remaining

#### Option B: Command Line (psql)
```bash
# From project root
psql "postgresql://postgres:[PASSWORD]@db.yvnfhsipyfxdmulajbgl.supabase.co:5432/postgres" \
  -f supabase/migrations/DELETE_ALL_USERS.sql
```

#### Option C: Supabase CLI
```bash
supabase db push --db-url "postgresql://postgres:[PASSWORD]@db.yvnfhsipyfxdmulajbgl.supabase.co:5432/postgres" \
  --file supabase/migrations/DELETE_ALL_USERS.sql
```

### What It Does:
```sql
-- Deletes from 13 tables in correct order:
1. booking_cancellations → 0 records
2. bookings → 0 records
3. post_gifts → 0 records
4. chat_messages → 0 records
5. chat_participants → 0 records
6. chat_rooms → 0 records
7. friendships → 0 records
8. referrals → 0 records
9. point_redemptions → 0 records
10. concierge_request_tracking → 0 records
11. subscription_events → 0 records
12. subscriptions → 0 records
13. user_subscriptions → 0 records
14. profiles → 0 records
```

### After Running SQL:
**STEP 2: Delete from auth.users**

```javascript
// Option 1: JavaScript (Supabase Admin API)
const { data: users } = await supabase.auth.admin.listUsers()
for (const user of users.users) {
  await supabase.auth.admin.deleteUser(user.id)
  console.log(`Deleted auth user: ${user.email}`)
}
```

```bash
# Option 2: cURL
# Get service role key from Supabase Dashboard
curl -X DELETE \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/admin/users/USER_ID' \
  -H 'apikey: YOUR_SERVICE_ROLE_KEY' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY'
```

---

## Method 2: Delete Single User

### When to Use:
- GDPR "right to be forgotten" requests
- User account deletion requests
- Removing specific test users
- Cleaning up orphaned accounts

### File: `DELETE_SINGLE_USER.sql`

### How to Run:

#### Option A: Supabase Dashboard (Manual)
1. Open `DELETE_SINGLE_USER.sql`
2. Replace `'USER_UUID_HERE'` with actual UUID (line 14)
   ```sql
   \set user_id '550e8400-e29b-41d4-a716-446655440000'
   ```
3. Paste into Supabase SQL Editor
4. Click "Run"

#### Option B: Command Line (Parameterized)
```bash
psql "postgresql://..." \
  -v user_id='550e8400-e29b-41d4-a716-446655440000' \
  -f supabase/migrations/DELETE_SINGLE_USER.sql
```

#### Option C: Using Database Function
```sql
-- First, apply the function:
psql "postgresql://..." -f supabase/migrations/USER_DELETION_FUNCTION.sql

-- Then call it:
SELECT delete_user_completely('550e8400-e29b-41d4-a716-446655440000');
```

### What It Does:
1. ✅ Verifies user exists (throws error if not found)
2. ✅ Shows user details (email, name) for confirmation
3. ✅ Deletes from all 13 tables in correct FK order
4. ✅ Returns deletion summary
5. ⚠️ Reminds you to delete from auth.users

### Example Output:
```
NOTICE: Deleting user: John Doe (john@example.com) - ID: 550e8400-...
NOTICE: ✓ Deleted booking_cancellations
NOTICE: ✓ Deleted bookings
...
NOTICE: ✓ Deleted profile
NOTICE: === USER DELETION COMPLETE ===
NOTICE: IMPORTANT: You must also delete from auth.users using Admin API
```

### After Running SQL:
**STEP 2: Delete from auth.users**

```javascript
// JavaScript
await supabase.auth.admin.deleteUser('550e8400-e29b-41d4-a716-446655440000')
```

---

## Method 3: Using Database Functions (Recommended)

### Advantages:
- ✅ Reusable across app/scripts
- ✅ Returns JSON summary
- ✅ Can be called via RPC from frontend
- ✅ Includes error handling
- ✅ Batch deletion support

### Setup:
```bash
# Apply the functions once
psql "postgresql://..." -f supabase/migrations/USER_DELETION_FUNCTION.sql
```

### Usage:

#### A. Delete Single User
```javascript
// Frontend/Backend JavaScript
const { data, error } = await supabase.rpc('delete_user_completely', {
  p_user_id: '550e8400-e29b-41d4-a716-446655440000'
})

console.log(data)
// {
//   "success": true,
//   "user_id": "550e8400-...",
//   "email": "john@example.com",
//   "full_name": "John Doe",
//   "deleted_records": {
//     "bookings": 5,
//     "friendships": 12,
//     "user_subscriptions": 1,
//     ...
//   },
//   "message": "User data deleted...",
//   "next_step": "await supabase.auth.admin.deleteUser(...)"
// }

// Then delete from auth
await supabase.auth.admin.deleteUser(data.user_id)
```

#### B. Delete Multiple Users (Batch)
```javascript
const userIds = [
  '550e8400-e29b-41d4-a716-446655440000',
  '6ba7b810-9dad-11d1-80b4-00c04fd430c8'
]

const { data } = await supabase.rpc('delete_users_batch', {
  p_user_ids: userIds
})

console.log(data)
// {
//   "success": true,
//   "total_users": 2,
//   "results": [...]
// }
```

#### C. Find Orphaned Profiles
```sql
-- SQL
SELECT * FROM find_orphaned_profiles();

-- Returns profiles without auth.users record
```

```javascript
// JavaScript
const { data } = await supabase.rpc('find_orphaned_profiles')
console.log(data) // Array of orphaned profiles
```

#### D. Clean Orphaned Profiles (Auto-cleanup)
```sql
-- SQL
SELECT clean_orphaned_profiles();

-- Automatically finds and deletes all orphaned profiles
```

```javascript
// JavaScript
const { data } = await supabase.rpc('clean_orphaned_profiles')
console.log(data)
// {
//   "success": true,
//   "message": "Deleted 3 orphaned profiles",
//   "deleted_count": 3
// }
```

---

## Complete Deletion Workflow

### For Single User:

```javascript
// Step 1: Delete from database tables
const { data, error } = await supabase.rpc('delete_user_completely', {
  p_user_id: userId
})

if (error) {
  console.error('Database deletion failed:', error)
  return
}

console.log('Database deletion summary:', data)

// Step 2: Delete from auth.users
const { error: authError } = await supabase.auth.admin.deleteUser(userId)

if (authError) {
  console.error('Auth deletion failed:', authError)
  // WARNING: User data deleted but auth record remains
  // Manual cleanup required in Supabase Dashboard
  return
}

console.log('✅ User completely deleted from all systems')
```

### For GDPR Compliance:

```javascript
async function handleGDPRDeletion(userId, requestedBy) {
  // 1. Log the deletion request
  await supabase.from('deletion_logs').insert({
    user_id: userId,
    requested_by: requestedBy,
    requested_at: new Date(),
    reason: 'GDPR Right to be Forgotten'
  })

  // 2. Export user data (optional - for compliance)
  const userData = await exportUserData(userId)
  await saveToArchive(userData)

  // 3. Delete from database
  const { data, error } = await supabase.rpc('delete_user_completely', {
    p_user_id: userId
  })

  if (error) throw error

  // 4. Delete from auth
  await supabase.auth.admin.deleteUser(userId)

  // 5. Log completion
  await supabase.from('deletion_logs').update({
    completed_at: new Date(),
    status: 'completed',
    deleted_records: data.deleted_records
  }).eq('user_id', userId)

  return data
}
```

---

## Verification Queries

### Check if user is completely deleted:

```sql
-- Check profiles
SELECT * FROM profiles WHERE id = 'USER_UUID';

-- Check auth.users (via Supabase Dashboard only)

-- Check all user tables
SELECT
  'bookings' as table_name, COUNT(*) as count FROM bookings WHERE user_id = 'USER_UUID'
UNION ALL
SELECT 'user_subscriptions', COUNT(*) FROM user_subscriptions WHERE user_id = 'USER_UUID'
UNION ALL
SELECT 'friendships', COUNT(*) FROM friendships WHERE user_id = 'USER_UUID' OR friend_id = 'USER_UUID'
UNION ALL
SELECT 'referrals', COUNT(*) FROM referrals WHERE referrer_user_id = 'USER_UUID' OR referred_user_id = 'USER_UUID'
UNION ALL
SELECT 'chat_messages', COUNT(*) FROM chat_messages WHERE sender_id = 'USER_UUID';

-- Should return 0 for all tables
```

### Find all users:

```sql
-- List all profiles
SELECT id, email, full_name, created_at
FROM profiles
ORDER BY created_at DESC;

-- Count users in each table
SELECT
  (SELECT COUNT(*) FROM profiles) as profiles,
  (SELECT COUNT(*) FROM user_subscriptions) as subscriptions,
  (SELECT COUNT(*) FROM bookings) as bookings,
  (SELECT COUNT(*) FROM friendships) as friendships;
```

---

## Troubleshooting

### Issue: "User not found"
**Solution:** User may have already been deleted or UUID is incorrect.
```sql
-- Find user by email
SELECT id, email FROM profiles WHERE email = 'user@example.com';
```

### Issue: Foreign key constraint violation
**Solution:** Deletion order is wrong. Use the provided scripts which delete in correct order.

### Issue: "auth.users cannot be deleted via SQL"
**Solution:** This is expected. Use Supabase Dashboard or Admin API:
1. Dashboard: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl/auth/users
2. API: `await supabase.auth.admin.deleteUser(userId)`

### Issue: Orphaned profiles (profile exists but no auth.users)
**Solution:** Use cleanup function:
```sql
SELECT clean_orphaned_profiles();
```

### Issue: Performance on large deletions
**Solution:** Use batch deletion with smaller batches:
```javascript
const userIds = [...] // Array of 1000s of IDs
const batchSize = 100

for (let i = 0; i < userIds.length; i += batchSize) {
  const batch = userIds.slice(i, i + batchSize)
  await supabase.rpc('delete_users_batch', { p_user_ids: batch })
  console.log(`Processed ${i + batchSize}/${userIds.length}`)
}
```

---

## Files Reference

| File | Purpose | Use Case |
|------|---------|----------|
| `DELETE_ALL_USERS.sql` | Delete all users | Dev/staging reset |
| `DELETE_SINGLE_USER.sql` | Delete one user | GDPR, testing |
| `USER_DELETION_FUNCTION.sql` | Reusable functions | Production app integration |
| `USER_DELETION_GUIDE.md` | This guide | Documentation |

---

## Production Checklist

Before running in production:

- [ ] ✅ **Backup database** (Supabase Dashboard → Database → Backups)
- [ ] ✅ **Test in staging** environment first
- [ ] ✅ **Verify user UUID** is correct
- [ ] ✅ **Notify user** of deletion (if GDPR)
- [ ] ✅ **Export user data** (if required by law)
- [ ] ✅ **Run database deletion** (Step 1)
- [ ] ✅ **Verify deletion** with queries above
- [ ] ✅ **Delete from auth.users** (Step 2)
- [ ] ✅ **Verify auth deletion** in Supabase Dashboard
- [ ] ✅ **Log deletion** in audit log
- [ ] ✅ **Confirm with user** (if GDPR)

---

## Support

**Database Schema Questions:**
- See: `supabase/migrations/00_initial_schema.sql`
- See: `supabase/migrations/*` (all migration files)

**Supabase Auth API:**
- Docs: https://supabase.com/docs/reference/javascript/auth-admin-deleteuser
- Dashboard: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl

**Testing:**
- Create test users in staging
- Run deletion scripts
- Verify with verification queries

---

**Last Updated:** May 30, 2026
**Schema Version:** Latest (20260424_unique_active_subscription.sql)
