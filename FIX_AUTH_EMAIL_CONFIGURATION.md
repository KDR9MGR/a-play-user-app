# Fix Supabase Auth Email Configuration

**Date:** May 29, 2026
**Issue:** Password recovery emails failing to send

---

## Problem Diagnosis

### Errors Encountered:

1. **Supabase Dashboard Error:**
   ```
   Failed to send password recovery: Failed to make POST request to
   "https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover".
   Check your project's Auth logs for more information.
   Error message: Error sending recovery email
   ```

2. **cURL Command Error:**
   ```
   {"code":"NOT_FOUND","message":"Requested function was not found"}
   ```

### Root Causes:

1. **Auth Email Provider Not Configured**
   - Supabase Auth needs an email provider (SMTP or SendGrid/Resend)
   - By default, Supabase uses its own email service (limited)
   - For production, you need to configure a custom SMTP provider

2. **Email Confirmations May Be Enabled**
   - If email confirmations are required, this affects the flow
   - Need to check and configure appropriately

---

## Solution: Configure Supabase Auth Email Provider

### Step 1: Check Current Email Configuration

1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/yvnfhsipyfxdmulajbgl
2. Click **Authentication** in left sidebar
3. Click **Providers** tab
4. Scroll down to **Email** section
5. Check what's currently configured

---

## Option A: Use Resend as SMTP Provider (Recommended)

Since you already have Resend configured for the app, let's use it for Auth emails too.

### Step 1: Get Resend SMTP Credentials

Resend provides SMTP access. You need:
- SMTP Host: `smtp.resend.com`
- SMTP Port: `465` (SSL) or `587` (TLS)
- Username: `resend`
- Password: Your Resend API Key

Your API Key (from .env): `YOUR_RESEND_API_KEY_PLACEHOLDER`

### Step 2: Configure in Supabase Dashboard

1. Go to: **Authentication** → **Providers** → **Email**
2. Scroll to **SMTP Settings**
3. Enable **"Enable Custom SMTP"**
4. Fill in:
   ```
   SMTP Host: smtp.resend.com
   SMTP Port: 587
   SMTP Username: resend
   SMTP Password: YOUR_RESEND_API_KEY_PLACEHOLDER
   Sender Email: noreply@aplayapp.com
   Sender Name: A-Play
   ```
5. Click **Save**

### Step 3: Test SMTP Connection

After saving, Supabase will test the connection. You should see:
- ✅ **SMTP connection successful**

If you see an error, check:
- API key is correct
- Domain `aplayapp.com` is verified in Resend
- Port 587 is not blocked by your network

---

## Option B: Use Supabase's Built-in Email (Quick Test)

For testing purposes, you can use Supabase's built-in email service:

### Step 1: Ensure Email Provider is Enabled

1. Go to: **Authentication** → **Providers**
2. Find **Email** provider
3. Ensure it's **enabled** (toggle should be ON)
4. Click **Save**

### Step 2: Disable Email Confirmation (Optional for Testing)

1. Go to: **Authentication** → **Settings**
2. Scroll to **Email Auth**
3. Find **"Enable email confirmations"**
4. Toggle **OFF** for testing (can re-enable later)
5. Click **Save**

### Step 3: Check Rate Limits

Supabase's built-in email service has rate limits:
- 4 emails per hour per user
- Limited daily quota

This is fine for testing but not for production.

---

## Option C: Configure Email Redirect URLs

Even with email provider configured, you need to whitelist redirect URLs:

### Step 1: Add Redirect URLs

1. Go to: **Authentication** → **URL Configuration**
2. Scroll to **Redirect URLs**
3. Add these URLs (one per line):
   ```
   https://www.aplayworld.com/*
   https://aplayworld.com/*
   http://localhost:*
   aplayorganiser://*
   io.supabase.aplay://*
   ```
4. Click **Save**

### Step 2: Set Site URL

1. In same section, find **Site URL**
2. Set to: `https://www.aplayworld.com`
3. Click **Save**

---

## Fix the cURL Command Error

The error `"Requested function was not found"` means the cURL command had wrong endpoint.

### Correct cURL Command:

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs' \
  -H 'Content-Type: application/json' \
  -d '{"email":"YOUR_EMAIL_HERE"}'
```

**Replace `YOUR_EMAIL_HERE` with your actual email.**

---

## Test After Configuration

### Test 1: Password Reset via Dashboard

1. Go to: **Authentication** → **Users**
2. Find your user
3. Click **••• → Send password recovery**
4. Check your email inbox (and spam folder)

### Test 2: Password Reset via cURL

```bash
curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/auth/v1/recover' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs' \
  -H 'Content-Type: application/json' \
  -d '{"email":"your-email@example.com"}'
