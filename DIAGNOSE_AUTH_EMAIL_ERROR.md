# Diagnose Auth Email Error - Step by Step

**Date:** May 29, 2026
**Issue:** Still getting "Error sending recovery email" after configuring SMTP

---

## Current Status

✅ **Completed:**
- SMTP configured with Resend credentials
- Redirect URL added: `https://www.aplayworld.com/*`

❌ **Still Failing:**
```
Failed to send password recovery: Failed to make POST request to
"https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover".
Check your project's Auth logs for more information.
Error message: Error sending recovery email
```

---

## Step 1: Check Auth Logs (MOST IMPORTANT)

The error message says "Check your project's Auth logs" - let's do that:

### How to Access Auth Logs:

1. Go to your Supabase Dashboard
2. Click **Authentication** in left sidebar
3. Click **Logs** tab
4. Look at the most recent entries

### What to Look For:

Look for log entries with:
- **Level:** ERROR (red)
- **Type:** auth.recovery
- **Timestamp:** Just now (when you tried to send)

### Common Error Messages:

**Error 1: "SMTP authentication failed"**
```
SMTP Error: Could not authenticate
```
**Fix:** API key is incorrect or expired

**Error 2: "Domain not verified"**
```
Error: Domain 'aplayapp.com' is not verified
```
**Fix:** Need to verify domain in Resend Dashboard

**Error 3: "Connection timeout"**
```
SMTP Error: Connection timeout
```
**Fix:** Try port 465 instead of 587

**Error 4: "Invalid sender email"**
```
Error: Sender email not authorized
```
**Fix:** Email must match verified domain

---

## Step 2: Verify Resend Domain

The sender email `noreply@aplayapp.com` requires domain verification.

### Check Domain Verification Status:

1. Log in to **Resend Dashboard:** https://resend.com/domains
2. Look for `aplayapp.com` in domains list
3. Check status:
   - ✅ **Verified** (green checkmark) → Good!
   - ⏳ **Pending** (yellow) → Need to add DNS records
   - ❌ **Not found** → Need to add domain

### If Domain is Not Verified:

**Option A: Use Resend Test Domain (Quick Test)**

Change SMTP sender email in Supabase to:
```
Sender Email: onboarding@resend.dev
```

This is Resend's sandbox domain - it works immediately but **only sends to your verified email address**.

**Option B: Verify Your Domain (Production)**

1. In Resend Dashboard, click **"Add Domain"**
2. Enter: `aplayapp.com`
3. Resend will show DNS records to add
4. Add these records to your domain's DNS:
   - **SPF Record** (TXT)
   - **DKIM Record** (TXT)
   - **DMARC Record** (TXT - optional)
5. Wait 5-30 minutes for DNS propagation
6. Click "Verify" in Resend Dashboard

---

## Step 3: Verify SMTP Configuration

Let's double-check the SMTP settings you entered:

### Correct Configuration for Resend:

```
Enable Custom SMTP: ✅ ON

SMTP Host: smtp.resend.com
SMTP Port: 587
SMTP Username: resend
SMTP Password: YOUR_RESEND_API_KEY_PLACEHOLDER

Sender Email: onboarding@resend.dev  (for testing)
    OR
Sender Email: noreply@aplayapp.com  (if domain verified)

Sender Name: A-Play
```

### Common Mistakes:

❌ **Wrong:**
- Port: 465 (use 587 for TLS)
- Username: Your email address (should be "resend")
- Password: A different API key

✅ **Correct:**
- Port: 587
- Username: resend
- Password: Your Resend API key

---

## Step 4: Test SMTP Connection

After saving SMTP settings, Supabase should test the connection.

### Check SMTP Connection Status:

1. In Supabase Dashboard, go to: **Authentication** → **Providers** → **Email**
2. Scroll to SMTP Settings
3. Look for connection status message:
   - ✅ **"SMTP connection successful"** → Good!
   - ❌ **"SMTP connection failed"** → Check credentials

### If Connection Failed:

**Try Alternative Port:**

Some networks block port 587. Try port 465 with SSL:

```
SMTP Port: 465
```

Then save and test again.

---

## Step 5: Check Email Confirmations Setting

Email confirmations might be interfering with password reset.

### Temporarily Disable Email Confirmations:

1. Go to: **Authentication** → **Settings**
2. Scroll to **Email Auth** section
3. Find **"Enable email confirmations"**
4. Toggle **OFF** (for testing)
5. Click **Save**

This won't affect password reset, but can eliminate one variable.

---

## Step 6: Add More Redirect URLs

You only added one redirect URL. Add all these:

### Required Redirect URLs:

1. Go to: **Authentication** → **URL Configuration**
2. In **"Redirect URLs"** section, add:
   ```
   https://www.aplayworld.com/*
   https://aplayworld.com/*
   http://localhost:3000/*
   http://localhost:8080/*
   aplayorganiser://*
   io.supabase.aplay://*
   ```
