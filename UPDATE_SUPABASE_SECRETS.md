# 🔐 Update Supabase Edge Function Secrets

## PayStack Test Credentials

You need to set the PayStack **test secret key** in your Supabase edge function.

### 📝 Command to Run

```bash
# Set PayStack TEST secret key in Supabase
supabase secrets set PAYSTACK_SECRET_KEY=YOUR_PAYSTACK_TEST_SECRET_KEY --project-ref YOUR_PROJECT_REF
```

### 🔍 Find Your Project Reference

**Option 1: From Supabase Dashboard**
1. Go to https://supabase.com/dashboard
2. Select your project
3. Look at the URL: `https://supabase.com/dashboard/project/YOUR_PROJECT_REF`
4. Copy the `YOUR_PROJECT_REF` part

**Option 2: From Project Settings**
1. Go to Settings → General
2. Find "Reference ID"
3. Copy the value

### ✅ Full Command Example

```bash
# If your project ref is "gixstjuzbqcvdfcqeztk", run:
supabase secrets set PAYSTACK_SECRET_KEY=YOUR_PAYSTACK_TEST_SECRET_KEY --project-ref gixstjuzbqcvdfcqeztk
```

### 📋 Verify Secrets Are Set

```bash
# List all secrets (values are hidden)
supabase secrets list --project-ref YOUR_PROJECT_REF
```

You should see:
```
PAYSTACK_SECRET_KEY=***
```

---

## 🎯 Edge Function: testplay

Your edge function `testplay` will use this secret key.

### Check Edge Function

```bash
# List all edge functions
supabase functions list --project-ref YOUR_PROJECT_REF
```

You should see `testplay` in the list.

### Deploy Edge Function (if needed)

```bash
# Deploy the testplay function
supabase functions deploy testplay --project-ref YOUR_PROJECT_REF
```

---

## 🔄 Switch Back to Live Keys Later

When you're ready to go live, run:

```bash
# Set PayStack LIVE secret key
supabase secrets set PAYSTACK_SECRET_KEY=sk_live_YOUR_LIVE_SECRET_KEY --project-ref YOUR_PROJECT_REF
```

And update the app:
- `lib/core/config/env.dart` - uncomment live key
- `lib/core/config/paystack_config.dart` - uncomment live key

---

## ⚠️ Important Notes

### Don't Commit Secret Keys
- Never commit `sk_test_*` or `sk_live_*` keys to git
- Only commit public keys (`pk_test_*` or `pk_live_*`)
- Secret keys should only be in:
  - Supabase edge function secrets
  - Your local `.env` file (which is gitignored)

### Test vs Live Keys
- **Test keys**: Start with `sk_test_` or `pk_test_`
- **Live keys**: Start with `sk_live_` or `pk_live_`
- Test keys won't charge real money
- Always test with test keys first!

---

## 🧪 Testing Payment Flow

After setting the secret:

1. Launch the app
2. Sign in (any method)
3. Navigate to Subscription screen
4. Select a plan
5. Complete payment with **test card**:
   - Card: `4084 0840 8408 4081`
   - CVV: `408`
   - Expiry: Any future date
   - PIN: `0000`

**Expected**: Payment succeeds, subscription activates

---

## 🆘 Troubleshooting

### Error: "Invalid secret key"
- Check the key starts with `sk_test_`
- Verify no extra spaces in the command
- Make sure you're using the correct project ref

### Error: "Project not found"
- Verify your project reference ID
- Check you're logged into Supabase CLI: `supabase login`

### Edge function not using secret
- Redeploy the function: `supabase functions deploy testplay`
- Wait 1-2 minutes for changes to propagate

---

**Ready to set secrets?** Run the command above! 🚀
