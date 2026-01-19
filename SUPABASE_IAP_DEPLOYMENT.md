# Supabase IAP Backend - Deployment & Security Guide

This document covers deployment, environment setup, security best practices, and operational guidelines for the Supabase IAP backend.

---

## Table of Contents

1. [Environment Variables Setup](#environment-variables-setup)
2. [Deploying SQL Migrations](#deploying-sql-migrations)
3. [Deploying Edge Functions](#deploying-edge-functions)
4. [Security Best Practices](#security-best-practices)
5. [Row Level Security (RLS) Explained](#row-level-security-rls-explained)
6. [Monitoring & Logging](#monitoring--logging)
7. [Testing Guide](#testing-guide)
8. [Troubleshooting](#troubleshooting)
9. [Production Checklist](#production-checklist)

---

## Environment Variables Setup

### Required Environment Variables

You need to configure these in your **Supabase Dashboard** for the Edge Functions to work.

#### 1. Navigate to Edge Functions Settings

```
Supabase Dashboard → Project Settings → Edge Functions → Environment Variables
```

#### 2. Add These Variables

| Variable Name | Description | Where to Get It | Example |
|--------------|-------------|-----------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | Supabase Dashboard → Settings → API | `https://abcdefgh.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (bypasses RLS) | Supabase Dashboard → Settings → API → service_role | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `APPLE_SHARED_SECRET` | Apple App Store shared secret | App Store Connect → App → Subscriptions → App-Specific Shared Secret | `a1b2c3d4e5f6...` |

#### 3. How to Add Environment Variables

**Option A: Via Supabase Dashboard**
1. Go to Project Settings → Edge Functions
2. Click "Add variable"
3. Enter name and value
4. Click "Save"

**Option B: Via Supabase CLI**
```bash
# Set environment variables for Edge Functions
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
supabase secrets set APPLE_SHARED_SECRET=your_apple_shared_secret
```

### Getting the APPLE_SHARED_SECRET

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to: **My Apps** → **Your App** → **Monetization** → **Subscriptions**
3. Under "Shared Secret", click **Generate** (if you don't have one)
4. Copy the **App-Specific Shared Secret** (recommended over Master Shared Secret)
5. Paste it into Supabase environment variables

**IMPORTANT**:
- Use **App-Specific Shared Secret** for better security
- Never commit this secret to version control
- Keep it secure like a password

---

## Deploying SQL Migrations

### Prerequisites

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link your local project to Supabase:
```bash
supabase link --project-ref your-project-id
```

### Deploy the Migration

#### Option A: Via Supabase CLI (Recommended)

```bash
# Navigate to your project directory
cd /Users/abdulrazak/Documents/a-play-user-app

# Apply the migration to remote database
supabase db push

# This will execute:
# - supabase/migrations/20250108_create_subscriptions_table.sql
```

The migration will create:
- `subscriptions` table
- `subscription_events` table
- Helper functions: `get_user_subscription()`, `user_has_active_subscription()`
- RLS policies
- Indexes

#### Option B: Via Supabase Dashboard

1. Go to Supabase Dashboard → **SQL Editor**
2. Click **New Query**
3. Copy contents of `supabase/migrations/20250108_create_subscriptions_table.sql`
4. Paste into SQL Editor
5. Click **Run**

### Verify Migration Success

```sql
-- Run this in Supabase SQL Editor to verify tables exist

-- Check tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('subscriptions', 'subscription_events');

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('subscriptions', 'subscription_events');

-- Check functions exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('get_user_subscription', 'user_has_active_subscription');
```

Expected output:
```
table_name: subscriptions
table_name: subscription_events

tablename: subscriptions, rowsecurity: true
tablename: subscription_events, rowsecurity: true

routine_name: get_user_subscription
routine_name: user_has_active_subscription
```

---

## Deploying Edge Functions

### Prerequisites

Ensure you have:
- Supabase CLI installed
- Environment variables configured (see above)
- Linked project: `supabase link --project-ref your-project-id`

### Deploy Both Edge Functions

```bash
# Navigate to your project directory
cd /Users/abdulrazak/Documents/a-play-user-app

# Deploy verify-apple-sub function
supabase functions deploy verify-apple-sub

# Deploy get-subscription-status function
supabase functions deploy get-subscription-status
```

### Deploy Individual Function

```bash
# Deploy only verify-apple-sub
supabase functions deploy verify-apple-sub

# Deploy only get-subscription-status
supabase functions deploy get-subscription-status
```

### Verify Deployment

1. Check in Supabase Dashboard:
   - Go to **Edge Functions**
   - You should see both functions listed
   - Status should be "Deployed"

2. Test via CLI:
```bash
# Test verify-apple-sub
supabase functions invoke verify-apple-sub \
  --body '{"receiptData":"test","userId":"test-user-id","sandbox":true}'

# Test get-subscription-status
supabase functions invoke get-subscription-status \
  --body '{"userId":"test-user-id"}'
```

### Function URLs

After deployment, your functions are available at:

```
Production:
https://your-project-ref.supabase.co/functions/v1/verify-apple-sub
https://your-project-ref.supabase.co/functions/v1/get-subscription-status

Local Development:
http://localhost:54321/functions/v1/verify-apple-sub
http://localhost:54321/functions/v1/get-subscription-status
```

---

## Security Best Practices

### 1. Service Role Key Protection

**CRITICAL SECURITY RULE**: Never expose `SUPABASE_SERVICE_ROLE_KEY` to client-side code.

#### ✅ CORRECT: Use service_role in Edge Functions only

```typescript
// Edge Function (server-side)
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, supabaseServiceKey);
```

#### ❌ WRONG: Never use service_role in Flutter app

```dart
// Flutter app (client-side) - NEVER DO THIS!
final supabase = SupabaseClient(
  'url',
  'service_role_key', // ❌ SECURITY BREACH - Anyone can decompile app
);
```

**Why?**:
- Service role key bypasses all RLS policies
- If exposed, attackers can read/write/delete ANY data
- Mobile apps can be decompiled to extract keys

**Solution**:
- Client uses `anon_key` (safe to expose)
- Edge Functions use `service_role_key` (server-side only)

### 2. RLS Policies Explained

Our subscription tables have strict RLS policies:

```sql
-- Users can READ their own subscriptions
-- Users CANNOT WRITE (prevent fraud)
-- Only service_role can WRITE (via Edge Functions)

-- Policy 1: Read access
CREATE POLICY "Users can read own subscriptions"
  ON public.subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy 2: Service role full access
CREATE POLICY "Service role has full access"
  ON public.subscriptions
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy 3: No direct INSERT/UPDATE/DELETE for users
-- (Enforced by absence of policies)
```

**What this means**:
- ✅ Users can query their subscription status via client
- ❌ Users cannot INSERT/UPDATE/DELETE subscriptions directly
- ✅ Edge Functions (using service_role) can INSERT/UPDATE subscriptions
- ✅ This prevents subscription fraud

### 3. Apple Receipt Verification

**Server-side verification is mandatory** to prevent:
- Fake receipts
- Replayed receipts
- Modified purchase data

```typescript
// ❌ NEVER trust client-side purchase data
// Client says: "I purchased premium!" → Don't believe it

// ✅ ALWAYS verify with Apple servers
// 1. Client sends receipt
// 2. Server verifies with Apple
// 3. Apple confirms: "Yes, valid subscription"
// 4. Server updates database
// 5. Server tells client: "You're premium"
```

### 4. Sandbox vs Production

**CRITICAL**: Always use the correct environment.

```typescript
// Development/TestFlight
const isSandbox = true;
const endpoint = 'https://sandbox.itunes.apple.com/verifyReceipt';

// Production (App Store)
const isSandbox = false;
const endpoint = 'https://buy.itunes.apple.com/verifyReceipt';
```

**Auto-detection** (our Edge Function handles this):
```typescript
// If production endpoint returns status 21007
// → Receipt is from sandbox
// → Automatically retry with sandbox endpoint
```

### 5. Prevent Replay Attacks

We use `latest_transaction_id` as a unique constraint:

```sql
latest_transaction_id TEXT UNIQUE
```

**What this prevents**:
- User can't submit same receipt multiple times
- Upsert ensures one subscription per transaction
- Renewals update existing record

### 6. Environment Variable Security

```bash
# ✅ CORRECT: Set via Supabase CLI or Dashboard
supabase secrets set APPLE_SHARED_SECRET=abc123

# ❌ WRONG: Don't commit to .env files
# .env
APPLE_SHARED_SECRET=abc123  # ← Will be in git history!

# ✅ Add to .gitignore
echo ".env" >> .gitignore
```

---

## Row Level Security (RLS) Explained

### What is RLS?

Row Level Security is PostgreSQL's way of enforcing access control at the row level, not just table level.

### Why We Use RLS

Without RLS:
```sql
-- Anyone with database access can do:
DELETE FROM subscriptions WHERE user_id = 'any-user';
UPDATE subscriptions SET expires_at = '2099-12-31' WHERE user_id = 'me';
```

With RLS:
```sql
-- Users can only see their own subscriptions
-- Users cannot modify subscriptions at all
-- Only server (service_role) can modify
```

### How Our RLS Works

#### Scenario 1: User Queries Their Subscription (Client)

```dart
// Flutter app using anon_key
final supabase = Supabase.instance.client;

final response = await supabase
  .from('subscriptions')
  .select('*')
  .eq('user_id', currentUserId);

// RLS Policy Applied:
// - Policy: "Users can read own subscriptions"
// - USING (auth.uid() = user_id)
// - Result: ✅ Returns rows where user_id matches authenticated user
```

#### Scenario 2: Hacker Tries to Query Other User's Subscription

```dart
// Hacker tries to see another user's subscription
final response = await supabase
  .from('subscriptions')
  .select('*')
  .eq('user_id', 'victim-user-id');

// RLS Policy Applied:
// - Policy: "Users can read own subscriptions"
// - USING (auth.uid() = user_id)
// - Result: ❌ Returns empty array (their auth.uid() ≠ victim's user_id)
```

#### Scenario 3: Hacker Tries to Give Themselves Premium

```dart
// Hacker tries to insert fake subscription
final response = await supabase
  .from('subscriptions')
  .insert({
    'user_id': 'me',
    'status': 'active',
    'product_id': 'SUBAU',
    'expires_at': '2099-12-31',
  });

// RLS Policy Applied:
// - No INSERT policy exists for authenticated users
// - Result: ❌ ERROR: "new row violates row-level security policy"
```

#### Scenario 4: Edge Function Updates Subscription (Server)

```typescript
// Edge Function using service_role_key
const supabase = createClient(url, serviceRoleKey);

await supabase.from('subscriptions').insert({
  user_id: 'user-123',
  status: 'active',
  product_id: 'SUBM',
  expires_at: '2025-12-31T00:00:00Z',
});

// RLS Policy Applied:
// - Policy: "Service role has full access"
// - TO service_role
// - Result: ✅ Insert succeeds (service_role bypasses RLS)
```

### RLS Policy Hierarchy

```
1. Check if table has RLS enabled
   └─ YES → Apply policies

2. Check user role
   ├─ service_role → Grant all access (bypass RLS)
   ├─ authenticated → Apply policies for authenticated users
   ├─ anon → Apply policies for anon users
   └─ No policies match → DENY

3. For SELECT: Check USING clause
   └─ USING (auth.uid() = user_id) → Only show matching rows

4. For INSERT/UPDATE/DELETE: Check WITH CHECK clause
   └─ No policy exists → DENY operation
```

---

## Monitoring & Logging

### View Edge Function Logs

```bash
# View live logs for verify-apple-sub
supabase functions logs verify-apple-sub --tail

# View logs for get-subscription-status
supabase functions logs get-subscription-status --tail

# View logs from specific time
supabase functions logs verify-apple-sub --since 2h
```

### Via Supabase Dashboard

1. Go to **Edge Functions**
2. Click on function name
3. Click **Logs** tab
4. Filter by date/time

### What to Monitor

**Success Metrics**:
- ✅ Verification requests per day
- ✅ Success rate (successful vs failed verifications)
- ✅ Average response time

**Error Patterns**:
- ❌ Apple status 21007 (sandbox/production mismatch)
- ❌ Invalid receipts
- ❌ Network timeouts
- ❌ Database write failures

### Query Subscription Stats

```sql
-- Total active subscriptions
SELECT COUNT(*)
FROM subscriptions
WHERE status IN ('active', 'grace_period')
  AND (expires_at IS NULL OR expires_at > NOW());

-- Subscriptions by product
SELECT product_id, COUNT(*)
FROM subscriptions
WHERE status = 'active'
GROUP BY product_id;

-- Recent subscription events
SELECT event_type, COUNT(*), MAX(created_at)
FROM subscription_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY event_type;

-- Sandbox vs production subscriptions
SELECT sandbox, COUNT(*)
FROM subscriptions
WHERE status = 'active'
GROUP BY sandbox;
```

---

## Testing Guide

### Local Development Testing

#### 1. Start Supabase locally

```bash
supabase start
```

#### 2. Run Edge Functions locally

```bash
# Serve verify-apple-sub
supabase functions serve verify-apple-sub --env-file .env.local

# In another terminal, serve get-subscription-status
supabase functions serve get-subscription-status --env-file .env.local
```

Create `.env.local`:
```env
SUPABASE_URL=http://localhost:54321
SUPABASE_SERVICE_ROLE_KEY=your_local_service_role_key
APPLE_SHARED_SECRET=your_apple_shared_secret
```

#### 3. Test with curl

```bash
# Test verify-apple-sub
curl -X POST http://localhost:54321/functions/v1/verify-apple-sub \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_anon_key" \
  -d '{
    "receiptData": "base64_encoded_receipt",
    "userId": "test-user-id",
    "sandbox": true
  }'

# Test get-subscription-status
curl -X POST http://localhost:54321/functions/v1/get-subscription-status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_anon_key" \
  -d '{"userId": "test-user-id"}'
```

### Testing with Apple Sandbox

#### 1. Create Sandbox Tester Account

1. Go to App Store Connect
2. **Users and Access** → **Sandbox Testers**
3. Click **+** to create new tester
4. Use a **new, unused email** (can be fake like `test@example.com`)
5. Set password and country

#### 2. Test Purchase Flow

1. Build app with **sandbox mode enabled**:
   ```dart
   const isSandbox = true;
   ```

2. Install on **real iOS device** or **TestFlight**
   - Note: Sandbox doesn't work in simulator

3. Sign out of real App Store account:
   - Settings → App Store → Sign Out

4. Launch app and make purchase

5. When prompted, sign in with **sandbox tester account**

6. Complete purchase

7. Check Supabase tables:
   ```sql
   SELECT * FROM subscriptions WHERE sandbox = true;
   ```

#### 3. Test Subscription Status Check

```dart
// In your app, add debug button
ElevatedButton(
  onPressed: () async {
    final user = Supabase.instance.client.auth.currentUser!;
    final response = await Supabase.instance.client.functions.invoke(
      'get-subscription-status',
      body: {'userId': user.id},
    );
    print(response.data);
  },
  child: Text('Check Status'),
)
```

---

## Troubleshooting

### Issue 1: "Environment variable not found"

```
Error: Deno.env.get('APPLE_SHARED_SECRET') returned undefined
```

**Solution**:
1. Check environment variables in Supabase Dashboard
2. Redeploy Edge Function after adding variables:
   ```bash
   supabase functions deploy verify-apple-sub
   ```

### Issue 2: "Apple status 21007"

```
Apple returned status: 21007
```

**Meaning**: Sandbox receipt sent to production endpoint

**Solution**:
- Edge Function automatically retries with sandbox endpoint
- If still failing, check `sandbox` flag in request

### Issue 3: "Row Level Security violation"

```
Error: new row violates row-level security policy
```

**Cause**: Trying to write to subscriptions from client

**Solution**:
- ❌ Don't use client to insert/update subscriptions
- ✅ Use Edge Function (service_role)

### Issue 4: "Invalid receipt"

```
{ success: false, errorCode: 'invalid_receipt', appleStatus: 21002 }
```

**Possible Causes**:
- Receipt data is not base64 encoded
- Receipt is corrupted
- Receipt is from different app

**Solution**:
1. Verify receipt is base64 encoded
2. Check receipt is from your app bundle ID
3. Test with sandbox tester account

### Issue 5: Function timeout

```
Error: Function execution time limit exceeded
```

**Cause**: Apple verification taking too long

**Solution**:
1. Check network connectivity
2. Apple servers may be slow (rare)
3. Implement retry logic in client

---

## Production Checklist

Before launching to production:

### Backend Setup
- [ ] SQL migration deployed to production database
- [ ] Edge Functions deployed to production
- [ ] Environment variables set correctly:
  - [ ] `SUPABASE_URL` (production)
  - [ ] `SUPABASE_SERVICE_ROLE_KEY` (production)
  - [ ] `APPLE_SHARED_SECRET` (production, not sandbox)
- [ ] RLS policies verified and enabled
- [ ] Helper functions created and working

### Apple Configuration
- [ ] Products created in App Store Connect
- [ ] App-Specific Shared Secret generated
- [ ] Products submitted for review
- [ ] Products approved and available

### Client Configuration
- [ ] Product IDs match App Store Connect:
  - [ ] SUB7DAY (Weekly)
  - [ ] SUBM (Monthly)
  - [ ] SUBM3 (3 Month)
  - [ ] SUBAU (Annual)
- [ ] Sandbox mode disabled in production build
- [ ] Receipt verification calls Edge Function
- [ ] Subscription status check implemented
- [ ] Error handling for all edge cases

### Testing
- [ ] Tested purchase flow with sandbox
- [ ] Tested subscription status check
- [ ] Tested receipt verification
- [ ] Tested expired subscription handling
- [ ] Tested subscription renewal
- [ ] Tested cancellation flow
- [ ] Tested refund scenario

### Security
- [ ] service_role_key NOT exposed in client
- [ ] Client uses anon_key only
- [ ] All secrets in environment variables
- [ ] No secrets committed to git
- [ ] RLS policies prevent direct writes

### Monitoring
- [ ] Set up error alerting
- [ ] Monitor Edge Function logs
- [ ] Track subscription metrics
- [ ] Monitor Apple status codes

### Documentation
- [ ] Team knows how to deploy functions
- [ ] Team knows how to check logs
- [ ] Team knows how to handle support cases
- [ ] Team knows where shared secret is stored

---

## Quick Reference Commands

```bash
# Deployment
supabase login
supabase link --project-ref your-project-id
supabase db push
supabase functions deploy verify-apple-sub
supabase functions deploy get-subscription-status

# Environment Variables
supabase secrets set APPLE_SHARED_SECRET=your_secret
supabase secrets list

# Logs
supabase functions logs verify-apple-sub --tail
supabase functions logs get-subscription-status --tail

# Testing
supabase functions invoke verify-apple-sub --body '{"test":"data"}'
```

---

## Support Resources

- **Supabase Docs**: https://supabase.com/docs
- **Edge Functions**: https://supabase.com/docs/guides/functions
- **Apple Receipt Validation**: https://developer.apple.com/documentation/appstorereceipts
- **Apple Status Codes**: https://developer.apple.com/documentation/appstorereceipts/status

---

## Summary

This backend architecture provides:
- ✅ Secure server-side receipt verification
- ✅ Centralized subscription state in database
- ✅ Protection against fraud via RLS
- ✅ Easy deployment and monitoring
- ✅ Automatic sandbox/production handling
- ✅ Production-ready error handling

The key principle: **Apple ↔ Edge Function ↔ Database ↔ Client**

Never: ~~Apple ↔ Database~~ or ~~Client ↔ Database (write)~~
