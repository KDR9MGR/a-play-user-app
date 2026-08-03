# Update Domain from aplayapp.com to aplayworld.com

**Date:** May 29, 2026
**Change:** Using correct domain `aplayworld.com` for all email configurations

---

## Changes Needed

You need to update the email domain in 3 places:

1. ✅ **`.env` file** - Already updated by me
2. ⏳ **Supabase Auth SMTP settings** - You need to update
3. ⏳ **Resend Dashboard** - You need to verify domain

---

## Step 1: Update Supabase Auth SMTP Settings

### Current (WRONG):
```
Sender Email: noreply@aplayapp.com  ❌
```

### Updated (CORRECT):
```
Sender Email: noreply@aplayworld.com  ✅
```

### How to Update:

1. **Go to Supabase Dashboard**
2. **Navigate to:** Authentication → Providers → Email
3. **Scroll to:** SMTP Settings
4. **Find:** "Sender Email" field
5. **Change from:** `noreply@aplayapp.com`
6. **Change to:** `noreply@aplayworld.com`
7. **Click:** Save

---

## Step 2: Verify Domain in Resend Dashboard

Before the email will work, you MUST verify `aplayworld.com` in Resend.

### How to Verify Domain:

1. **Log in to Resend Dashboard:** https://resend.com/domains

2. **Check if `aplayworld.com` is already added:**
   - Look in the domains list
   - If you see it with green checkmark ✅ → You're done!
   - If you see it with yellow icon ⏳ → Need to add DNS records
   - If you don't see it → Need to add domain

3. **If domain is NOT verified, click "Add Domain"**

4. **Enter:** `aplayworld.com`

5. **Resend will show DNS records to add:**

   **SPF Record (TXT):**
   ```
   Type: TXT
   Name: @
   Value: v=spf1 include:_spf.resend.com ~all
   ```

   **DKIM Record (TXT):**
   ```
   Type: TXT
   Name: resend._domainkey
   Value: [Long string provided by Resend]
   ```

   **DMARC Record (TXT - Optional):**
   ```
   Type: TXT
   Name: _dmarc
   Value: v=DMARC1; p=none; rua=mailto:postmaster@aplayworld.com
   ```

6. **Add these DNS records to your domain registrar:**
   - If your domain is with Namecheap, GoDaddy, Cloudflare, etc.
   - Log in to your domain registrar
   - Find "DNS Settings" or "DNS Management"
   - Add the 3 TXT records shown above

7. **Wait 5-30 minutes for DNS propagation**

8. **Click "Verify" in Resend Dashboard**

9. **Check status:**
   - ✅ Green checkmark = Verified!
   - ❌ Red X = DNS records not found yet (wait longer)

---

## Step 3: Alternative - Use Sandbox for Immediate Testing

If you can't verify the domain right now and want to test immediately:

### Use Resend Sandbox Email:

1. **In Supabase SMTP settings, use:**
   ```
   Sender Email: onboarding@resend.dev
   ```

2. **This will work immediately** (no domain verification needed)

3. **Limitation:** Only sends to YOUR email (the one you used for Resend account)

4. **Perfect for testing!**

---

## Step 4: Test After Update

### After updating sender email in Supabase:

1. **Go to:** Authentication → Users
2. **Find your user**
3. **Click:** ••• → Send password recovery
4. **Check your email inbox**

### Expected Results:

**If domain is verified:**
- ✅ Email arrives in inbox
- ✅ From: A-Play <noreply@aplayworld.com>
- ✅ Contains password reset link

**If domain is NOT verified:**
- ❌ Error in Auth Logs: "Domain not verified"
- ❌ No email received

**If using sandbox (onboarding@resend.dev):**
- ✅ Email arrives in inbox
- ✅ From: onboarding@resend.dev
- ✅ Contains password reset link

---

## Summary of Changes

### File: `.env`

**Before:**
```env
RESEND_FROM_EMAIL=A-Play <noreply@aplayapp.com>
```

**After:**
```env
RESEND_FROM_EMAIL=A-Play <noreply@aplayworld.com>
```

✅ **Status:** Already updated

---

### Supabase Auth SMTP Settings

**Before:**
```
Sender Email: noreply@aplayapp.com
```

**After:**
```
Sender Email: noreply@aplayworld.com
```

⏳ **Status:** You need to update this in Supabase Dashboard

---

### Resend Domain Verification

**Domain:** `aplayworld.com`

⏳ **Status:** Check if verified, if not, add DNS records

---

## Quick Action Checklist

Do these in order:

- [ ] **1. Update Supabase SMTP sender email**
  - Go to: Authentication → Providers → Email
  - Change to: `noreply@aplayworld.com`
  - Click Save

- [ ] **2. Check Resend domain status**
  - Log in to: https://resend.com/domains
  - Look for: `aplayworld.com`
  - Status: Verified? ✅ or Not verified? ❌

- [ ] **3a. If domain NOT verified, use sandbox temporarily**
  - Change sender to: `onboarding@resend.dev`
  - Test immediately

- [ ] **3b. If domain NOT verified, verify it for production**
  - Add domain in Resend
  - Copy DNS records
  - Add to domain registrar
  - Wait for verification
  - Change sender back to: `noreply@aplayworld.com`

- [ ] **4. Test password reset**
  - Authentication → Users → Send password recovery
  - Check email inbox

- [ ] **5. Check Auth Logs if it fails**
  - Authentication → Logs
  - Look for error message
  - Share error with me

---

## Troubleshooting

### Error: "Domain not verified"

**Solution:** Either:
1. Use sandbox: `onboarding@resend.dev` (for testing)
2. Verify domain in Resend (for production)

### Error: "SMTP authentication failed"

**Solution:** API key might be wrong, verify:
```bash
# Test API key
curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer YOUR_RESEND_API_KEY_PLACEHOLDER' \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "onboarding@resend.dev",
    "to": "your-email@example.com",
    "subject": "Test",
    "html": "<p>Test</p>"
  }'
```

### Email goes to spam

**Solution:** Add DMARC record (shown in Step 2 above)

---

## Where is Your Domain Hosted?

To add DNS records, you need to know where your domain is hosted:

**Common registrars:**
- Namecheap → https://www.namecheap.com/myaccount/login/
- GoDaddy → https://www.godaddy.com/
- Cloudflare → https://dash.cloudflare.com/
- Google Domains → https://domains.google.com/
- Vercel → https://vercel.com/dashboard

**If you don't know:**
1. Go to: https://who.is/
2. Enter: `aplayworld.com`
3. Look for "Registrar" - this tells you where it's hosted

---

## Next Steps

**Right now:**

1. ✅ Update Supabase sender email to `noreply@aplayworld.com`
2. ✅ Check if domain is verified in Resend
3. ✅ If NOT verified, use `onboarding@resend.dev` for testing
4. ✅ Test password reset
5. ✅ Report back results

**For production:**

1. ⏳ Verify `aplayworld.com` in Resend
2. ⏳ Add DNS records to domain registrar
3. ⏳ Wait for verification
4. ⏳ Switch sender from sandbox to `noreply@aplayworld.com`

---

**Last Updated:** May 29, 2026
**Status:** .env updated, awaiting Supabase SMTP update
