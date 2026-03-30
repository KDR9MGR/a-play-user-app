# ⚡ Quick Deployment Commands

**One-page reference for deploying A-Play to Supabase**

---

## 🔗 1. Link Project (First Time Only)

```bash
cd /Users/abdulrazak/Documents/a-play-user-app-main
supabase link --project-ref YOUR_PROJECT_REF
```

Get your project ref from: https://supabase.com/dashboard/project/_/settings/general

---

## 🗄️ 2. Deploy Database Migrations

```bash
supabase db push
```

**What this deploys:**
- `concierge_request_tracking` table
- `restaurant_bookings` payment columns
- Performance indexes

---

## ⚡ 3. Deploy Edge Functions

```bash
# Deploy PayStack webhook
supabase functions deploy paystack-webhook

# Deploy email service
supabase functions deploy send-email
```

---

## 🔐 4. Set Environment Variables

```bash
# Resend API key
supabase secrets set RESEND_API_KEY=re_YOUR_KEY_HERE

# PayStack secret key
supabase secrets set PAYSTACK_SECRET_KEY=sk_live_YOUR_KEY_HERE
```

**Get your keys:**
- Resend: https://resend.com/api-keys
- PayStack: https://dashboard.paystack.com/#/settings/developer

---

## 🧪 5. Test Deployment

```bash
# View webhook logs
supabase functions logs paystack-webhook --tail

# View email logs
supabase functions logs send-email --tail
```

---

## ✅ 6. Verify Everything Works

### Check database tables:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_name IN ('concierge_request_tracking', 'restaurant_bookings');
```

### Check functions:
```bash
supabase functions list
```

Should show:
- paystack-webhook
- send-email

### Check secrets:
```bash
supabase secrets list
```

Should show:
- RESEND_API_KEY
- PAYSTACK_SECRET_KEY

---

## 🚨 If Something Fails

**Migration error:**
```bash
supabase db reset  # WARNING: Clears all data
supabase db push
```

**Function deployment error:**
```bash
# Check function logs
supabase functions logs FUNCTION_NAME

# Redeploy
supabase functions deploy FUNCTION_NAME
```

**Secrets not working:**
```bash
# List secrets
supabase secrets list

# Update secret
supabase secrets set KEY_NAME=new_value
```

---

## 📋 Complete Deployment Sequence

Copy-paste this entire block:

```bash
# 1. Navigate to project
cd /Users/abdulrazak/Documents/a-play-user-app-main

# 2. Deploy migrations
supabase db push

# 3. Deploy functions
supabase functions deploy paystack-webhook
supabase functions deploy send-email

# 4. Set secrets (replace with your actual keys)
supabase secrets set RESEND_API_KEY=re_YOUR_RESEND_API_KEY
supabase secrets set PAYSTACK_SECRET_KEY=sk_live_YOUR_PAYSTACK_SECRET

# 5. Verify
supabase functions list
supabase secrets list

# 6. Test with logs
supabase functions logs paystack-webhook --tail
```

---

## 🔄 Update PayStack Webhook

After deployment, update your PayStack webhook URL:

1. Go to: https://dashboard.paystack.com/#/settings/developer
2. Find "Webhook URL"
3. Set to: `https://YOUR_PROJECT_REF.supabase.co/functions/v1/paystack-webhook`
4. Save changes

---

## ✅ Done!

Your A-Play backend is now synced with Supabase.

**Next:** Test the app flow:
1. Sign up new user
2. Complete onboarding
3. See trial offer
4. Book a restaurant table
5. Complete payment
6. Check email confirmation

See [SUPABASE_SYNC_GUIDE.md](SUPABASE_SYNC_GUIDE.md) for detailed troubleshooting.