```

**Expected Response:**
```json
{}
```
(Empty object means success)

**Then check your email inbox.**

### Test 3: Check Auth Logs

1. Go to: **Authentication** → **Logs**
2. Look for recent entries
3. Check for errors or successful email sends

---

## Troubleshooting

### Error: "SMTP connection failed"

**Cause:** Resend SMTP credentials incorrect or domain not verified

**Fix:**
1. Log in to Resend Dashboard
2. Go to **API Keys**
3. Verify your API key is active
4. Go to **Domains**
5. Ensure `aplayapp.com` is verified (green checkmark)
6. If not verified, add DNS records shown by Resend

### Error: "Rate limit exceeded"

**Cause:** Using Supabase built-in email with rate limits

**Fix:** Configure custom SMTP (Option A above)

### Error: "Invalid redirect URL"

**Cause:** Redirect URL not whitelisted

**Fix:** Add all URLs to whitelist (Option C above)

### Emails Going to Spam

**Fix:**
1. Verify Resend domain with SPF/DKIM/DMARC
2. Add `noreply@aplayapp.com` to your contacts
3. Check Resend deliverability dashboard

---

## Recommended Setup for Production

### 1. Configure Resend SMTP ✅
- Use Option A (Resend as SMTP provider)
- This ensures reliable delivery
- Uses your verified domain
- No rate limits

### 2. Whitelist Redirect URLs ✅
- Add all app URLs (web + mobile)
- Prevents redirect errors

### 3. Enable Email Confirmations (Optional) ⚠️
- Good for security
- Requires users to verify email before login
- Can be disabled for testing

### 4. Customize Email Templates (Optional) ✨
- Go to: **Authentication** → **Email Templates**
- Customize:
  - Confirm Signup
  - Magic Link
  - Change Email
  - Reset Password
- Use your brand colors and messaging

---

## Test Welcome Email (Separate System)

Welcome emails are sent by your Flutter app via Resend directly (not Supabase Auth).

### Test Welcome Email via Terminal:

```bash
# Get your service role key from Supabase Dashboard:
# Project Settings → API → service_role (secret key)

curl -X POST \
  'https://yvnfhsipyfxdmulajbgl.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY_HERE' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "your-email@example.com",
    "subject": "Welcome to A-Play! 🎉",
    "html": "<div style=\"background: linear-gradient(135deg, #FF6B35 0%, #FF8A3D 100%); padding: 40px; text-align: center; border-radius: 16px;\"><h1 style=\"color: white;\">Welcome to A-Play! 🎉</h1><p style=\"color: white;\">Thank you for joining Ghana'\''s premier event booking platform!</p></div>"
  }'
```

**Expected Response:**
```json
{
  "message": "Email sent successfully",
  "id": "some-id"
}
```

---

## Quick Action Checklist

### Immediate Actions:

- [ ] **Step 1:** Configure Resend SMTP in Supabase Auth
  - Authentication → Providers → Email → Enable Custom SMTP
  - Use credentials from above

- [ ] **Step 2:** Add Redirect URLs
  - Authentication → URL Configuration
  - Add all URLs listed above

- [ ] **Step 3:** Test password reset via Dashboard
  - Authentication → Users → Send password recovery

- [ ] **Step 4:** Check email inbox
  - Look for password reset email
  - Check spam folder if not in inbox

- [ ] **Step 5:** Test welcome email
  - Use cURL command above with service role key
  - Check email inbox

### Verify After Setup:

- [ ] Password reset emails arrive in inbox
- [ ] Welcome emails arrive in inbox
- [ ] No emails in spam folder
- [ ] Links in emails work correctly
- [ ] Auth logs show successful sends

---

## Summary

### Current Issues:
1. ❌ Supabase Auth email provider not configured → Need to add SMTP
2. ❌ Redirect URLs not whitelisted → Need to add URLs
3. ❌ cURL command had wrong endpoint → Fixed in this guide

### Solution Steps:
1. ✅ Configure Resend as SMTP provider in Supabase Auth
2. ✅ Add redirect URLs to whitelist
3. ✅ Test password reset via Dashboard
4. ✅ Test welcome email via cURL (separate system)

### After Configuration:
- Password reset emails will work from app
- Welcome emails already work from app (just need to test)
- Both use Resend for reliable delivery
- No code changes needed

---

## Need Help?

If you encounter issues:

1. **Check Auth Logs:** Authentication → Logs
2. **Check Resend Dashboard:** See if emails were sent
3. **Check Spam Folder:** Emails might be filtered
4. **Verify Domain:** Ensure `aplayapp.com` is verified in Resend

---

**Last Updated:** May 29, 2026
**Status:** Awaiting SMTP configuration