3. Click **Save**

---

## Step 7: Verify API Key is Valid

Let's test if your Resend API key actually works:

### Test Resend API Key via cURL:

```bash
curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer YOUR_RESEND_API_KEY_PLACEHOLDER' \
  -H 'Content-Type: application/json' \
  -d '{
    "from": "onboarding@resend.dev",
    "to": "YOUR_EMAIL_HERE",
    "subject": "Test Email from Resend",
    "html": "<p>This is a test email to verify Resend API key works.</p>"
  }'
```

**Replace `YOUR_EMAIL_HERE` with your actual email.**

### Expected Response:

**Success:**
```json
{
  "id": "uuid-here"
}
```

**Error - Invalid API Key:**
```json
{
  "statusCode": 401,
  "message": "Invalid API key"
}
```

**Error - Domain Not Verified:**
```json
{
  "statusCode": 403,
  "message": "Domain not verified"
}
```

If you get an error, your Resend setup needs fixing.

---

## Step 8: Use Resend Sandbox for Testing

If domain verification is taking too long, use Resend's test domain:

### Update SMTP Sender Email:

1. Go to: **Authentication** → **Providers** → **Email**
2. Change **Sender Email** to:
   ```
   onboarding@resend.dev
   ```
3. Click **Save**
4. Try sending password recovery again

**Note:** With `onboarding@resend.dev`, emails will ONLY be sent to YOUR email address (the one you used to sign up for Resend). This is perfect for testing!

---

## Step 9: Check Rate Limits

Resend has rate limits on sandbox domain:

- **Sandbox:** 1 email per day to verified recipients
- **Verified Domain:** Much higher limits

If you've already sent test emails today, wait until tomorrow or verify your domain.

---

## Step 10: Alternative - Use Different SMTP Provider

If Resend SMTP isn't working, you can temporarily use Gmail SMTP for testing:

### Gmail SMTP Configuration:

```
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP Username: your-gmail@gmail.com
SMTP Password: your-app-password (not regular password)
Sender Email: your-gmail@gmail.com
Sender Name: A-Play
```

**Note:** You need to generate an "App Password" in Gmail settings. Don't use your regular Gmail password.

---

## Diagnostic Checklist

Go through this checklist in order:

- [ ] **1. Check Auth Logs** - What's the exact error?
- [ ] **2. Verify Resend Domain** - Is `aplayapp.com` verified?
- [ ] **3. Test with Sandbox Email** - Change to `onboarding@resend.dev`
- [ ] **4. Check SMTP Connection** - Does Supabase show "connection successful"?
- [ ] **5. Test Resend API Key** - Run cURL test above
- [ ] **6. Add All Redirect URLs** - Don't just use one
- [ ] **7. Check Rate Limits** - Have you sent too many test emails?
- [ ] **8. Try Port 465** - If 587 doesn't work

---

## Most Likely Issues

Based on your error, the most likely causes are:

### 1. Domain Not Verified (80% probability)
**Symptom:** "Error sending recovery email"
**Fix:** Use `onboarding@resend.dev` for testing OR verify domain in Resend

### 2. Invalid API Key (15% probability)
**Symptom:** SMTP authentication failed
**Fix:** Get fresh API key from Resend Dashboard

### 3. Port Blocked (5% probability)
**Symptom:** Connection timeout
**Fix:** Try port 465 instead of 587

---

## Quick Fix - Try This First

**If you want to test immediately, do this:**

1. **Change Sender Email to Resend Sandbox:**
   - Go to: Authentication → Providers → Email
   - Change **Sender Email** to: `onboarding@resend.dev`
   - Click **Save**

2. **Try Sending Password Reset Again:**
   - Go to: Authentication → Users
   - Click ••• → Send password recovery
   - Check your email inbox

3. **If it works:**
   - ✅ Your SMTP is configured correctly
   - ✅ API key is valid
   - ❌ Just need to verify your domain for production

4. **If it still fails:**
   - Go to: Authentication → Logs
   - Take a screenshot of the error
   - Share the error message

---

## After Fixing

Once emails are working:

1. **Test Password Reset Flow:**
   - Send recovery email
   - Check inbox
   - Click link
   - Should redirect to reset password page

2. **Test Welcome Email:**
   - Use the cURL command from previous guide
   - Separate system from Auth

3. **Verify Domain for Production:**
   - Add DNS records in Resend
   - Change sender back to `noreply@aplayapp.com`

---

## Next Steps

**Right now, please:**

1. ✅ **Check Auth Logs** - Tell me what error you see
2. ✅ **Try Sandbox Email** - Change to `onboarding@resend.dev`
3. ✅ **Test API Key** - Run the cURL command from Step 7

Then report back with:
- What error shows in Auth logs?
- Does it work with `onboarding@resend.dev`?
- Does the API key test work?

---

**Last Updated:** May 29, 2026
**Status:** Awaiting Auth logs check
